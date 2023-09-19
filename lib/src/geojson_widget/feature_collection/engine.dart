import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:power_geojson/power_geojson.dart';
export 'properties.dart';

Future<String> _defaultFileLoadBuilder(String path) async {
  final file = File(path);
  var readasstring = await file.readAsString();
  return readasstring;
}

Future<String> _defaultNetworkLoader(
    Client? client, Uri uri, Map<String, String>? headers) async {
  var method = client == null ? get : client.get;
  var response = await method(uri, headers: headers);
  var string = response.body;
  return string;
}

Future<Widget> _fileFeatureCollections(
  String path, {
  required FeatureCollectionProperties featureCollectionLayerProperties,
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  required Future<String> Function(String filePath) fileLoadBuilder,
  MapController? mapController,
  bool polylineCulling = false,
  bool polygonCulling = false,
  Key? key,
}) async {
  final readasstring = await fileLoadBuilder(path);
  return _string(
    readasstring,
    featureCollectionPropertie: featureCollectionLayerProperties,
    mapController: mapController,
    key: key,
    polygonCulling: polygonCulling,
    polylineCulling: polygonCulling,
    builder: builder,
  );
}

Future<Widget> _memoryFeatureCollections(
  Uint8List list, {
  required FeatureCollectionProperties featureCollectionLayerProperties,
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  MapController? mapController,
  bool polylineCulling = false,
  bool polygonCulling = false,
  Key? key,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    featureCollectionPropertie: featureCollectionLayerProperties,
    mapController: mapController,
    key: key,
    polygonCulling: polygonCulling,
    polylineCulling: polygonCulling,
    builder: builder,
  );
}

Future<Widget> _assetFeatureCollections(
  String path, {
  required FeatureCollectionProperties featureCollectionProperties,
  bool polylineCulling = false,
  bool polygonCulling = false,
  MapController? mapController,
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  Key? key,
}) async {
  final string = await rootBundle.loadString(path);
  return _string(
    string,
    featureCollectionPropertie: featureCollectionProperties,
    mapController: mapController,
    key: key,
    polygonCulling: polygonCulling,
    polylineCulling: polygonCulling,
    builder: builder,
  );
}

Future<Widget> _networkFeatureCollections(
  Uri uri, {
  required FeatureCollectionProperties featureCollectionLayerProperties,
  Key? key,
  Client? client,
  Map<String, String>? headers,
  bool polylineCulling = false,
  bool polygonCulling = false,
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  required Future<String> Function(
          Client? client, Uri uri, Map<String, String>? map)
      networkLoadBuilder,
  MapController? mapController,
}) async {
  String string = await networkLoadBuilder(client, uri, headers);
  return _string(
    string,
    featureCollectionPropertie: featureCollectionLayerProperties,
    mapController: mapController,
    key: key,
    polygonCulling: polygonCulling,
    polylineCulling: polygonCulling,
    builder: builder,
  );
}

Widget _string(
  String json, {
  Key? key,
  //featureCollection props
  required Widget Function(
          FeatureCollectionProperties featureCollectionProperties,
          Map<String, dynamic>? map)
      builder,
  required FeatureCollectionProperties featureCollectionPropertie,
  bool polylineCulling = false,
  bool polygonCulling = false, // others
  MapController? mapController,
}) {
  PowerGeoJSONFeatureCollection parseGeoJSON =
      PowerGeoJSONFeatureCollection.fromJson(json);
  var points = parseGeoJSON.geoJSONPoints
      .map(
        (e) => e.geometry.coordinates.toMarker(
          markerProperties: featureCollectionPropertie.markerProperties,
          builder: (context) => builder(
            featureCollectionPropertie,
            e.properties,
          ),
        ),
      )
      .toList();
  var firstMarker = points.firstOrNull;
  return Stack(
    key: key,
    children: [
      MarkerLayer(
        rotate: firstMarker?.rotate ?? false,
        rotateAlignment: firstMarker?.rotateAlignment,
        rotateOrigin: firstMarker?.rotateOrigin,
        anchorPos: firstMarker?.anchorPos,
        markers: points,
      ),
      PolylineLayer(
        polylines: parseGeoJSON.geoJSONLineStrings
            .map(
              (e) => e.geometry.coordinates.toPolyline(
                polylineProperties:
                    featureCollectionPropertie.polylineProperties,
              ),
            )
            .toList(),
        polylineCulling: polylineCulling,
      ),
      PolygonLayer(
        polygons: parseGeoJSON.geoJSONPolygons
            .map(
              (e) => e.geometry.coordinates.toPolygon(
                polygonProperties: featureCollectionPropertie.polygonProperties,
              ),
            )
            .toList(),
        polygonCulling: polygonCulling,
      ),
    ],
  );
}

