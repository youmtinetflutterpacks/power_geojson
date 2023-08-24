import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:power_geojson/power_geojson.dart';

class FileGeoJSONPolylines extends StatelessWidget {
  const FileGeoJSONPolylines({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolylines.file(
      "/storage/emulated/0/Android/data/com.ymrabtipacks.power_geojson_example/files/files_lines",
      polylineProperties: const PolylineProperties(),
      mapController: _mapController,
    );
  }
}

class FileGeoJSONMultiPolylines extends StatelessWidget {
  const FileGeoJSONMultiPolylines({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolylines.file(
      "/storage/emulated/0/Android/data/com.ymrabtipacks.power_geojson_example/files/files_multilines",
      polylineProperties: const PolylineProperties(),
      mapController: _mapController,
    );
  }
}
