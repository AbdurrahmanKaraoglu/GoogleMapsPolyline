import 'dart:async';
import 'dart:convert';

import 'package:google_maps_polyline/src/point_latlng.dart';
import 'package:google_maps_polyline/src/polyline_codec.dart';
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
import 'package:google_maps_polyline/src/utils/result_polyline.dart';
import 'package:google_maps_polyline/src/utils/waypoint_polyline.dart';
import 'package:http/http.dart' as http;

/// Google Directions API ile iletişimi yürütür.
class MyNetworkUtil {
  /// Dışarıdan verilen HTTP istemcisi. `null` ise her istek için geçici bir
  /// istemci oluşturulur ve istek bitince kapatılır.
  final http.Client? client;

  /// İsteğin en fazla ne kadar süreceği.
  final Duration timeout;

  MyNetworkUtil({this.client, this.timeout = const Duration(seconds: 15)});

  static const Map<String, String> _statusMessages = {
    "ZERO_RESULTS": "Başlangıç ve hedef arasında rota bulunamadı.",
    "NOT_FOUND": "Başlangıç, hedef veya ara noktalardan en az biri bulunamadı.",
    "OVER_QUERY_LIMIT": "API kotası aşıldı.",
    "OVER_DAILY_LIMIT": "Günlük API kotası aşıldı veya faturalandırma etkin değil.",
    "REQUEST_DENIED": "İstek reddedildi; API anahtarını ve Directions API yetkisini kontrol edin.",
    "INVALID_REQUEST": "Geçersiz istek.",
    "MAX_WAYPOINTS_EXCEEDED": "Ara nokta sayısı sınırı aşıldı.",
    "MAX_ROUTE_LENGTH_EXCEEDED": "Rota çok uzun.",
    "UNKNOWN_ERROR": "Sunucu hatası; istek tekrar denenebilir.",
  };

  /// Google Directions API'den iki nokta arasındaki rotayı alır.
  ///
  /// Hata durumunda istisna fırlatmaz; [ResultPolyline.status] ve
  /// [ResultPolyline.errorMessage] doldurulur. API anahtarı hata
  /// mesajlarında asla yer almaz.
  ///
  /// [detailedPolyline] `true` ise rota, Google'ın sadeleştirdiği
  /// `overview_polyline` yerine her adımın (`legs[].steps[].polyline`)
  /// birleştirilmesiyle oluşturulur; yakın zoom'da yolu daha iyi izler.
  Future<ResultPolyline> getRouteBetweenCoordinates(
      String googleApiKey,
      MyPointLatLng origin,
      MyPointLatLng destination,
      MyTravelMode travelMode,
      List<WayPointPolyline> wayPoints,
      bool avoidHighways,
      bool avoidTolls,
      bool avoidFerries,
      bool optimizeWaypoints,
      {bool detailedPolyline = false}) async {
    if (!_isFinite(origin) || !_isFinite(destination)) {
      return ResultPolyline(
          status: ResultPolyline.statusError, errorMessage: "Başlangıç ve hedef koordinatları sonlu sayılar olmalı.");
    }
    final uri = buildUri(googleApiKey, origin, destination, travelMode, wayPoints, avoidHighways, avoidTolls,
        avoidFerries, optimizeWaypoints);

    final activeClient = client ?? http.Client();
    final http.Response response;
    try {
      response = await activeClient.get(uri).timeout(timeout);
    } on TimeoutException {
      return ResultPolyline(
          status: ResultPolyline.statusError, errorMessage: "İstek ${timeout.inSeconds} saniye içinde yanıtlanmadı.");
    } on Exception catch (e) {
      return ResultPolyline(status: ResultPolyline.statusError, errorMessage: _redact("Ağ hatası: $e", googleApiKey));
    } finally {
      if (client == null) activeClient.close();
    }

    final Map<String, dynamic> body;
    try {
      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) throw const FormatException();
      body = decoded;
    } on FormatException {
      return ResultPolyline(
          status: ResultPolyline.statusError,
          errorMessage:
              response.statusCode == 200 ? "Directions API yanıtı okunamadı." : "HTTP ${response.statusCode} hatası.");
    }

    final status = body["status"] is String ? body["status"] as String : null;
    if (response.statusCode != 200 && status == null) {
      return ResultPolyline(status: ResultPolyline.statusError, errorMessage: "HTTP ${response.statusCode} hatası.");
    }

    if (status == "OK") {
      try {
        final points = _routePoints(body["routes"], detailedPolyline);
        if (points == null) {
          return ResultPolyline(status: "ZERO_RESULTS", errorMessage: _statusMessages["ZERO_RESULTS"]);
        }
        return ResultPolyline(status: status, points: points);
      } on FormatException catch (e) {
        return ResultPolyline(status: ResultPolyline.statusError, errorMessage: "Polyline çözülemedi: ${e.message}");
      }
    }

