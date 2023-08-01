// point_latlng.dart
// MyPointLatLng sınıfı, enlem ve boylamı temsil eder.
class MyPointLatLng {
  // Enlem değeri (latitude) derece cinsinden.
  final double? latitude;

  // Boylam değeri (longitude) derece cinsinden.
  final double? longitude;

  MyPointLatLng(this.latitude, this.longitude);

  @override
  String toString() {
    return "enlem: $latitude / boylam: $longitude";
  }
}
