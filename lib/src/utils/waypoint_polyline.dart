class WayPointPolyline {
  String location;

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
