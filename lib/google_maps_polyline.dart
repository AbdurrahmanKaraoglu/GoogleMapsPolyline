/// Fetch routes from the Google Directions API and decode/encode Google
/// encoded polylines.
library;

import 'package:google_maps_polyline/src/my_network_util.dart';
import 'package:google_maps_polyline/src/point_latlng.dart';
import 'package:google_maps_polyline/src/polyline_codec.dart';
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
import 'package:google_maps_polyline/src/utils/result_polyline.dart';
import 'package:google_maps_polyline/src/utils/waypoint_polyline.dart';
import 'package:http/http.dart' as http;

export 'package:google_maps_polyline/src/point_latlng.dart';
export 'package:google_maps_polyline/src/polyline_codec.dart';
export 'package:google_maps_polyline/src/utils/my_request_enums.dart';
export 'package:google_maps_polyline/src/utils/result_polyline.dart';
export 'package:google_maps_polyline/src/utils/waypoint_polyline.dart';

/// Entry point for fetching routes and decoding/encoding polylines.
class GoogleMapsPolyline {
  /// Helper that performs the network requests.
  final MyNetworkUtil util;

  /// If [client] is given, requests use it (for tests or custom
  /// configuration) and the caller is responsible for closing it.
  /// [timeout] is the maximum duration of a single request.
  ///
  /// [language] is sent to the Directions API (so its own `error_message`
  /// comes back in that language) and selects the language of the package's
  /// messages: `tr` gives Turkish, anything else English.
  GoogleMapsPolyline({http.Client? client, Duration timeout = const Duration(seconds: 15), String language = 'en'})
      : util = MyNetworkUtil(client: client, timeout: timeout, language: language);

  /// Fetches the route between [origin] and [destination] from the Google
  /// Directions API.
  ///
  /// - [googleApiKey]: API key with access to the Directions API.
  /// - [travelMode]: travel mode (default: driving).
  /// - [wayPoints]: intermediate points (default: none).
  /// - [avoidHighways], [avoidTolls], [avoidFerries]: route restrictions
  ///   (defaults: false, false, true).
  /// - [optimizeWaypoints]: let the API reorder the waypoints (default: false).
  /// - [detailedPolyline]: return the step-by-step route instead of the
  ///   simplified `overview_polyline` (default: false).
  ///
  /// Never throws; on failure [ResultPolyline.isSuccess] is `false`.
  Future<ResultPolyline> getRouteBetweenCoordinates(
      String googleApiKey, MyPointLatLng origin, MyPointLatLng destination,
      {MyTravelMode travelMode = MyTravelMode.driving,
      List<WayPointPolyline> wayPoints = const [],
      bool avoidHighways = false,
      bool avoidTolls = false,
      bool avoidFerries = true,
      bool optimizeWaypoints = false,
      bool detailedPolyline = false}) {
    return util.getRouteBetweenCoordinates(googleApiKey, origin, destination, travelMode, wayPoints, avoidHighways,
        avoidTolls, avoidFerries, optimizeWaypoints,
        detailedPolyline: detailedPolyline);
  }

  /// Decodes a Google encoded polyline, e.g. "_p~iF~ps|U_ulLnnqC_mqNvxq`@".
  ///
  /// Throws [FormatException] for invalid input.
  List<MyPointLatLng> decodePolyline(String encodedString, {int precision = 5}) {
    return PolylineCodec.decode(encodedString, precision: precision);
  }

  /// Encodes a list of points as a Google encoded polyline.
  String encodePolyline(List<MyPointLatLng> points, {int precision = 5}) {
    return PolylineCodec.encode(points, precision: precision);
  }
}
