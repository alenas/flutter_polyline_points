import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() {
  test('get list of coordinates from two geographical positions', () async {
    PolylineResult result =
        await Directions.getRouteBetweenCoordinates('API_KEY', LatLng(6.5212402, 3.3679965), LatLng(6.595680, 3.337030), travelMode: TravelMode.driving);
    assert(result.points.isNotEmpty == true);
  });

  test('get list of coordinates from an encoded String', () {
    print("Writing a test is very easy");
    List<LatLng> points = Directions.decodePolyline("_p~iF~ps|U_ulLnnqC_mqNvxq`@");
    print("Answer ---- ");
    print(points);
    assert(points.length > 0);
  });
}
