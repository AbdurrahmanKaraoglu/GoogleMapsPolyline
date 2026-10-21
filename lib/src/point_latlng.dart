/// point_latlng.dart
/// MyPointLatLng sınıfı, enlem ve boylamı temsil eder.
class MyPointLatLng {
  /// Enlem değeri (latitude) derece cinsinden.
  final double latitude;

  /// Boylam değeri (longitude) derece cinsinden.
  final double longitude;

  const MyPointLatLng(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      other is MyPointLatLng && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() {
    return "enlem: $latitude / boylam: $longitude";
  }
}
