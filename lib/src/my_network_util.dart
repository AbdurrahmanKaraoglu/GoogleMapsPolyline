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
  Future<ResultPolyline> getRouteBetweenCoordinates(
      String googleApiKey,
      MyPointLatLng origin,
      MyPointLatLng destination,
      MyTravelMode travelMode,
      List<WayPointPolyline> wayPoints,
      bool avoidHighways,
      bool avoidTolls,
      bool avoidFerries,
      bool optimizeWaypoints) async {
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
      final encoded = _overviewPolyline(body["routes"]);
      if (encoded == null) {
        return ResultPolyline(status: "ZERO_RESULTS", errorMessage: _statusMessages["ZERO_RESULTS"]);
      }
      try {
        return ResultPolyline(status: status, points: PolylineCodec.decode(encoded));
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
  /// kodlanır.
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
    final avoid = [
      if (avoidHighways) "highways",
      if (avoidTolls) "tolls",
      if (avoidFerries) "ferries",
    ];
    final params = <String, String>{
      "origin": "${origin.latitude},${origin.longitude}",
      "destination": "${destination.latitude},${destination.longitude}",
      "mode": travelMode.name,
      if (avoid.isNotEmpty) "avoid": avoid.join('|'),
      if (wayPoints.isNotEmpty)
        "waypoints": [if (optimizeWaypoints) "optimize:true", ...wayPoints.map((p) => p.toString())].join('|'),
      "key": googleApiKey,
    };
    return Uri.https("maps.googleapis.com", "maps/api/directions/json", params);
  }

  static String? _overviewPolyline(Object? routes) {
    if (routes is! List || routes.isEmpty) return null;
    final route = routes.first;
    if (route is! Map) return null;
    final overview = route["overview_polyline"];
    if (overview is! Map) return null;
    final points = overview["points"];
    return points is String ? points : null;
  }

  static String _redact(String text, String apiKey) {
    if (apiKey.isEmpty) return text;
    return text.replaceAll(Uri.encodeQueryComponent(apiKey), "***").replaceAll(apiKey, "***");
  }
}
