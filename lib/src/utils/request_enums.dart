/// description:
/// project: flutter_polyline_points

/// Specify mode of travel. default is drive
enum RouteTravelMode {
  DRIVE,
  BICYCLE,
  WALK,
  TWO_WHEELER,
  TRANSIT,
}

/// Specify the quality of the polyline. Default is overview.
enum PolylineQuality {
  HIGH_QUALITY,
  OVERVIEW,
}

/// Specifies the preferred type of polyline to be returned.
enum PolylineEncoding {
  ENCODED_POLYLINE,
  GEO_JSON_LINESTRING,
}

// A set of values that specify the unit of measure used in the display
enum Units {
  METRIC,
  IMPERIAL,
}

/// A supported reference route on the ComputeRoutesRequest.
enum ReferenceRoute {
  FUEL_EFFICIENT,
}

/// Extra computations to perform while completing the request.
enum ExtraComputation {
  TOLLS,
  FUEL_CONSUMPTION,
  TRAFFIC_ON_POLYLINE,
  HTML_FORMATTED_NAVIGATION_INSTRUCTIONS,
}
