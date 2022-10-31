import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';

import 'package:power_geojson/power_geojson.dart';
import 'package:console_tools/console_tools.dart';
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:power_geojson_example/custom/random_user_api/random_user_api.dart';
import 'package:power_geojson_example/markers/asset.dart';
import 'package:power_geojson_example/markers/index.dart';
import 'package:power_geojson_example/polygons/asset.dart';
import 'package:power_geojson_example/polygons/file.dart';
import 'package:power_geojson_example/polygons/network.dart';
import 'package:power_geojson_example/polygons/string.dart';
import 'package:power_geojson_example/polylines/asset.dart';

void main() {
  runApp(const GetMaterialApp(
    home: PowerGeojsonSampleApp(),
  ));
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

class PowerGeojsonSampleApp extends StatefulWidget {
  const PowerGeojsonSampleApp({
    super.key,
  });

  @override
  State<PowerGeojsonSampleApp> createState() => _PowerGeojsonSampleAppState();
}

class _PowerGeojsonSampleAppState extends State<PowerGeojsonSampleApp> {
  var latLng = latlong2.LatLng(34.92849168609999, -2.3225879568537056);
  final MapController _mapController = MapController();
  final FlutterMapState mapState = FlutterMapState();
  bool start = false;
  @override
  void initState() {
    super.initState();
  }

  GestureDetector gestureDetector() => GestureDetector(
        onLongPressStart: (details) {},
      );
  @override
  Widget build(BuildContext context) {
    var interactiveFlags2 = InteractiveFlag.doubleTapZoom | InteractiveFlag.drag | InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove;
    var center = latlong2.LatLng(34.926447747065936, -2.3228343908943998);
    // double distanceMETERS = 10;
    // var distanceDMS = dmFromMeters(distanceMETERS);
    var baseUrl = "https://server.arcgisonline.com/ArcGIS/rest/services";
    return Scaffold(
      appBar: AppBar(
        title: const Text("Power GeoJSON Examples"),
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: center,
          zoom: 11,
          interactiveFlags: interactiveFlags2,
          onLongPress: (tapPosition, point) {
            Console.log('onLongPress $point', color: ConsoleColors.citron);
          },
          onMapEvent: (p0) {},
          onMapReady: () async {
            await Future.delayed(const Duration(seconds: 1));
            var users = await UserProvider().getRandomUsers();
            _mapController.state = mapState;
            start = true;
          },
        ),
        children: [
          TileLayer(
            urlTemplate: '$baseUrl/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
            backgroundColor: const Color(0xFF202020),
            maxZoom: 19,
          ),

          /* FeatureLayer(
            options: FeatureLayerOptions(
              "https://services.arcgis.com/V6ZHFr6zdgNZuVG0/arcgis/rest/services/Landscape_Trees/FeatureServer/0",
              "point",
            ),
            map: mapState,
            stream: esri(),
          ), */

          NetworkGeoJSONPolygon(mapController: _mapController),
          AssetGeoJSONPolygon(mapController: _mapController),
          StringGeoJSONPolygon(mapController: _mapController),
          FileGeoJSONPolygon(mapController: _mapController),

          const AssetGeoJSONPolyline(),
          //

          const AssetGeoJSONMarkerExample2(),
          const AssetGeoJSONMarker(),
          //   MarkerLayer(markers: getMarkers()),
          CircleOfMap(latLng: latLng),
          const ClustersMarkers(),
        ],
      ),
    );
  }

  double recalc(DestinationDS distanceDMS) {
    const latlong2.Distance distanc = latlong2.Distance();
    final double m = distanc.as(
      latlong2.LengthUnit.Meter,
      latlong2.LatLng(0, 0),
      latlong2.LatLng(0, distanceDMS.dm),
    );
    return m;
  }

  Polygon getPolygon() {
    var polygon = ringsHoled.toPolygon(
      polygonProperties: PolygonProperties(
        fillColor: const Color(0xFF5E0365).withOpacity(0.5),
      ),
    );
    Console.log(polygon.isGeoPointInPolygon(latLng));
    Console.log(polygon.isIntersectedWithPoint(latLng), color: ConsoleColors.teal);
    return polygon;
  }

  Stream<void> esri() async* {
    await Future.delayed(const Duration(seconds: 1));
    yield 1;
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
