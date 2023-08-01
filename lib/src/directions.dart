import 'dart:convert';

import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'utils/route_result.dart';

class Directions {
  static const String STATUS_OK = "ok";
  static late final String API_KEY;

  /// Sets Google API KEY
  Directions(String apiKey) {
    API_KEY = apiKey;
  }

  ///Get the encoded string from google directions api
  ///
  static Future<RouteResult> getRouteBetweenCoordinates(LatLng origin, LatLng destination) async {
    // {RouteTravelMode? travelMode = RouteTravelMode.DRIVE,
    // //List<Waypoint> intermediates = const [],
    // bool avoidHighways = false,
    // bool avoidTolls = false,
    // bool avoidFerries = true,
    // bool optimizeWaypoints = false}) async {
    //String mode = travelMode.toString().replaceAll('TravelMode.', '');
    var filter = {
      "fields": "routes.staticDuration,routes.distanceMeters,routes.description,routes.polyline.encodedPolyline",
    };
    // var params = {
    //   "origin": "${origin.latitude},${origin.longitude}",
    //   "destination": "${destination.latitude},${destination.longitude}",
    //   "mode": mode,
    //   "avoidHighways": "$avoidHighways",
    //   "avoidFerries": "$avoidFerries",
    //   "avoidTolls": "$avoidTolls",
    //   "key": API_KEY
    // };
    var body = {
      "origin": {
        "location": {
          "latLng": {"latitude": origin.latitude, "longitude": origin.longitude},
        }
      },
      "destination": {
        "location": {
          "latLng": {"latitude": destination.latitude, "longitude": destination.longitude},
        }
      },
      "routeModifiers": {"avoidFerries": true},
    };
    //print(body);
    /*
    {
  "origin": {
    object (Waypoint)
  },
  "destination": {
    object (Waypoint)
  },
  "intermediates": [
    {
      object (Waypoint)
    }
  ],
  "travelMode": enum (RouteTravelMode),
  "routingPreference": enum (RoutingPreference),
  "polylineQuality": enum (PolylineQuality),
  "polylineEncoding": enum (PolylineEncoding),
  "departureTime": string,
  "arrivalTime": string,
  "computeAlternativeRoutes": boolean,
  "routeModifiers": {
    object (RouteModifiers)
  },
  "languageCode": string,
  "regionCode": string,
  "units": enum (Units),
  "optimizeWaypointOrder": boolean,
  "requestedReferenceRoutes": [
    enum (ReferenceRoute)
  ],
  "extraComputations": [
    enum (ExtraComputation)
  ],
  "trafficModel": enum (TrafficModel),
  "transitPreferences": {
    object (TransitPreferences)
  }
}
*/
    // if (wayPoints.isNotEmpty) {
    //   List wayPointsArray = [];
    //   wayPoints.forEach((point) => wayPointsArray.add(point.location));
    //   String wayPointsString = wayPointsArray.join('|');
    //   if (optimizeWaypoints) {
    //     wayPointsString = 'optimize:true|$wayPointsString';
    //   }
    //   params.addAll({"waypoints": wayPointsString});
    // }
    Uri uri = Uri.https("routes.googleapis.com", "directions/v2:computeRoutes", filter);
    // var request = Request("post", uri);
    // request.headers.addEntries({'Content-Type': 'application/json'}.entries);
    // request.headers.addEntries({"X-Goog-Api-Key": API_KEY}.entries);

    Response response;
    try {
      response = await http.post(uri,
          headers: {
            //'Referer': 'https://calm-sea-0e45cbd10.1.azurestaticapps.net',
            'Content-Type': 'application/json',
            "X-Goog-Api-Key": API_KEY,
          },
          body: body.toString());
    } catch (e) {
      return RouteResult(errorMessage: e.toString());
    }
    //print(response.body);
    var isSuccess = false;
    List<LatLng> points = [];
    //LatLngBounds? bounds;
    var errorMessage = '';
    var distance = 0;
    String duration = "0";
    var summary = '';
    var parsedJson = json.decode(response.body);
    if (response.statusCode == 200) {
      isSuccess = true;
      //isSuccess = parsedJson["status"]?.toLowerCase() == STATUS_OK;
      if (parsedJson["routes"] != null && parsedJson["routes"].isNotEmpty) {
        points = decodePolyline(parsedJson["routes"][0]["polyline"]["encodedPolyline"]);
        //bounds = boundsFromMap(parsedJson["routes"][0]["bounds"]);
        distance = parsedJson["routes"][0]["distanceMeters"];
        duration = parsedJson["routes"][0]["staticDuration"];
        duration = duration.substring(0, duration.length - 1);
        summary = parsedJson["routes"][0]["description"];
      } else {
        errorMessage = parsedJson["error"]["message"];
      }
    } else {
      errorMessage = parsedJson["error"]["message"];
    }
    return RouteResult(isSuccess: isSuccess, points: points, distance: distance, duration: int.parse(duration), summary: summary, errorMessage: errorMessage);
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
