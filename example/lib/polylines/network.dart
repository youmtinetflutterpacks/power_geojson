import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/power_geojson.dart';
import 'package:power_geojson_example/lib.dart';

class NetworkGeoJSONPolyline extends StatelessWidget {
  const NetworkGeoJSONPolyline({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolylines.network(
      "$url/others/network_lines.json",
      polylineProperties: const PolylineProperties(
        layerProperties: {
          LayerPolylineIndexes.borderColor: 'COLOR',
        },
        isDotted: false,
      ),
      mapController: _mapController,
    );
  }
}

class NetworkGeoJSONMultiPolyline extends StatelessWidget {
  const NetworkGeoJSONMultiPolyline({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolylines.network(
      "$url/others/network_linesmultiples.json",
      polylineProperties: const PolylineProperties(
        layerProperties: {
          LayerPolylineIndexes.borderColor: 'COLOR',
        },
        isDotted: false,
      ),
      mapController: _mapController,
    );
  }
}
