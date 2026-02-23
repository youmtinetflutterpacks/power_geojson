import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/power_geojson.dart';

class AssetGeoJSONPolygon extends StatelessWidget {
  const AssetGeoJSONPolygon({Key? key, MapController? mapController})
    : _mapController = mapController,
      super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolygons.asset(
      "assets/polygons.geojson",
      polygonProperties: const PolygonProperties(
        label: 'Asset',
        fillColor: Color(0x662195F3), // translucent blue @ 40%
        borderColor: Color(0xFF1E00FD), // deep blue border
        borderStokeWidth: 2,
        rotateLabel: true,
        isFilled: true,
        labelStyle: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 8, color: Colors.black)],
        ),
        labeled: true,
        layerProperties: {
          LayerPolygonIndexes.label: 'Name',
          LayerPolygonIndexes.borderStokeWidth: 'FID',
        },
      ),
      mapController: _mapController,
    );
  }
}

class AssetGeoJSONZones extends StatelessWidget {
  const AssetGeoJSONZones({Key? key, MapController? mapController})
    : _mapController = mapController,
      super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolygons.asset(
      "assets/morocco.geojson",
      polygonProperties: const PolygonProperties(
        fillColor: Color(0x662195F3), // translucent blue @ 40%
        borderColor: Color(0xFF1E00FD), // deep blue border
        borderStokeWidth: 2,
        rotateLabel: true,
        labelStyle: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.white,
          shadows: [Shadow(blurRadius: 8, color: Colors.black)],
        ),
        labeled: true,
        layerProperties: {
          LayerPolygonIndexes.fillColor: 'color',
          LayerPolygonIndexes.label: 'name',
        },
      ),
      mapController: _mapController,
    );
  }
}
