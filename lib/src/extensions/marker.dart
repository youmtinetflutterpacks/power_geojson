import 'package:dart_jts/dart_jts.dart' as dart_jts;
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:power_geojson/power_geojson.dart';
import 'package:flutter/material.dart';

extension MarkersX on List<Marker> {
  List<Polygon> toBuffers(double radius, PolygonProperties polygonProperties) {
    return map((e) => e.buffer(radius, polygonProperties)).toList();
  }
}

extension MarkerX on Marker {
  CircleMarker bufferCircle(double radius, PolygonProperties polygonProperties) {
    return CircleMarker(
      point: point,
      radius: radius,
      borderStrokeWidth: polygonProperties.borderStokeWidth,
      color: polygonProperties.fillColor,
      useRadiusInMeter: true,
      borderColor: polygonProperties.borderColor,
    );
  }

  Polygon buffer(double radius, PolygonProperties polygonProperties) {
    var pointCoordinate = point.toCoordinate();
    final geometryFactory = dart_jts.GeometryFactory.defaultPrecision();
    final polylines = geometryFactory.createPoint(pointCoordinate);
    var distanceDMS = dmFromMeters(radius);
    final buffer = dart_jts.BufferOp.bufferOp3(polylines, distanceDMS, 10);
    var bufferBolygon = buffer as dart_jts.Polygon;
    var listPointsPolyline = bufferBolygon.shell!.points.toCoordinateArray().toLatLng();
    var polygon = Polygon(
      points: listPointsPolyline,
      isFilled: polygonProperties.isFilled,
      color: polygonProperties.fillColor,
      borderColor: polygonProperties.borderColor,
      borderStrokeWidth: polygonProperties.borderStokeWidth,
      isDotted: polygonProperties.isDotted,
      strokeCap: polygonProperties.strokeCap,
      disableHolesBorder: polygonProperties.disableHolesBorder,
      label: polygonProperties.label,
      labelPlacement: polygonProperties.labelPlacement,
      labelStyle: polygonProperties.labelStyle,
      rotateLabel: polygonProperties.rotateLabel,
      strokeJoin: polygonProperties.strokeJoin,
    );
    return polygon;
  }
}

extension MarkerXX on List<double> {
  Marker toMarker({
    required MarkerProperties markerProperties,
    required Widget Function(BuildContext buildContext) builder,
  }) {
    var marker = Marker(
      height: markerProperties.height,
      width: markerProperties.width,
      rotate: markerProperties.rotate,
      builder: builder,
      rotateAlignment: markerProperties.rotateAlignment,
      anchorPos: markerProperties.anchorPos,
      key: markerProperties.key,
      rotateOrigin: markerProperties.rotateOrigin,
      point: LatLng(this[1], this[0]),
    );
    return marker;
  }
}
