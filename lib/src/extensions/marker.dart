import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:power_geojson/power_geojson.dart';
import 'package:flutter/material.dart';

extension MarkerXX on List<double> {
  /// Converts a list coords of point into a [Marker]
  Marker toMarker({
    required MarkerProperties markerProperties,
    required Widget child,
  }) {
    var marker = Marker(
      height: markerProperties.height,
      width: markerProperties.width,
      rotate: markerProperties.rotate,
      child: child,
      alignment: markerProperties.rotateAlignment,
      key: markerProperties.key,
      point: LatLng(this[1], this[0]),
    );
    return marker;
  }
}
