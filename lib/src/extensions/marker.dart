import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:power_geojson/src/geojson_widget/markers/properties.dart';
import 'package:power_geojson/src/geojson_widget/polygon/properties.dart';

extension MarkersX on List<Marker> {
  List<CircleMarker> toBuffers(double radius, PolygonProperties polygonProperties) {
    return [...map((e) => e.buffer(radius, polygonProperties))];
  }
}

extension MarkerX on Marker {
  CircleMarker buffer(double radius, PolygonProperties polygonProperties) {
    return CircleMarker(
      point: point,
      radius: radius,
      borderStrokeWidth: polygonProperties.borderStokeWidth,
      color: polygonProperties.fillColor,
      useRadiusInMeter: true,
      borderColor: polygonProperties.borderColor,
    );
  }
}

extension MarkerXX on List<double> {
  Marker toMarker({required MarkerProperties markerProperties}) {
    var marker = Marker(
      height: markerProperties.height,
      width: markerProperties.width,
      rotate: markerProperties.rotate,
      builder: markerProperties.builder,
      rotateAlignment: markerProperties.rotateAlignment,
      anchorPos: markerProperties.anchorPos,
      key: markerProperties.key,
      rotateOrigin: markerProperties.rotateOrigin,
      point: LatLng(this[1], this[0]),
    );
    return marker;
  }
}

// var distanceDMS = dmFromMeters(radius);
// var customPaint = CustomPaint(painter: OpenPainter());

/* var cArrSeqFac = dart_jts.CoordinateArraySequenceFactory();
var res = createCircularString(cArrSeqFac, 2, point.toCoordinate(), radius, 0, 490);
var coordinateArray = res.toCoordinateArray().toLatLng();
var polygon = Polygon(
    isFilled: true,
    holePointsList: [],
    points: coordinateArray,
    label: polygonProperties.label,
    color: polygonProperties.fillColor,
    isDotted: polygonProperties.isDotted,
    strokeCap: polygonProperties.strokeCap,
    labelStyle: polygonProperties.labelStyle,
    strokeJoin: polygonProperties.strokeJoin,
    rotateLabel: polygonProperties.rotateLabel,
    borderColor: polygonProperties.borderColor,
    labelPlacement: polygonProperties.labelPlacement,
    borderStrokeWidth: polygonProperties.borderStokeWidth,
    disableHolesBorder: polygonProperties.disableHolesBorder,
); */