class PowerGeoJSONFeatureCollections {
  /// Fetches featureCollections from a network source.
  ///
  /// [polygonProperties] is a map containing properties to customize the appearance of featureCollections.
  /// [layerProperties] specifies the layer options for rendering the featureCollections.
  ///
  /// Returns a [Widget] representing the fetched featureCollections.
  static Future<Widget> network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    required Widget Function(
      FeatureCollectionProperties featureCollectionProperties,
      Map<String, dynamic>? map,
    ) builder,
    required FeatureCollectionProperties featureCollectionProperties,
    bool polylineCulling = false,
    bool polygonCulling = false,
    MapController? mapController,
    Future<String> Function(Client? client, Uri uri, Map<String, String>? map)?
        networkLoadBuilder,
    Key? key,
  }) {
    var uri = url.toUri();
    return _networkFeatureCollections(
      uri,
      headers: headers,
      client: client,
      featureCollectionLayerProperties: featureCollectionProperties,
      networkLoadBuilder: networkLoadBuilder ?? _defaultNetworkLoader,
      builder: builder,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      mapController: mapController,
      key: key,
    );
  }

  static Future<Widget> asset(
    String url, {
    required FeatureCollectionProperties featureCollectionProperties,
    bool polylineCulling = false,
    bool polygonCulling = false,
    MapController? mapController,
    required Widget Function(
            FeatureCollectionProperties featureCollectionProperties,
            Map<String, dynamic>? map)
        builder,
    Key? key,
  }) {
    return _assetFeatureCollections(
      url,
      featureCollectionProperties: featureCollectionProperties,
      mapController: mapController,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      builder: builder,
      key: key,
    );
  }

  static Future<Widget> file(
    String path, {
    required FeatureCollectionProperties featureCollectionProperties,
    bool polylineCulling = false,
    bool polygonCulling = false,
    MapController? mapController,
    Key? key,
    Future<String> Function(String)? fileLoadBuilder,
    required Widget Function(
            FeatureCollectionProperties featureCollectionProperties,
            Map<String, dynamic>? map)
        builder,
  }) {
    return _fileFeatureCollections(
      path,
      featureCollectionLayerProperties: featureCollectionProperties,
      mapController: mapController,
      builder: builder,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      fileLoadBuilder: fileLoadBuilder ?? _defaultFileLoadBuilder,
      key: key,
    );
  }

  static Future<Widget> memory(
    Uint8List bytes, {
    required FeatureCollectionProperties featureCollectionLayerProperties,
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    bool polygonCulling = false,
    required Widget Function(
            FeatureCollectionProperties featureCollectionProperties,
            Map<String, dynamic>? map)
        builder,
  }) {
    return _memoryFeatureCollections(
      bytes,
      featureCollectionLayerProperties: featureCollectionLayerProperties,
      mapController: mapController,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      builder: builder,
      key: key,
    );
  }

  static Widget string(
    String data, {
    required FeatureCollectionProperties featureCollectionProperties,
    bool polylineCulling = false,
    bool polygonCulling = false,
    MapController? mapController,
    Key? key,
    required Widget Function(
            FeatureCollectionProperties featureCollectionProperties,
            Map<String, dynamic>? properties)
        builder,
  }) {
    return _string(
      data,
      featureCollectionPropertie: featureCollectionProperties,
      key: key,
      builder: builder,
      polygonCulling: polygonCulling,
      polylineCulling: polygonCulling,
      mapController: mapController,
    );
  }
}
