import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/src/geojson_widget/polygon/properties.dart';

class BufferOptions {
  final double? _buffer;
  final bool buffersOnly;
  double get buffer => _buffer ?? 0;
  PolygonProperties? polygonBufferProperties;
  BufferOptions({
    double? buffer,
    this.buffersOnly = false,
    this.polygonBufferProperties,
  }) : _buffer = buffer;
}

class MarkerProperties {
  final Key? key;
  final Widget Function(BuildContext) builder;
  static const bool defLabeled = false;
  static const bool defaultRotate = false;
  static const TextStyle defLabelStyle = TextStyle();
  static const bool defRotateLabel = false;
  static const Offset defStrokeCap = Offset(0, 0);
  static const StrokeJoin defStrokeJoin = StrokeJoin.round;
  final bool rotate;
  final Offset rotateOrigin;
  final AnchorPos<dynamic>? anchorPos;

  static const List<double> defColorsStop = [];
  final Alignment? rotateAlignment;

  static const double defaultHeight = 30;
  final double height;

  static const double defaultWidth = 30;
  final double width;

  const MarkerProperties({
    this.width = MarkerProperties.defaultWidth,
    this.height = MarkerProperties.defaultHeight,
    this.rotate = MarkerProperties.defaultRotate,
    required this.builder,
    this.rotateAlignment,
    this.anchorPos,
    this.key,
    this.rotateOrigin = MarkerProperties.defStrokeCap,
    //
  });
  static MarkerProperties fromMap(
      Map<String, dynamic>? properties,
      Map<LayerPolygonIndexes, String>? layerProperties,
      MarkerProperties markerLayerProperties) {
    if (properties != null && layerProperties != null) {
      return MarkerProperties(
        key: markerLayerProperties.key,
        rotateAlignment: markerLayerProperties.rotateAlignment,
        height: markerLayerProperties.height,
        width: markerLayerProperties.width,
        builder: markerLayerProperties.builder,
        rotate: markerLayerProperties.rotate,
        rotateOrigin: markerLayerProperties.rotateOrigin,
        anchorPos: markerLayerProperties.anchorPos,
      );
    } else {
      return markerLayerProperties;
    }
  }
}
