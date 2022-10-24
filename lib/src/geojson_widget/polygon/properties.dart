import 'package:console_tools/console_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/src/extensions/extensions.dart';

enum LayerPolygonIndexes {
  fillColor,
  label,
  borderStokeWidth,
  borderColor,
}

class PolygonProperties {
  static const defFillColor = Color(0x9C2195F3);
  static const bool defDisableHolesBorder = true;
  static const bool defIsFilled = true;
  static const String defLabel = '';
  static const double defBorderStokeWidth = 2;
  static const Color defBorderColor = Color(0xFF1E00FD);
  final Color fillColor;
  final String label;
  final double borderStokeWidth;
  final Color borderColor;
  final bool isFilled;
  final bool disableHolesBorder;
  static const bool defLabeled = false;
  static const bool defIsDotted = false;
  static const PolygonLabelPlacement defLabelPlacement = PolygonLabelPlacement.polylabel;
  static const TextStyle defLabelStyle = TextStyle();
  static const bool defRotateLabel = false;
  static const StrokeCap defStrokeCap = StrokeCap.round;
  static const StrokeJoin defStrokeJoin = StrokeJoin.round;
  final bool labeled;
  final bool isDotted;
  final PolygonLabelPlacement labelPlacement;
  final TextStyle labelStyle;
  final bool rotateLabel;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;

  const PolygonProperties({
    this.labeled = PolygonProperties.defLabeled,
    this.isDotted = PolygonProperties.defIsDotted,
    this.labelPlacement = PolygonProperties.defLabelPlacement,
    this.labelStyle = PolygonProperties.defLabelStyle,
    this.rotateLabel = PolygonProperties.defRotateLabel,
    this.strokeCap = PolygonProperties.defStrokeCap,
    this.strokeJoin = PolygonProperties.defStrokeJoin,
    this.fillColor = PolygonProperties.defFillColor,
    this.label = PolygonProperties.defLabel,
    this.borderStokeWidth = PolygonProperties.defBorderStokeWidth,
    this.borderColor = PolygonProperties.defBorderColor,
    this.disableHolesBorder = PolygonProperties.defDisableHolesBorder,
    this.isFilled = PolygonProperties.defIsFilled,
  });
  static PolygonProperties fromMap(
    Map<String, dynamic>? properties,
    Map<LayerPolygonIndexes, String>? layerProperties, {
    PolygonProperties polygonLayerProperties = const PolygonProperties(),
  }) {
    if (properties != null && layerProperties != null) {
      // fill
      final String? layerPropertieFillColor = layerProperties[LayerPolygonIndexes.fillColor];
      var isFilledMap = layerPropertieFillColor != null;
      String hexString = '${properties[layerPropertieFillColor]}';
      final Color fillColor = HexColor.fromHex(hexString, polygonLayerProperties.fillColor);
      // border color
      final String? layerPropertieBorderColor = layerProperties[LayerPolygonIndexes.borderColor];
      String hexString2 = '${properties[layerPropertieBorderColor]}';
      var fall = polygonLayerProperties.borderColor;
      final Color borderColor = HexColor.fromHex(hexString2, fall);
      // border width
      var layerPropertieBWidth = layerProperties[LayerPolygonIndexes.borderStokeWidth];
      var defBorderStokeWidth = polygonLayerProperties.borderStokeWidth;
      var source = '$layerPropertieBWidth';
      final double borderWidth = double.tryParse(source) ?? defBorderStokeWidth;
      // label
      final String? label = layerProperties[LayerPolygonIndexes.label];
      final bool labeled = properties[label] != null;
      var isLabelled = labeled && polygonLayerProperties.labeled;
      String label2 = labeled ? '${properties[label]}' : polygonLayerProperties.label;
      if (fillColor != PolygonProperties.defFillColor) {
        Console.log('inside fromMap fillcolor = $fillColor', color: ConsoleColors.citron);
      }
      return PolygonProperties(
        isFilled: isFilledMap && polygonLayerProperties.isFilled,
        fillColor: fillColor,
        borderColor: borderColor,
        borderStokeWidth: borderWidth,
        label: label2,
        labeled: isLabelled,
        disableHolesBorder: polygonLayerProperties.disableHolesBorder,
        isDotted: polygonLayerProperties.isDotted,
        labelPlacement: polygonLayerProperties.labelPlacement,
        labelStyle: polygonLayerProperties.labelStyle,
        rotateLabel: polygonLayerProperties.rotateLabel,
        strokeCap: polygonLayerProperties.strokeCap,
        strokeJoin: polygonLayerProperties.strokeJoin,
      );
    } else {
      return polygonLayerProperties;
    }
  }
}

// Map<String, String> getProperties(Map<EnumPolygonProperties, String> layerProperties) {}

//   static const bool defLabeled = false;
//   static const bool defIsDotted = false;
//   static const PolygonLabelPlacement defLabelPlacement = PolygonLabelPlacement.polylabel;
//   static const TextStyle defLabelStyle = TextStyle();
//   static const bool defRotateLabel = false;
//   static const StrokeCap defStrokeCap = StrokeCap.round;
//   static const StrokeJoin defStrokeJoin = StrokeJoin.round;
//   final bool labeled;
//   final bool isDotted;
//   final PolygonLabelPlacement labelPlacement;
//   final TextStyle labelStyle;
//   final bool rotateLabel;
//   final StrokeCap strokeCap;
//   final StrokeJoin strokeJoin;
    // this.labeled = PolygonProperties.defLabeled,
    // this.isDotted = PolygonProperties.defIsDotted,
    // this.labelPlacement = PolygonProperties.defLabelPlacement,
    // this.labelStyle = PolygonProperties.defLabelStyle,
    // this.rotateLabel = PolygonProperties.defRotateLabel,
    // this.strokeCap = PolygonProperties.defStrokeCap,
    // this.strokeJoin = PolygonProperties.defStrokeJoin,