import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:power_geojson/power_geojson.dart';

class FileGeoJSONPolygon extends StatelessWidget {
  const FileGeoJSONPolygon({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolygons.file(
      "/storage/emulated/0/Android/data/com.ymrabtipacks.power_geojson_example/files/files_polygons",
      polygonProperties: const PolygonProperties(
        isDotted: false,
        rotateLabel: true,
        label: 'File',
        fillColor: Color(0xFF7F0573),
        isFilled: true,
        borderColor: Colors.red,
        labelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 10, color: Colors.black),
          ],
        ),
        labeled: true,
      ),
      mapController: _mapController,
    );
  }
}

class FileGeoJSONMultiPolygon extends StatelessWidget {
  const FileGeoJSONMultiPolygon({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONPolygons.file(
      "/storage/emulated/0/Android/data/com.ymrabtipacks.power_geojson_example/files/files_multipolygons",
      /* polygonProperties: const PolygonProperties(
        isDotted: false,
        rotateLabel: true,
        label: 'File Multi',
        fillColor: Color(0xFF5328EF),
        isFilled: true,
        borderColor: Colors.red,
        labelStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(blurRadius: 10, color: Colors.black),
          ],
        ),
        labeled: true,
      ), */
      builder: (coordinates, map) {
        TextFormField();
        return Polygon(
          points: coordinates.first.map((e) => LatLng(e[1], e[0])).toList(),
          holePointsList: coordinates
              .map((f) => f.map((e) => LatLng(e[1], e[0])).toList())
              .toList(),
          color: Colors.purple,
        );
      },
      mapController: _mapController,
    );
  }
}
