import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/power_geojson.dart';
import 'package:power_geojson_example/lib.dart';

class NetworkGeoJSONPolygon extends StatelessWidget {
  const NetworkGeoJSONPolygon({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolygons.network(
      "$url/others/network_polygons.json",
      polygonProperties: const PolygonProperties(
        layerProperties: {
          LayerPolygonIndexes.fillColor: 'COLOR',
          LayerPolygonIndexes.label: 'ECO_NAME',
        },
        isDotted: false,
        rotateLabel: true,
        borderStokeWidth: 0.02,
        fillColor: Color(0xFF17CD11),
        labelStyle: TextStyle(
          fontStyle: FontStyle.italic,
          color: Color(0xFF830202),
          shadows: [
            Shadow(blurRadius: 10, color: Colors.white),
          ],
        ),
        labeled: true,
      ),
      mapController: _mapController,
    );
  }
}

class NetworkGeoJSONMultiPolygon extends StatelessWidget {
  const NetworkGeoJSONMultiPolygon({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolygons.network(
      "$url/others/network_polygonsmultiples.json",
      polygonProperties: const PolygonProperties(
        layerProperties: {
          LayerPolygonIndexes.fillColor: 'COLOR',
        },
        isDotted: false,
        rotateLabel: true,
        label: 'MP',
        borderStokeWidth: 0.02,
        fillColor: Color(0xFFA33A10),
        labelStyle: TextStyle(
          fontStyle: FontStyle.italic,
          color: Color(0xFF830202),
          shadows: [
            Shadow(blurRadius: 10, color: Colors.white),
          ],
        ),
        labeled: true,
      ),
      mapController: _mapController,
    );
  }
}
