import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:flutter_polyline_points/flutter_polyline_points.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polyline example',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.orange,
      ),
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;

  var origin = LatLng(26.48424, 50.04551);
  var destination = LatLng(26.46423, 50.06358);

  Map<MarkerId, Marker> markers = {};
  Map<PolylineId, Polyline> polylines = {};
  String googleAPiKey = const String.fromEnvironment("API_KEY", defaultValue: "");

  @override
  void initState() {
    super.initState();

    /// origin marker
    _addMarker(origin, "origin", BitmapDescriptor.defaultMarker);

    /// destination marker
    _addMarker(destination, "destination", BitmapDescriptor.defaultMarkerWithHue(90));

    _getPolyline();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          body: GoogleMap(
        initialCameraPosition: CameraPosition(target: origin, zoom: 15),
        myLocationEnabled: true,
        tiltGesturesEnabled: true,
        compassEnabled: true,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        onMapCreated: _onMapCreated,
        markers: Set<Marker>.of(markers.values),
        polylines: Set<Polyline>.of(polylines.values),
      )),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    mapController = controller;
  }

  _addMarker(LatLng position, String id, BitmapDescriptor descriptor) {
    MarkerId markerId = MarkerId(id);
    Marker marker = Marker(markerId: markerId, icon: descriptor, position: position);
    //setState(() {
    markers[markerId] = marker;
    //});
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    var id = PolylineId("poly");
    var polyline = Polyline(polylineId: id, color: Colors.red, points: polylineCoordinates);
    //setState(() {
    polylines[id] = polyline;
    //});
  }

  _getPolyline() async {
    Directions(googleAPiKey);
    RouteResult result = await Directions.getRouteBetweenCoordinates(origin, destination);
    if (result.points.isNotEmpty) {
      _addPolyLine(result.points);
    } else {
      debugPrint("Empty result!");
    }
  }
}
