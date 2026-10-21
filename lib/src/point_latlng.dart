/// A geographic point in degrees.
class MyPointLatLng {
  /// Latitude in degrees.
  final double latitude;

  /// Longitude in degrees.
  final double longitude;

  const MyPointLatLng(this.latitude, this.longitude);

  @override
  bool operator ==(Object other) =>
      other is MyPointLatLng && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);

  @override
  String toString() => "MyPointLatLng($latitude, $longitude)";
}
