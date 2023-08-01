import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  group("Route service tests", () {
    test('get route between two positions', () async {
      RouteResult result = await Directions.getRouteBetweenCoordinates(LatLng(6.5212402, 3.3679965), LatLng(6.595680, 3.337030));
      assert(result.isSuccess);
      assert(result.points.isNotEmpty);
      // assert(result.bounds != null);
      // for (var l in result.points) {
      //   assert(result.bounds!.contains(l));
      // }
      assert(result.duration != 0);
      assert(result.distance != 0);
      assert(result.summary.isNotEmpty);
      assert(result.errorMessage.isEmpty);
    });

    test('error without api key', () async {
      RouteResult result = await Directions.getRouteBetweenCoordinates(LatLng(6.5212402, 3.3679965), LatLng(6.595680, 3.337030));
      assert(result.isSuccess == false);
      assert(result.points.isEmpty);
      //assert(result.bounds == null);
      assert(result.duration == 0);
      assert(result.distance == 0);
      assert(result.summary.isEmpty);
      assert(result.errorMessage.isNotEmpty);
    });
  });

  test('get list of coordinates from an encoded String', () {
    List<LatLng> points = Directions.decodePolyline("_p~iF~ps|U_ulLnnqC_mqNvxq`@");
    assert(points.length == 3);
    assert(points[0].latitude == 38.5 && points[0].longitude == -120.2);
    assert(points[1].latitude == 40.7 && points[1].longitude == -120.95);
    assert(points[2].latitude == 43.252 && points[2].longitude == -126.453);
  });
}
