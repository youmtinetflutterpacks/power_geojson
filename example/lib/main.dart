import 'dart:io';

import 'package:console_tools/console_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:enhanced_future_builder/enhanced_future_builder.dart';
import 'package:power_geojson/power_geojson.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:power_geojson_example/lib.dart';

void main() {
  runApp(
    const GetMaterialApp(
      home: PowerGeojsonSampleApp(),
    ),
  );
}

Future<PowerGeoPolygon> _assetPolygons(String path) async {
  final string = await rootBundle.loadString(path);
  return PowerGeoJSONFeatureCollection.fromJson(string).geoJSONPolygons.first;
}

class PowerGeojsonSampleApp extends StatefulWidget {
  const PowerGeojsonSampleApp({
    super.key,
  });

  @override
  State<PowerGeojsonSampleApp> createState() => _PowerGeojsonSampleAppState();
}

class _PowerGeojsonSampleAppState extends State<PowerGeojsonSampleApp> {
  var latLng = const latlong2.LatLng(34.92849168609999, -2.3225879568537056);

  final MapController _mapController = MapController();
  @override
  void initState() {
    super.initState();
  }

  GestureDetector gestureDetector() => GestureDetector(
        onLongPressStart: (details) {},
      );
  @override
  Widget build(BuildContext context) {
    // double distanceMETERS = 10;
    // var distanceDMS = dmFromMeters(distanceMETERS);
    return Scaffold(
      body: Center(
        child: EnhancedFutureBuilder(
          future: _assetPolygons('assets/geojsons/moorocco.geojson'),
          whenDone: (polygon) {
            return ClipPath(
              clipper: PowerGeoJSONClipper(
                polygon: polygon.geometry.coordinates.toPolygon(),
              ),
              child: Container(
                color: Colors.red,
                width: Get.width / 1.23,
                height: Get.height / 1.5,
                child: const Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
          rememberFutureResult: false,
          whenNotDone: const Center(
            child: Icon(
              Icons.error,
              color: Colors.blue,
            ),
          ),
        ),
      ),
    );
  }

  Scaffold map() {
    var interactiveFlags2 = InteractiveFlag.doubleTapZoom | InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove;
    var center = const latlong2.LatLng(34.926447747065936, -2.3228343908943998);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Power GeoJSON Examples"),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: 11,
          interactionOptions: InteractionOptions(flags: interactiveFlags2),
          onLongPress: (tapPosition, point) {
            Console.log('onLongPress $point', color: ConsoleColors.citron);
          },
          onMapEvent: (mapEvent) async {
            var txt = await PowerGeoJSONFeatureCollections.asset(
              "assets/geojsons/assets_polygonsmultiples.geojson",
              featureCollectionProperties: const FeatureCollectionProperties(),
              builder: (p0, p1) {
                return const SizedBox();
              },
            );
            Console.log(txt);
          },
          onMapReady: () async {
            await _createFiles();
            // await Future.delayed(const Duration(seconds: 1));
            // var users = await UserProvider().getRandomUsers();
          },
        ),
        children: [
          /* TileLayer(
                urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
                backgroundColor: const Color(0xFF202020),
                maxZoom: 19,
              ), */

          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            maxZoom: 19,
          ),

          const AssetGeoJSONZones(),
          /* FeatureLayer(
                options: FeatureLayerOptions(
                  "https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/Landscape_Trees/FeatureServer/0",
                  "point",
                ),
                stream: esri(),
              ), */

          /* 
              */
          //////////////// Polygons
          const AssetGeoJSONPolygon(),
          const AssetGeoJSONMultiPolygon(),

          const FileGeoJSONPolygon(),
          const FileGeoJSONMultiPolygon(),

          const StringGeoJSONPolygon(),
          const StringGeoJSONMultiPolygon(),

          const NetworkGeoJSONPolygon(),
          const NetworkGeoJSONMultiPolygon(),
          NetworkGeoJSONMultiPolygon1(
            mapController: _mapController,
          ),
          //////////////// Lines
          const AssetGeoJSONLines(),
          const AssetGeoJSONMultiLines(),

          const FileGeoJSONPolylines(),
          const FileGeoJSONMultiPolylines(),

          const StringGeoJSONLines(),
          const StringGeoJSONMultiLines(),

          const NetworkGeoJSONPolyline(),
          const NetworkGeoJSONMultiPolyline(),

          //////////////// Points
          const AssetGeoJSONMarkerPoints(),
          const AssetGeoJSONMarkerMultiPoints(),

          const FileGeoJSONMarkers(),
          const FileGeoJSONMultiMarkers(),

          const StringGeoJSONPoints(),
          const StringGeoJSONMultiPoints(),

          const NetworkGeoJSONMarker(),
          const NetworkGeoJSONMultiMarker(),
          //   MarkerLayer(markers: getMarkers()),

          CircleOfMap(latLng: latLng),
          /* const ClustersMarkers(), */
        ],
      ),
    );
  }

  /* Polygon getPolygon() {
    var polygon = ringsHoled.toPolygon(
      polygonProperties: PolygonProperties(
        fillColor: const Color(0xFF5E0365).withOpacity(0.5),
      ),
    );
    Console.log(polygon.isGeoPointInPolygon(latLng));
    Console.log(polygon.isIntersectedWithPoint(latLng), color: ConsoleColors.teal);
    return polygon;
  } */

  Stream<void> esri() async* {
    await Future.delayed(const Duration(seconds: 1));
    yield 1;
  }
}

