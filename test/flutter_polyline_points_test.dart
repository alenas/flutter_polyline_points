import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  test('get list of coordinates from two geographical positions', () async {
    PolylineResult result = await Directions.getRouteBetweenCoordinates('API_KEY', LatLng(6.5212402, 3.3679965), LatLng(6.595680, 3.337030));
    assert(result.isSuccess);
    assert(result.points.isNotEmpty == true);
    assert(result.bounds != null);
    assert(result.errorMessage.isEmpty);
  });

  test('get list of coordinates from an encoded String', () {
    List<LatLng> points = Directions.decodePolyline("_p~iF~ps|U_ulLnnqC_mqNvxq`@");
    assert(points.length == 3);
    assert(points[0].latitude == 38.5 && points[0].longitude == -120.2);
    assert(points[1].latitude == 40.7 && points[1].longitude == -120.95);
    assert(points[2].latitude == 43.252 && points[2].longitude == -126.453);
  });
}
