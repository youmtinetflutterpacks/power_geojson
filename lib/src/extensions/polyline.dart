import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/power_geojson.dart';

extension PolylineXX on List<List<double>> {
  Polyline toPolyline({PolylineProperties polylineProperties = const PolylineProperties()}) {
    var polyline = Polyline(
      colorsStop: polylineProperties.colorsStop,
      gradientColors: polylineProperties.gradientColors,
      strokeWidth: polylineProperties.strokeWidth,
      useStrokeWidthInMeter: polylineProperties.useStrokeWidthInMeter,
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
