import 'package:flutter_polyline_points/src/utils/polyline_result.dart';
import 'package:flutter_polyline_points/src/utils/polyline_waypoint.dart';
import 'package:flutter_polyline_points/src/utils/request_enums.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'network_util.dart';

class Directions {
  /// Get the list of coordinates between two geographical positions
  /// which can be used to draw polyline between this two positions
  ///
  static Future<PolylineResult> getRouteBetweenCoordinates(String googleApiKey, LatLng origin, LatLng destination,
      {TravelMode travelMode = TravelMode.driving,
      List<PolylineWayPoint> wayPoints = const [],
      bool avoidHighways = false,
      bool avoidTolls = false,
      bool avoidFerries = true,
      bool optimizeWaypoints = false}) async {
    return await NetworkUtil.getRouteBetweenCoordinates(
        googleApiKey, origin, destination, travelMode, wayPoints, avoidHighways, avoidTolls, avoidFerries, optimizeWaypoints);
  }

  /// Decode and encoded google polyline
  /// e.g "_p~iF~ps|U_ulLnnqC_mqNvxq`@"
  ///
  static List<LatLng> decodePolyline(String encodedString) {
    return NetworkUtil.decodeEncodedPolyline(encodedString);
  }
}
