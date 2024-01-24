import 'dart:convert';
import 'dart:math';

import 'package:google_maps_flutter_platform_interface/google_maps_flutter_platform_interface.dart';
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
    Response response;
    try {
      response = await post(uri,
          headers: {
            'Content-Type': 'application/json',
            "X-Goog-Api-Key": API_KEY,
          },
          body: body.toString());
    } catch (e) {
      return RouteResult(errorMessage: e.toString());
    }

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
        //bounds = _boundsFromMap(parsedJson["routes"][0]["bounds"]);
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

  /// Encodes the given [latitude, longitude] coordinates list to an encoded string.
  /// @encode_poly Function
  /// @param {List<LatLng>} coordinates
  /// @param {int} precision
  /// @returns {String}
  static String encodePolyline(List<LatLng> points, {int precision = 5}) {
    if (points.isEmpty) {
      return '';
    }

    var factor = pow(10, precision).toInt();

    StringBuffer output = StringBuffer();
    output.write(_encode(points[0].latitude, 0, factor));
    output.write(_encode(points[0].longitude, 0, factor));
    LatLng a, b;
    for (var i = 1; i < points.length; i++) {
      a = points[i];
      b = points[i - 1];
      output.write(_encode(a.latitude, b.latitude, factor));
      output.write(_encode(a.longitude, b.longitude, factor));
    }

    return output.toString();
  }

  /// Returns the character string
  /// @param {double} current
  /// @param {double} previous
  /// @param {int} factor
  /// @returns {String}
  static StringBuffer _encode(double current, double previous, int factor) {
    final _current = (current * factor).round();
    final _previous = (previous * factor).round();

    var coordinate = _current - _previous;
    coordinate <<= 1;
    if (_current - _previous < 0) {
      coordinate = ~coordinate;
    }

    var output = StringBuffer();
    while (coordinate >= 0x20) {
      output.writeCharCode((0x20 | (coordinate & 0x1f)) + 63);
      coordinate >>= 5;
    }
    output.writeCharCode(coordinate + 63);
    return output;
  }

  static LatLngBounds? _boundsFromMap(Object? json) {
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
