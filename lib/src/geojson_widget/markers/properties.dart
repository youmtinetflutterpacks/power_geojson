import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

enum LayerMarkerIndexes {
  width,
  height,
  rotate,
}

class MarkerProperties {
  final Key? key;
  final double width;
  final double height;
  final AnchorPos? anchorPos;
  final bool? rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;
  final Map<LayerMarkerIndexes, String>? layerProperties;

  const MarkerProperties({
    this.layerProperties,
    this.key,
    this.width = 30.0,
    this.height = 30.0,
    this.anchorPos,
    this.rotate,
    this.rotateOrigin,
    this.rotateAlignment,
  });
  static MarkerProperties fromMap(
    Map<String, dynamic>? properties,
    MarkerProperties markerLayerProperties,
  ) {
    var layerMarkerProperties = markerLayerProperties.layerProperties;
    if (properties != null && layerMarkerProperties != null) {
      // width
      final String? keyPropertieWidth = layerMarkerProperties[LayerMarkerIndexes.width];
      double? propWidth = properties[keyPropertieWidth];
      // width
      final String? keyPropertieHeight = layerMarkerProperties[LayerMarkerIndexes.height];
      double? propHeighgt = properties[keyPropertieHeight];
      // width
      final String? keyPropertieRotate = layerMarkerProperties[LayerMarkerIndexes.rotate];
      bool? propRotate = properties[keyPropertieRotate];
      return MarkerProperties(
        key: markerLayerProperties.key,
        width: propWidth ?? markerLayerProperties.width,
        height: propHeighgt ?? markerLayerProperties.height,
        rotate: propRotate,
        rotateAlignment: markerLayerProperties.rotateAlignment,
        rotateOrigin: markerLayerProperties.rotateOrigin,
        anchorPos: markerLayerProperties.anchorPos,
      );
    } else {
      return markerLayerProperties;
    }
  }
}
