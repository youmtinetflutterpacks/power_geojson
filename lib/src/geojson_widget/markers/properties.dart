import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

enum LayerMarkerIndexes {
  width,
  height,
  rotate,
}

class MarkerProperties {
  final Key? key;
  final Widget Function(BuildContext) builder;
  final double width;
  final double height;
  final AnchorPos? anchorPos;
  final bool? rotate;
  final Offset? rotateOrigin;
  final AlignmentGeometry? rotateAlignment;

  const MarkerProperties({
    this.key,
    required this.builder,
    this.width = 30.0,
    this.height = 30.0,
    this.anchorPos,
    this.rotate,
    this.rotateOrigin,
    this.rotateAlignment,
  });
  static MarkerProperties fromMap(
    Map<String, dynamic>? properties,
    Map<LayerMarkerIndexes, String>? layerMarkerProperties,
    MarkerProperties markerLayerProperties,
  ) {
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
        builder: markerLayerProperties.builder,
        rotateOrigin: markerLayerProperties.rotateOrigin,
        anchorPos: markerLayerProperties.anchorPos,
      );
    } else {
      return markerLayerProperties;
    }
  }
}
