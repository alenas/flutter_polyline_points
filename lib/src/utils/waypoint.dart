import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Encapsulates a waypoint. Waypoints mark both the beginning and end of a route, and include intermediate stops along the route.
/// https://developers.google.com/maps/documentation/routes/reference/rest/v2/Waypoint
class Waypoint {
  /// the location of the waypoint,
  Location location;

  bool vehicleStopover = false;
  bool sideOfRoad = false;

  Waypoint(this.location);

  Waypoint.latLng(LatLng latLng) : this(Location(latLng));

  Waypoint.location(double latitude, double longitude) : this.latLng(LatLng(latitude, longitude));

  Object toJson() {
    return {"location", location.toJson()};
  }
}

/// Encapsulates a location (a geographic point, and an optional heading).
/// https://developers.google.com/maps/documentation/routes/reference/rest/v2/Location
class Location {
  /// Geographic coordinates
  LatLng latLng;

  /// The compass heading associated with the direction of the flow of traffic
  int? heading;

  Location(this.latLng, {this.heading});

  Object toJson() {
    Set<Object> result = Set();
    result = {"latLng", latLng.toJson()};
    if (heading != null) {
      result.add({"heading", heading!});
    }
    return result;
  }
}
