/// WayPointPolyline sınıfı, rota üzerindeki ara noktayı temsil eder.
class WayPointPolyline {
  /// Ara noktanın konumu: `"enlem,boylam"`, adres veya `place_id:...`.
  String location;

  /// `false` ise nokta durak olarak değil, yalnızca geçiş noktası (`via:`)
  /// olarak kullanılır.
  bool stopOver;

  WayPointPolyline({required this.location, this.stopOver = true});

  @override
  String toString() {
    if (stopOver) {
      return location;
    } else {
      return "via:$location";
    }
  }
}
