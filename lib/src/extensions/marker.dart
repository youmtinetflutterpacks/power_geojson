import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:power_geojson/power_geojson.dart';
import 'package:flutter/material.dart';

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
