import 'package:flutter/material.dart';
import 'package:power_geojson/power_geojson.dart';

class AssetGeoJSONPolyline extends StatelessWidget {
  const AssetGeoJSONPolyline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolylines.asset(
      'assets/lignesassets.geojson',
      /* bufferOptions: BufferOptions(
              buffer: 50,
              polygonBufferProperties: const PolygonProperties(
                borderStokeWidth: 0,
                fillColor: Color(0x8DF436AB),
              ),
            ), */
      polylineProperties: const PolylineProperties(
        isDotted: false,
        borderStrokeWidth: 0,
        borderColor: Colors.red,
        strokeWidth: 3,
        color: Colors.transparent,
        gradientColors: Colors.primaries,
      ),
    );
  }
}