    final apiMessage = body["error_message"] is String ? body["error_message"] as String : null;
    return ResultPolyline(
        status: status ?? ResultPolyline.statusError,
        errorMessage:
            _redact(apiMessage ?? _statusMessages[status] ?? "Bilinmeyen yanıt durumu: $status", googleApiKey));
  }

  /// Directions API istek adresini oluşturur. Tüm değerler `Uri` tarafından
  /// kodlanır. Sonlu olmayan (NaN, sonsuz) koordinatlarda [ArgumentError]
  /// fırlatır.
  Uri buildUri(
      String googleApiKey,
      MyPointLatLng origin,
      MyPointLatLng destination,
      MyTravelMode travelMode,
      List<WayPointPolyline> wayPoints,
      bool avoidHighways,
      bool avoidTolls,
      bool avoidFerries,
      bool optimizeWaypoints) {
    if (!_isFinite(origin)) throw ArgumentError.value(origin, 'origin', 'Sonlu olmayan koordinat');
    if (!_isFinite(destination)) throw ArgumentError.value(destination, 'destination', 'Sonlu olmayan koordinat');
    final avoid = [
      if (avoidHighways) "highways",
      if (avoidTolls) "tolls",
      if (avoidFerries) "ferries",
    ];
    final params = <String, String>{
      "origin": formatLatLng(origin),
      "destination": formatLatLng(destination),
      "mode": travelMode.name,
      if (avoid.isNotEmpty) "avoid": avoid.join('|'),
      if (wayPoints.isNotEmpty)
        "waypoints": [if (optimizeWaypoints) "optimize:true", ...wayPoints.map((p) => p.toString())].join('|'),
      "key": googleApiKey,
    };
    return Uri.https("maps.googleapis.com", "maps/api/directions/json", params);
  }

  /// Koordinatı API'nin beklediği `enlem,boylam` biçimine çevirir.
  ///
  /// `double.toString` küçük değerleri `1e-7` gibi üstel yazar ve API bunu
  /// reddeder; bu yüzden en fazla 7 ondalık basamakla sabit gösterim kullanılır.
  static String formatLatLng(MyPointLatLng point) =>
      "${_formatDegrees(point.latitude)},${_formatDegrees(point.longitude)}";

  static String _formatDegrees(double value) {
    var text = value.toStringAsFixed(7);
    text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    return text == '-0' ? '0' : text;
  }

  static bool _isFinite(MyPointLatLng p) => p.latitude.isFinite && p.longitude.isFinite;

  /// İlk rotanın noktalarını döndürür; rota yoksa `null`.
  /// [detailed] ise adım polylinelerini birleştirir, adımlar okunamazsa
  /// `overview_polyline`'a döner.
  static List<MyPointLatLng>? _routePoints(Object? routes, bool detailed) {
    if (routes is! List || routes.isEmpty) return null;
    final route = routes.first;
    if (route is! Map) return null;

    if (detailed) {
      final stepPolylines = _stepPolylines(route["legs"]);
      if (stepPolylines != null) {
        final points = <MyPointLatLng>[];
        for (final encoded in stepPolylines) {
          final stepPoints = PolylineCodec.decode(encoded);
          // Ardışık adımlar ortak bir noktada birleşir; tekrarı atla.
          final skipFirst = points.isNotEmpty && stepPoints.isNotEmpty && stepPoints.first == points.last;
          points.addAll(skipFirst ? stepPoints.skip(1) : stepPoints);
        }
        return points;
      }
    }

    final overview = route["overview_polyline"];
    if (overview is! Map) return null;
    final encoded = overview["points"];
    return encoded is String ? PolylineCodec.decode(encoded) : null;
  }

  static List<String>? _stepPolylines(Object? legs) {
    if (legs is! List || legs.isEmpty) return null;
    final result = <String>[];
    for (final leg in legs) {
      final steps = leg is Map ? leg["steps"] : null;
      if (steps is! List) return null;
      for (final step in steps) {
        final polyline = step is Map ? step["polyline"] : null;
        final encoded = polyline is Map ? polyline["points"] : null;
        if (encoded is! String) return null;
        result.add(encoded);
      }
    }
    return result.isEmpty ? null : result;
  }

  static String _redact(String text, String apiKey) {
    if (apiKey.isEmpty) return text;
    return text.replaceAll(Uri.encodeQueryComponent(apiKey), "***").replaceAll(apiKey, "***");
  }
}
