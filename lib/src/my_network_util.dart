import 'dart:async';
import 'dart:convert';

import 'package:google_maps_polyline/src/messages.dart';
import 'package:google_maps_polyline/src/point_latlng.dart';
import 'package:google_maps_polyline/src/polyline_codec.dart';
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
import 'package:google_maps_polyline/src/utils/result_polyline.dart';
import 'package:google_maps_polyline/src/utils/waypoint_polyline.dart';
import 'package:http/http.dart' as http;

/// Talks to the Google Directions API.
class MyNetworkUtil {
  /// HTTP client supplied by the caller. When `null`, a temporary client is
  /// created for each request and closed afterwards.
  final http.Client? client;

  /// Maximum duration of a single request.
  final Duration timeout;

  /// Language code sent to the API as `language` and used for the package's
  /// own messages (`tr` gives Turkish, anything else English).
  final String language;

  final PolylineMessages _messages;

  MyNetworkUtil({this.client, this.timeout = const Duration(seconds: 15), this.language = 'en'})
      : _messages = PolylineMessages.forLanguage(language);

  /// Fetches the route between two points from the Google Directions API.
  ///
  /// Never throws; on failure [ResultPolyline.status] and
  /// [ResultPolyline.errorMessage] are filled in. The API key never appears in
  /// error messages.
  ///
  /// When [detailedPolyline] is `true`, the route is built by joining every
  /// step polyline (`legs[].steps[].polyline`) instead of the simplified
  /// `overview_polyline`, so it follows the road closely at high zoom.
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
      return ResultPolyline(status: ResultPolyline.statusError, errorMessage: _messages.invalidCoordinates);
    }
    final uri = buildUri(googleApiKey, origin, destination, travelMode, wayPoints, avoidHighways, avoidTolls,
        avoidFerries, optimizeWaypoints);

    final activeClient = client ?? http.Client();
    final http.Response response;
    try {
      response = await activeClient.get(uri).timeout(timeout);
    } on TimeoutException {
      return ResultPolyline(status: ResultPolyline.statusError, errorMessage: _messages.timeout(timeout));
    } on http.ClientException catch (e) {
      // `toString` also contains the request URL; only the message is kept.
      return ResultPolyline(
          status: ResultPolyline.statusError, errorMessage: _redact(_messages.network(e.message), googleApiKey));
    } on Exception catch (e) {
      return ResultPolyline(
          status: ResultPolyline.statusError, errorMessage: _redact(_messages.network("$e"), googleApiKey));
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
              response.statusCode == 200 ? _messages.unreadableResponse : _messages.http(response.statusCode));
    }

    final status = body["status"] is String ? body["status"] as String : null;
    if (response.statusCode != 200 && status == null) {
      return ResultPolyline(status: ResultPolyline.statusError, errorMessage: _messages.http(response.statusCode));
    }

    if (status == "OK") {
      try {
        final points = _routePoints(body["routes"], detailedPolyline);
        if (points == null) {
          return ResultPolyline(status: "ZERO_RESULTS", errorMessage: _messages.status("ZERO_RESULTS"));
        }
        return ResultPolyline(status: status, points: points);
      } on FormatException catch (e) {
        return ResultPolyline(status: ResultPolyline.statusError, errorMessage: _messages.polyline(e.message));
      }
    }

    final apiMessage = body["error_message"] is String ? body["error_message"] as String : null;
    return ResultPolyline(
        status: status ?? ResultPolyline.statusError,
        errorMessage: _redact(apiMessage ?? _messages.status(status) ?? _messages.unknownStatus(status), googleApiKey));
  }

  /// Builds the Directions API request URL. All values are encoded by [Uri].
  /// Throws [ArgumentError] for non-finite (NaN, infinite) coordinates.
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
    if (!_isFinite(origin)) throw ArgumentError.value(origin, 'origin', 'Non-finite coordinate');
    if (!_isFinite(destination)) throw ArgumentError.value(destination, 'destination', 'Non-finite coordinate');
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
      if (language.isNotEmpty) "language": language,
      "key": googleApiKey,
    };
    return Uri.https("maps.googleapis.com", "maps/api/directions/json", params);
  }

  /// Formats a point as the `lat,lng` string the API expects.
  ///
  /// `double.toString` writes small values in exponent form such as `1e-7`,
  /// which the API rejects, so fixed notation with at most 7 decimals is used.
  static String formatLatLng(MyPointLatLng point) =>
      "${_formatDegrees(point.latitude)},${_formatDegrees(point.longitude)}";

  static String _formatDegrees(double value) {
    var text = value.toStringAsFixed(7);
    text = text.replaceFirst(RegExp(r'\.?0+$'), '');
    return text == '-0' ? '0' : text;
  }

  static bool _isFinite(MyPointLatLng p) => p.latitude.isFinite && p.longitude.isFinite;

  /// Returns the points of the first route, or `null` if there is none.
  /// When [detailed], joins the step polylines and falls back to
  /// `overview_polyline` if the steps cannot be read.
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
          // Consecutive steps share their joining point; skip the duplicate.
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
