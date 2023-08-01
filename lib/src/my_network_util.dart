import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_polyline/src/point_latlng.dart';
import 'package:google_maps_polyline/src/utils/my_request_enums.dart';
import 'package:google_maps_polyline/src/utils/result_polyline.dart';
import 'package:google_maps_polyline/src/utils/waypoint_polyline.dart';
import 'package:http/http.dart' as http;

import 'dart:math' as math show pow;

class MyNetworkUtil {
  static const String sTATUSOK = "ok";

  ///Get the encoded string from google directions api
  ///
  Future<ResultPolyline> getRouteBetweenCoordinates(String googleApiKey, MyPointLatLng origin, MyPointLatLng destination, MyTravelMode travelMode, List<WayPointPolyline> wayPoints, bool avoidHighways,
      bool avoidTolls, bool avoidFerries, bool optimizeWaypoints) async {
    String mode = travelMode.toString().replaceAll('TravelMode.', '');
    ResultPolyline result = ResultPolyline();
    var params = {
      "origin": "${origin.latitude},${origin.longitude}",
      "destination": "${destination.latitude},${destination.longitude}",
      "mode": mode,
      "avoidHighways": "$avoidHighways",
      "avoidFerries": "$avoidFerries",
      "avoidTolls": "$avoidTolls",
      "key": googleApiKey
    };
    if (wayPoints.isNotEmpty) {
      List wayPointsArray = [];
      for (var point in wayPoints) {
        wayPointsArray.add(point.location);
      }
      String wayPointsString = wayPointsArray.join('|');
      if (optimizeWaypoints) {
        wayPointsString = 'optimize:true|$wayPointsString';
      }
      params.addAll({"waypoints": wayPointsString});
    }
    Uri uri = Uri.https("maps.googleapis.com", "maps/api/directions/json", params);

    try {
      var response = await http.get(uri);
      if (response.statusCode == 200) {
        var parsedJson = json.decode(response.body);
        result.status = parsedJson["status"];
        if (parsedJson["status"]?.toLowerCase() == sTATUSOK && parsedJson["routes"] != null && parsedJson["routes"].isNotEmpty) {
          result.points = decodePolyline(parsedJson["routes"][0]["overview_polyline"]["points"]).cast<MyPointLatLng>();
        } else {
          result.errorMessage = parsedJson["error_message"];
        }
      }
    } on Exception catch (e) {
      debugPrint("Hata getRouteBetweenCoordinates : $e");
      return ResultPolyline(status: "error", errorMessage: e.toString());
    }

    return result;
  }

  List<MyPointLatLng> decodeEncodedPolyline(String encoded) {
    List<MyPointLatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;
      MyPointLatLng p = MyPointLatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble());
      poly.add(p);
    }
    return poly;
  }

  List<MyPointLatLng> decodePolyline(String polyline, {int accuracyExponent = 5}) {
    final accuracyMultiplier = math.pow(10, accuracyExponent);

    List<MyPointLatLng> coordinates = [];

    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polyline.length) {
      int char;
      int shift = 0;
      int result = 0;

      /// Method for getting **only** `1` coorditane `latitude` or `longitude` at a time
      int getCoordinate() {
        /// Iterating while value is grater or equal of `32-bits` size
        do {
          /// Substract `63` from `codeUnit`.
          char = polyline.codeUnitAt(index++) - 63;

          /// `AND` each `char` with `0x1f` to get 5-bit chunks.
          /// Then `OR` each `char` with `result`.
          /// Then left-shift for `shift` bits
          result |= (char & 0x1f) << shift;
          shift += 5;
        } while (char >= 0x20);

        /// Inversion of both:
        ///
        ///  * Left-shift the `value` for one bit
        ///  * Inversion `value` if it is negative
        final value = result >> 1;
        final coordinateChange = (result & 1) != 0 ? (~BigInt.from(value)).toInt() : value;

        /// It is needed to clear `shift` and `result` for next coordinate.
        shift = result = 0;

        return coordinateChange;
      }

      lat += getCoordinate();
      lng += getCoordinate();

      /// coordinates.add([lat / accuracyMultiplier, lng / accuracyMultiplier]);
      coordinates.add(MyPointLatLng(lat / accuracyMultiplier, lng / accuracyMultiplier));
    }

    return coordinates;
  }
}
