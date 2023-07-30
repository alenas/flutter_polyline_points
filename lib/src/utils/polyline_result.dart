import 'package:google_maps_flutter/google_maps_flutter.dart';

/// description:
/// project: flutter_polyline_points
/// @package:
/// @author: dammyololade
/// created on: 13/05/2020
class PolylineResult {
  /// the api status retuned from google api
  ///
  /// returns OK if the api call is successful
  final bool isSuccess;

  /// list of decoded points
  final List<LatLng> points;

  final LatLngBounds? bounds;

  /// the error message returned from google, if none, the result will be empty
  final String errorMessage;

  PolylineResult({this.isSuccess = false, this.points = const [], this.bounds, this.errorMessage = ""});
}
