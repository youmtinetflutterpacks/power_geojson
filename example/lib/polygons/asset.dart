import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/power_geojson.dart';

class AssetGeoJSONPolygon extends StatelessWidget {
  const AssetGeoJSONPolygon({
    Key? key,
    required MapController mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolygons.asset(
      "assets/geojson.json",
      /* bufferOptions: BufferOptions(
        buffer: 300,
        buffersOnly: true,
        /* polygonBufferProperties: PolygonProperties(
          fillColor: const Color(0xFF6D05A8).withOpacity(0.5),
          borderStokeWidth: 4,
          isDotted: true,
          borderColor: Colors.green,
        ), */
      ), */
      polygonProperties: const PolygonProperties(
        isDotted: false,
        label: 'Asset',
        fillColor: Color(0xFFA29A0A),
        rotateLabel: true,
        labelStyle: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.black,
          shadows: [
            Shadow(blurRadius: 10, color: Colors.white),
          ],
          decoration: TextDecoration.underline,
        ),
        labeled: true,
      ),
      mapController: _mapController,
    );
  }
}
