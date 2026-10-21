/// An intermediate point on a route.
class WayPointPolyline {
  /// Location of the waypoint: `"lat,lng"`, an address or `place_id:...`.
  String location;

  /// When `false`, the route passes through the point without stopping
  /// (sent with the `via:` prefix).
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
