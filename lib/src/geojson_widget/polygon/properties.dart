import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/power_geojson.dart';

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
  static const PolygonLabelPlacement defLabelPlacement =
      PolygonLabelPlacement.polylabel;
  static const TextStyle defLabelStyle = TextStyle();
  static const bool defRotateLabel = false;
  static const StrokeCap defStrokeCap = StrokeCap.round;
  static const StrokeJoin defStrokeJoin = StrokeJoin.round;
  final bool labeled;
  final bool isDotted;
  final Map<LayerPolygonIndexes, String>? layerProperties;
  final PolygonLabelPlacement labelPlacement;
  final TextStyle labelStyle;
  final bool rotateLabel;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;

  const PolygonProperties({
    this.layerProperties,
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
    PolygonProperties polygonLayerProperties,
  ) {
    var layerProperties = polygonLayerProperties.layerProperties;
    if (properties != null && layerProperties != null) {
      // fill
      final String? keyPropertieFillColor =
          layerProperties[LayerPolygonIndexes.fillColor];
      var isFilledMap = keyPropertieFillColor != null;
      String hexString = '${properties[keyPropertieFillColor]}';
      final Color fillColor =
          HexColor.fromHex(hexString, polygonLayerProperties.fillColor);
      // border color
      final String? layerPropertieBorderColor =
          layerProperties[LayerPolygonIndexes.borderColor];
      String hexString2 = '${properties[layerPropertieBorderColor]}';
      var fall = polygonLayerProperties.borderColor;
      final Color borderColor = HexColor.fromHex(hexString2, fall);
      // border width
      var layerPropertieBWidth =
          layerProperties[LayerPolygonIndexes.borderStokeWidth];
      // label
      final String? label = layerProperties[LayerPolygonIndexes.label];
      final bool labeled = properties[label] != null;
      var isLabelled = labeled && polygonLayerProperties.labeled;
      String label2 =
          labeled ? '${properties[label]}' : polygonLayerProperties.label;
      return PolygonProperties(
        isFilled: isFilledMap && polygonLayerProperties.isFilled,
        fillColor: fillColor,
        borderColor: borderColor,
        borderStokeWidth: (properties[layerPropertieBWidth] ??
                polygonLayerProperties.borderStokeWidth)
            .toDouble(),
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
