import 'dart:math';

import 'package:latlong2/latlong.dart';
import 'package:dart_jts/dart_jts.dart' as dart_jts;
import 'package:flutter_map/flutter_map.dart';
import 'package:point_in_polygon/point_in_polygon.dart';
import 'package:power_geojson/power_geojson.dart';

extension PolygonsX on List<Polygon> {
  List<Polygon> toBuffers(double radius, PolygonProperties polygonBufferProperties) {
    return map((e) => e.buffer(radius, polygonProperties: polygonBufferProperties)).toList();
  }

  List<Polygon> toBuffersWithOriginals(double radius, PolygonProperties polygonBufferProperties) {
    return map((e) => e.toBuffer(radius, polygonBufferProperties)).expand((e) => e).toList();
  }
}

extension PolygonX on Polygon {
  List<Polygon> toBuffer(double radius, PolygonProperties polygonProperties) {
    return [buffer(radius, polygonProperties: polygonProperties), this];
  }

  double area() {
    return dart_jts.Area.ofRing(
      points.toCoordinatesProjted(),
    );
  }

  Polygon buffer(double radius, {PolygonProperties? polygonProperties}) {
    var precesion = dart_jts.PrecisionModel.fixedPrecision(0);
    //
    var listCoordinate = points.toCoordinates();
    var listLinearRing = dart_jts.LinearRing(listCoordinate, precesion, 10);
    //
    List<dart_jts.LinearRing>? holesLineString = holePointsList!.map((pts) {
      var listCoordinates = pts.toCoordinates();
      return dart_jts.LinearRing(listCoordinates, precesion, 10);
    }).toList();
    // consoleLog(holesLineString.length);
    //
    final geometryFactory = dart_jts.GeometryFactory.defaultPrecision();
    final polygons = geometryFactory.createPolygon(listLinearRing, holesLineString);
    var distanceDMS = dmFromMeters(radius);
    final buffer = dart_jts.BufferOp.bufferOp3(polygons, distanceDMS, 10);
    var bufferBolygon = buffer as dart_jts.Polygon;
    var listPointsPolygon = bufferBolygon.shell!.points.toCoordinateArray().toLatLng();
    var polygon = Polygon(
      points: listPointsPolygon,
      holePointsList: holePointsList,
      isFilled: polygonProperties != null ? polygonProperties.isFilled : isFilled,
      color: polygonProperties != null ? polygonProperties.fillColor : color,
      borderColor: polygonProperties != null ? polygonProperties.borderColor : borderColor,
      borderStrokeWidth: polygonProperties != null ? polygonProperties.borderStokeWidth : borderStrokeWidth,
      disableHolesBorder: polygonProperties != null ? polygonProperties.disableHolesBorder : disableHolesBorder,
      isDotted: polygonProperties != null ? polygonProperties.isDotted : isDotted,
      label: polygonProperties != null ? polygonProperties.label : label,
      labelPlacement: polygonProperties != null ? polygonProperties.labelPlacement : labelPlacement,
      labelStyle: polygonProperties != null ? polygonProperties.labelStyle : labelStyle,
      rotateLabel: polygonProperties != null ? polygonProperties.rotateLabel : rotateLabel,
      strokeCap: polygonProperties != null ? polygonProperties.strokeCap : strokeCap,
      strokeJoin: polygonProperties != null ? polygonProperties.strokeJoin : strokeJoin,
    );
    return polygon;
  }

  bool isGeoPointInPolygon(LatLng latlng) {
    var isInPolygon = false;
    for (var i = 0, j = points.length - 1; i < points.length; j = i++) {
      if ((((points[i].latitude <= latlng.latitude) && (latlng.latitude < points[j].latitude)) || ((points[j].latitude <= latlng.latitude) && (latlng.latitude < points[i].latitude))) && (latlng.longitude < (points[j].longitude - points[i].longitude) * (latlng.latitude - points[i].latitude) / (points[j].latitude - points[i].latitude) + points[i].longitude)) isInPolygon = !isInPolygon;
    }
    return isInPolygon;
  }

  bool isIntersectedWithPoint(LatLng latlng) {
    var currPoint = Point(
      x: latlng.latitude,
      y: latlng.longitude,
    );
    var pInP = Poly.isPointInPolygon(
      currPoint,
      points.map((e) {
        return Point(
          x: e.latitude,
          y: e.longitude,
        );
      }).toList(),
    );
    return pInP;
  }

  bool isGeoPointInsidePolygon(LatLng position) {
    // Check if the point sits exactly on a vertex
    // var vertexPosition = points.firstWhere((point) => point == position, orElse: () => null);
    LatLng? vertexPosition = points.firstWhereOrNull((point) => point == position);
    if (vertexPosition != null) {
      return true;
    }

    // Check if the point is inside the polygon or on the boundary
    int intersections = 0;
    var verticesCount = points.length;

    for (int i = 1; i < verticesCount; i++) {
      LatLng vertex1 = points[i - 1];
      LatLng vertex2 = points[i];

      if (vertex1.latitude == vertex2.latitude && vertex1.latitude == position.latitude && position.longitude > min(vertex1.longitude, vertex2.longitude) && position.longitude < max(vertex1.longitude, vertex2.longitude)) {
        return true;
      }

      if (position.latitude > min(vertex1.latitude, vertex2.latitude) && position.latitude <= max(vertex1.latitude, vertex2.latitude) && position.longitude <= max(vertex1.longitude, vertex2.longitude) && vertex1.latitude != vertex2.latitude) {
        var xinters = (position.latitude - vertex1.latitude) * (vertex2.longitude - vertex1.longitude) / (vertex2.latitude - vertex1.latitude) + vertex1.longitude;
        if (xinters == position.longitude) {
          return true;
        }
        if (vertex1.longitude == vertex2.longitude || position.longitude <= xinters) {
          intersections++;
        }
      }
    }
    return intersections % 2 != 0;
  }
}

extension PolygonsXX on List<List<List<double>>> {
  Polygon toPolygon({PolygonProperties polygonProperties = const PolygonProperties()}) {
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
