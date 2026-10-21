import 'package:google_maps_polyline/src/point_latlng.dart';

/// Result of a Directions API route request.
class ResultPolyline {
  /// Status used for network, timeout and response parsing failures.
  static const String statusError = "error";

  /// Request status.
  ///
  /// The value returned by the Directions API (`OK`, `ZERO_RESULTS`,
  /// `NOT_FOUND`, `OVER_QUERY_LIMIT`, `REQUEST_DENIED`, `INVALID_REQUEST`,
  /// `MAX_WAYPOINTS_EXCEEDED`, `MAX_ROUTE_LENGTH_EXCEEDED`, `UNKNOWN_ERROR`).
  /// [statusError] if the request did not reach the API or the response could
  /// not be read.
  String? status;

  /// Decoded route points.
  List<MyPointLatLng> points;

  /// Error message, if any. The API key is never included.
  String? errorMessage;

  ResultPolyline({this.status, this.points = const [], this.errorMessage = ""});

  /// `true` if a route was returned.
  bool get isSuccess => status == "OK";
}
