import 'package:flutter/material.dart';
import 'package:power_geojson/src/extensions/extensions.dart';

enum LayerPolylineIndexes {
  fillColor,
  label,
  borderStokeWidth,
  borderColor,
}

class PolylineProperties {
  static const defFillColor = Color(0x9C2195F3);
  static const double defBorderStokeWidth = 2;
  static const Color defBorderColor = Color(0xFF1E00FD);
  static const bool defIsDotted = false;
  static const StrokeCap defStrokeCap = StrokeCap.round;
  static const StrokeJoin defStrokeJoin = StrokeJoin.round;
  static const List<double> defColorsStop = [];
  static const List<Color> defGradientColors = [];
  static const double defStrokeWidth = 1;

  final Color color;
  final double borderStrokeWidth;
  final Color borderColor;
  final bool isDotted;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
  final List<double> colorsStop;
  final List<Color> gradientColors;
  final double strokeWidth;

  static PolylineProperties fromMap(
    Map<String, dynamic>? properties,
    Map<LayerPolylineIndexes, String>? layerProperties, {
    PolylineProperties polylineLayerProperties = const PolylineProperties(),
  }) {
    if (properties != null && layerProperties != null) {
      // fill
      final String? layerPropertieFillColor = layerProperties[LayerPolylineIndexes.fillColor];
      String hexString = '${properties[layerPropertieFillColor]}';
      final Color fillColor = HexColor.fromHex(hexString, polylineLayerProperties.color);
      // border color
      final String? layerPropertieBorderColor = layerProperties[LayerPolylineIndexes.borderColor];
      String hexString2 = '${properties[layerPropertieBorderColor]}';
      var fall = polylineLayerProperties.borderColor;
      final Color borderColor = HexColor.fromHex(hexString2, fall);
      // border width
      var layerPropertieBWidth = layerProperties[LayerPolylineIndexes.borderStokeWidth];
      var defBorderStokeWidth = polylineLayerProperties.borderStrokeWidth;
      var source = '$layerPropertieBWidth';
      final double borderWidth = double.tryParse(source) ?? defBorderStokeWidth;
      return PolylineProperties(
        colorsStop: polylineLayerProperties.colorsStop,
        gradientColors: polylineLayerProperties.gradientColors,
        strokeWidth: borderWidth,
        isDotted: polylineLayerProperties.isDotted,
        strokeCap: polylineLayerProperties.strokeCap,
        strokeJoin: polylineLayerProperties.strokeJoin,
        borderStrokeWidth: polylineLayerProperties.borderStrokeWidth,
        borderColor: borderColor,
        color: fillColor,
        //
      );
    } else {
      return polylineLayerProperties;
    }
  }

  const PolylineProperties({
    this.colorsStop = PolylineProperties.defColorsStop,
    this.gradientColors = PolylineProperties.defGradientColors,
    this.strokeWidth = PolylineProperties.defStrokeWidth,
    this.isDotted = PolylineProperties.defIsDotted,
    this.strokeCap = PolylineProperties.defStrokeCap,
    this.strokeJoin = PolylineProperties.defStrokeJoin,
    this.borderStrokeWidth = PolylineProperties.defBorderStokeWidth,
    this.borderColor = PolylineProperties.defBorderColor,
    this.color = PolylineProperties.defFillColor,
  });
}
