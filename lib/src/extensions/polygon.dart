import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
// import 'package:point_in_polygon/point_in_polygon.dart';
import 'package:power_geojson/power_geojson.dart';

extension ListABC<T> on List<T> {
  /// Returns the first element that matches the test; if none is found, it returns null.
  T? firstWhereOrNull(bool Function(T) test) {
    var first = where(test);
    return first.isEmpty ? null : first.first;
  }
}

extension PolygonX on Polygon {
  /// Determines whether a point resides within a polygon.
  bool isGeoPointInPolygon(LatLng latlng) {
    var isInPolygon = false;
    for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
      if ((((points[i].latitude <= latlng.latitude) &&
                  (latlng.latitude < points[j].latitude)) ||
              ((points[j].latitude <= latlng.latitude) &&
                  (latlng.latitude < points[i].latitude))) &&
          (latlng.longitude <
              (points[j].longitude - points[i].longitude) *
                      (latlng.latitude - points[i].latitude) /
                      (points[j].latitude - points[i].latitude) +
                  points[i].longitude)) isInPolygon = !isInPolygon;
    }
    return isInPolygon;
  }

  /// Determines whether a point resides within a polygon.
  bool isGeoPointInsidePolygon(LatLng position) {
    /// Check if the point sits exactly on a vertex
    /// var vertexPosition = points.firstWhere((point) => point == position, orElse: () => null);
    LatLng? vertexPosition =
        points.firstWhereOrNull((point) => point == position);
    if (vertexPosition != null) {
      return true;
    }

    // Check if the point is inside the polygon or on the boundary
    int intersections = 0;
    var verticesCount = points.length;

    for (int i = 1; i < verticesCount; i++) {
      LatLng vertex1 = points[i - 1];
      LatLng vertex2 = points[i];

      if (vertex1.latitude == vertex2.latitude &&
          vertex1.latitude == position.latitude &&
          position.longitude > min(vertex1.longitude, vertex2.longitude) &&
          position.longitude < max(vertex1.longitude, vertex2.longitude)) {
        return true;
      }

      if (position.latitude > min(vertex1.latitude, vertex2.latitude) &&
          position.latitude <= max(vertex1.latitude, vertex2.latitude) &&
          position.longitude <= max(vertex1.longitude, vertex2.longitude) &&
          vertex1.latitude != vertex2.latitude) {
        var xinters = (position.latitude - vertex1.latitude) *
                (vertex2.longitude - vertex1.longitude) /
                (vertex2.latitude - vertex1.latitude) +
            vertex1.longitude;
        if (xinters == position.longitude) {
          return true;
        }
        if (vertex1.longitude == vertex2.longitude ||
            position.longitude <= xinters) {
          intersections++;
        }
      }
    }
    return intersections % 2 != 0;
  }
}

extension PolygonsXX on List<List<List<double>>> {
  /// Converts a list coords of a Polygon into a [Polygon]
  Polygon toPolygon(
      {PolygonProperties polygonProperties = const PolygonProperties()}) {
    var holes = sublist(1).map((f) => f.toLatLng()).toList();
    var polygon = Polygon(
      points: first.toLatLng(),
      holePointsList: holes,
      color: polygonProperties.fillColor,
      isFilled: polygonProperties.isFilled,
      borderColor: polygonProperties.borderColor,
      borderStrokeWidth: polygonProperties.borderStokeWidth,
      disableHolesBorder: polygonProperties.disableHolesBorder,
      label: polygonProperties.label,
      isDotted: polygonProperties.isDotted,
      labelPlacement: polygonProperties.labelPlacement,
      labelStyle: polygonProperties.labelStyle,
      rotateLabel: polygonProperties.rotateLabel,
      strokeCap: polygonProperties.strokeCap,
      strokeJoin: polygonProperties.strokeJoin,
    );
    // consoleLog(polygon.area(), color: 35);
    return polygon;
  }
}
