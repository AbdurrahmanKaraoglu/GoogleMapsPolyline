import 'dart:math' as math show pow;

import 'package:google_maps_polyline/src/point_latlng.dart';

/// Decoder and encoder for Google's Encoded Polyline Algorithm Format.
///
/// See https://developers.google.com/maps/documentation/utilities/polylinealgorithm
class PolylineCodec {
  PolylineCodec._();

  /// Decodes an encoded polyline into a list of points.
  ///
  /// [precision] is the number of decimal places: 5 for the Google
  /// Directions/Routes APIs, 6 for some services (e.g. OSRM `polyline6`).
  ///
  /// Throws [FormatException] if the string is truncated or contains invalid
  /// characters.
  static List<MyPointLatLng> decode(String encoded, {int precision = 5}) {
    _checkPrecision(precision);
    final factor = math.pow(10, precision);
    final points = <MyPointLatLng>[];
    var index = 0;
    var lat = 0;
    var lng = 0;

    int nextValue() {
      var result = 0;
      var shift = 0;
      int chunk;
      do {
        if (index >= encoded.length) {
          throw FormatException('Unexpected end of polyline', encoded, index);
        }
        if (shift > 30) {
          throw FormatException('Polyline value is too large', encoded, index);
        }
        chunk = encoded.codeUnitAt(index) - 63;
        if (chunk < 0 || chunk > 63) {
          throw FormatException('Invalid polyline character', encoded, index);
        }
        index++;
        result |= (chunk & 0x1f) << shift;
        shift += 5;
      } while (chunk >= 0x20);
      // The lowest bit carries the sign: if set, the value is negative and inverted.
      return (result & 1) != 0 ? ~(result >> 1) : result >> 1;
    }

    while (index < encoded.length) {
      lat += nextValue();
      lng += nextValue();
      points.add(MyPointLatLng(lat / factor, lng / factor));
    }
    return points;
  }

  /// Encodes a list of points as a polyline string.
  static String encode(List<MyPointLatLng> points, {int precision = 5}) {
    _checkPrecision(precision);
    final factor = math.pow(10, precision);
    final buffer = StringBuffer();
    var prevLat = 0;
    var prevLng = 0;
    for (final point in points) {
      final lat = (point.latitude * factor).round();
      final lng = (point.longitude * factor).round();
      _encodeValue(lat - prevLat, buffer);
      _encodeValue(lng - prevLng, buffer);
      prevLat = lat;
      prevLng = lng;
    }
    return buffer.toString();
  }

  static void _encodeValue(int value, StringBuffer buffer) {
    var v = value < 0 ? ~(value << 1) : value << 1;
    while (v >= 0x20) {
      buffer.writeCharCode((0x20 | (v & 0x1f)) + 63);
      v >>= 5;
    }
    buffer.writeCharCode(v + 63);
  }

  static void _checkPrecision(int precision) {
    RangeError.checkValueInInterval(precision, 0, 6, 'precision');
  }
}