Future<void> _createFiles() async {
  final assetsPoints = await rootBundle.loadString('assets/geojsons/files/files_points.geojson');
  final assetsMultipoints = await rootBundle.loadString('assets/geojsons/files/files_pointsmultiples.geojson');
  final assetsLines = await rootBundle.loadString('assets/geojsons/files/files_lines.geojson');
  final assetsMultilines = await rootBundle.loadString('assets/geojsons/files/files_linesmultiples.geojson');
  final assetsPolygons = await rootBundle.loadString('assets/geojsons/files/files_polygons.geojson');
  final assetsMultipolygons = await rootBundle.loadString('assets/geojsons/files/files_polygonsmultiples.geojson');
  await _createFile('files_points', assetsPoints);
  await _createFile('files_multipoints', assetsMultipoints);
  await _createFile('files_lines', assetsLines);
  await _createFile('files_multilines', assetsMultilines);
  await _createFile('files_polygons', assetsPolygons);
  await _createFile('files_multipolygons', assetsMultipolygons);
}

Future<File> _createFile(String filename, String data) async {
  var list = await getExternalDir();
  var directory = ((list == null || list.isEmpty) ? Directory('/') : list[0]).path;
  final path = "$directory/$filename";
  Console.log(path);
  final File file = File(path);
  var exists = await file.exists();
  if (!exists) {
    var savedFile = await file.writeAsString(data);
    return savedFile;
  }
  return file;
}

class UserProvider extends GetConnect {
  // Get request
  Future<String?> getRandomUsers() async {
    var future = await get('https://randomuser.me/api?results=50');
    return future.bodyString;
  }

  // Post request
  Future<Response> postUser(Map data) => post('http://youapi/users', data);
  // Post request with File
  Future<Response<RandomUserApi>> postCases(List<int> image) {
    final form = FormData({
      'file': MultipartFile(image, filename: 'avatar.png'),
      'otherFile': MultipartFile(image, filename: 'cover.png'),
    });
    return post('http://youapi/users/upload', form);
  }

  GetSocket userMessages() {
    return socket('https://yourapi/users/socket');
  }
}

class CircleOfMap extends StatelessWidget {
  const CircleOfMap({
    Key? key,
    required this.latLng,
  }) : super(key: key);

  final latlong2.LatLng latLng;

  @override
  Widget build(BuildContext context) {
    return CircleLayer(
      circles: [
        CircleMarker(
          point: latLng,
          radius: 500,
          color: Colors.indigo.withOpacity(0.6),
          borderColor: Colors.black,
          borderStrokeWidth: 3,
          useRadiusInMeter: true,
        ),
      ],
    );
  }
}
/* function getRandomColor() {
  const letters = '0123456789ABCDEF';
  let color = '#';
  for (let i = 0; i < 6; i++) {
    color += letters[Math.floor(Math.random() * 16)];
  }
  return color;
}

function generateRandomColorList(count) {
  const colorList = [];
  for (let i = 0; i < count; i++) {
    colorList.push(getRandomColor());
  }
  return colorList;
} 
console.log(generateRandomColorList(10)); 
*/

