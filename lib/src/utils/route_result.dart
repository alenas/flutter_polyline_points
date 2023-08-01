import 'package:google_maps_flutter/google_maps_flutter.dart';

/// description:
/// project: flutter_polyline_points
/// @package:
/// @author: dammyololade
/// created on: 13/05/2020
class RouteResult {
  /// the api status retuned from google api
  final bool isSuccess;

  /// list of route points
  final List<LatLng> points;

  /// Bounds of points
  //final LatLngBounds? bounds;

  /// Route distance in meters
  final int distance;

  /// Route duration in seconds
  final int duration;

  /// Route summary
  final String summary;

  /// the error message returned from google
  final String errorMessage;

  RouteResult({this.isSuccess = false, this.points = const [], this.distance = 0, this.duration = 0, this.summary = "", this.errorMessage = ""});
}
