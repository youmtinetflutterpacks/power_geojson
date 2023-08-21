import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/power_geojson.dart';

class AssetGeoJSONLines extends StatelessWidget {
  const AssetGeoJSONLines({Key? key, this.mapController}) : super(key: key);
  final MapController? mapController;
  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolylines.asset(
      'assets/geojsons/assets_lines.geojson',
      bufferOptions: BufferOptions(
        buffer: 50,
        polygonBufferProperties: const PolygonProperties(
          borderStokeWidth: 1,
          isFilled: true,
          fillColor: Color(0x8DCA7608),
        ),
      ),
      mapController: mapController,
      //   polylineCulling: true,
      polylineProperties: const PolylineProperties(
        isDotted: false,
        borderStrokeWidth: 0,
        borderColor: Colors.red,
        useStrokeWidthInMeter: true,
        strokeWidth: 20,
        color: Colors.transparent,
        gradientColors: Colors.primaries,
      ),
    );
  }
}

class AssetGeoJSONMultiLines extends StatelessWidget {
  const AssetGeoJSONMultiLines({Key? key, this.mapController}) : super(key: key);
  final MapController? mapController;
  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolylines.asset(
      'assets/geojsons/assets_linesmultiples.geojson',
      bufferOptions: BufferOptions(
        buffer: 150,
        polygonBufferProperties: const PolygonProperties(
          borderStokeWidth: 1,
          isFilled: true,
          label: "MultiLines",
          fillColor: Color(0x8D0E8104),
        ),
      ),
      mapController: mapController,
      //   polylineCulling: true,
      polylineProperties: const PolylineProperties(
        isDotted: false,
        borderStrokeWidth: 0,
        borderColor: Colors.red,
        useStrokeWidthInMeter: true,
        strokeWidth: 100,
        color: Colors.transparent,
        // gradientColors: [Colors.red, Colors.blue, Colors.cyan, Colors.green, Colors.yellow],
        layerProperties: {
          LayerPolylineIndexes.strokeWidth: 'strokeWidth',
          LayerPolylineIndexes.color: 'color',
        },
      ),
    );
  }
}
