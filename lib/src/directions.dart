import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import '../src/utils/polyline_waypoint.dart';
import '../src/utils/request_enums.dart';
import 'utils/route_result.dart';

class Directions {
  static const String STATUS_OK = "ok";

  ///Get the encoded string from google directions api
  ///
  static Future<RouteResult> getRouteBetweenCoordinates(String googleApiKey, LatLng origin, LatLng destination,
      {TravelMode travelMode = TravelMode.driving,
      List<PolylineWayPoint> wayPoints = const [],
      bool avoidHighways = false,
      bool avoidTolls = false,
      bool avoidFerries = true,
      bool optimizeWaypoints = false}) async {
    String mode = travelMode.toString().replaceAll('TravelMode.', '');
    var params = {
      "origin": "${origin.latitude},${origin.longitude}",
      "destination": "${destination.latitude},${destination.longitude}",
      "mode": mode,
      "avoidHighways": "$avoidHighways",
      "avoidFerries": "$avoidFerries",
      "avoidTolls": "$avoidTolls",
      "key": googleApiKey
    };
    if (wayPoints.isNotEmpty) {
      List wayPointsArray = [];
      wayPoints.forEach((point) => wayPointsArray.add(point.location));
      String wayPointsString = wayPointsArray.join('|');
      if (optimizeWaypoints) {
        wayPointsString = 'optimize:true|$wayPointsString';
      }
      params.addAll({"waypoints": wayPointsString});
    }
    Uri uri = Uri.https("maps.googleapis.com", "maps/api/directions/json", params);

    Response response;
    try {
      response = await http.get(uri);
    } catch (e) {
      return RouteResult(errorMessage: e.toString());
    }
    var isSuccess = false;
    List<LatLng> points = [];
    LatLngBounds? bounds;
    var errorMessage = '';
    var distance = 0;
    var duration = 0;
    var summary = '';
    if (response.statusCode == 200) {
      var parsedJson = json.decode(response.body);
      isSuccess = parsedJson["status"]?.toLowerCase() == STATUS_OK;
      if (isSuccess && parsedJson["routes"] != null && parsedJson["routes"].isNotEmpty) {
        points = decodePolyline(parsedJson["routes"][0]["overview_polyline"]["points"]);
        bounds = boundsFromMap(parsedJson["routes"][0]["bounds"]);
        distance = parsedJson["routes"][0]["legs"][0]["distance"]["value"];
        duration = parsedJson["routes"][0]["legs"][0]["duration"]["value"];
        summary = parsedJson["routes"][0]["summary"];
      } else {
        errorMessage = parsedJson["error_message"];
      }
    }
    return RouteResult(
        isSuccess: isSuccess, points: points, bounds: bounds, distance: distance, duration: duration, summary: summary, errorMessage: errorMessage);
  }

  ///decode the google encoded string using Encoded Polyline Algorithm Format
  /// for more info about the algorithm check https://developers.google.com/maps/documentation/utilities/polylinealgorithm
  ///
  ///return [List] of [LatLng]
  static List<LatLng> decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    final big0 = BigInt.from(0);
    final big0x1f = BigInt.from(0x1f);
    final big0x20 = BigInt.from(0x20);

    while (index < len) {
      int shift = 0;
      BigInt b, result;
      result = big0;
      do {
        b = BigInt.from(encoded.codeUnitAt(index++) - 63);
        result |= (b & big0x1f) << shift;
        shift += 5;
      } while (b >= big0x20);
      BigInt rShifted = result >> 1;
      int dLat;
      if (result.isOdd)
        dLat = (~rShifted).toInt();
      else
        dLat = rShifted.toInt();
      lat += dLat;

      shift = 0;
      result = big0;
      do {
        b = BigInt.from(encoded.codeUnitAt(index++) - 63);
        result |= (b & big0x1f) << shift;
        shift += 5;
      } while (b >= big0x20);
      rShifted = result >> 1;
      int dLng;
      if (result.isOdd)
        dLng = (~rShifted).toInt();
      else
        dLng = rShifted.toInt();
      lng += dLng;

      poly.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
    }
    return poly;
  }

  static LatLngBounds? boundsFromMap(Object? json) {
    if (json == null) {
      return null;
    }
    assert(json is Map && json.length == 2);
    final list = json as Map<String, dynamic>;
    final first = LatLng(list["southwest"]["lat"], list["southwest"]["lng"]);
    final second = LatLng(list["northeast"]["lat"], list["northeast"]["lng"]);
    if (first.latitude <= second.latitude) {
      return LatLngBounds(
        southwest: first,
        northeast: second,
      );
    } else {
      return LatLngBounds(
        southwest: second,
        northeast: first,
      );
    }
  }
}
