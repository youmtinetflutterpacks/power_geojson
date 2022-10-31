import 'package:dart_jts/dart_jts.dart' as dart_jts;
import 'package:flutter_map/flutter_map.dart';

import 'package:power_geojson/src/extensions/extensions.dart';
import 'package:power_geojson/src/geojson_widget/polygon/properties.dart';
import 'package:power_geojson/src/geojson_widget/polyline/properties.dart';
import 'package:power_geojson/src/utils.dart';

extension PolylinesX on List<Polyline> {
  List<Polygon> toBuffers(double radius, PolygonProperties polygonProperties) {
    return map((e) => e.buffer(radius, polygonProperties)).toList();
  }
}

extension PolylineX on Polyline {
  Polygon buffer(double radius, PolygonProperties polygonProperties) {
    var listCoordinate = points.toCoordinates();
    final geometryFactory = dart_jts.GeometryFactory.defaultPrecision();
    final polylines = geometryFactory.createLineString(listCoordinate);
    var distanceDMS = dmFromMeters(radius);
    final buffer = dart_jts.BufferOp.bufferOp3(polylines, distanceDMS, 10);
    var bufferBolygon = buffer as dart_jts.Polygon;
    var listPointsPolyline =
        bufferBolygon.shell!.points.toCoordinateArray().toLatLng();
    var polygon = Polygon(
      points: listPointsPolyline,
      isFilled: true,
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

extension PolylineXX on List<List<double>> {
  Polyline toPolyline(
      {PolylineProperties polylineProperties = const PolylineProperties()}) {
    var polyline = Polyline(
      colorsStop: polylineProperties.colorsStop,
      gradientColors: polylineProperties.gradientColors,
      strokeWidth: polylineProperties.strokeWidth,
      points: toLatLng(),
      color: polylineProperties.color,
      borderColor: polylineProperties.borderColor,
      borderStrokeWidth: polylineProperties.borderStrokeWidth,
      isDotted: polylineProperties.isDotted,
      strokeCap: polylineProperties.strokeCap,
      strokeJoin: polylineProperties.strokeJoin,
    );
    // consoleLog(polyline.area(), color: 35);
    return polyline;
  }
}
