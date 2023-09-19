import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:power_geojson/power_geojson.dart';
export 'properties.dart';

Future<Widget> _filePolygons(
  String path, {
  Polygon Function(
          List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
      builder,
  PolygonProperties? polygonProperties,
  MapController? mapController,
  Key? key,
  bool polygonCulling = false,
}) async {
  final file = File(path);
  var exists = await file.exists();
  if (exists) {
    var readasstring = await file.readAsString();
    return _string(
      readasstring,
      builder: builder,
      polygonProperties: polygonProperties,
      polygonCulling: polygonCulling,
      mapController: mapController,
      key: key,
    );
  } else {
    return const Text('Not Found');
  }
}

Future<Widget> _memoryPolygons(
  Uint8List list, {
  Polygon Function(
          List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
      builder,
  PolygonProperties? polygonProperties,
  bool polygonCulling = false,
  Key? key,
  MapController? mapController,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    builder: builder,
    polygonProperties: polygonProperties,
    key: key,
    polygonCulling: polygonCulling,
    mapController: mapController,
  );
}

Future<Widget> _assetPolygons(
  String path, {
  Polygon Function(
          List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
      builder,
  PolygonProperties? polygonProperties,
  bool polygonCulling = false,
  Key? key,
  MapController? mapController,
}) async {
  final string = await rootBundle.loadString(path);
  return _string(
    string,
    builder: builder,
    polygonProperties: polygonProperties,
    key: key,
    polygonCulling: polygonCulling,
    mapController: mapController,
  );
}

Future<Widget> _networkPolygons(
  Uri urlString, {
  Polygon Function(
          List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
      builder,
  Client? client,
  Map<String, String>? headers,
  PolygonProperties? polygonProperties,
  bool polygonCulling = false,
  Key? key,
  MapController? mapController,
}) async {
  var method = client == null ? get : client.get;
  var response = await method(urlString, headers: headers);
  var string = response.body;
  return _string(
    string,
    builder: builder,
    polygonProperties: polygonProperties,
    key: key,
    polygonCulling: polygonCulling,
    mapController: mapController,
  );
}

Widget _string(
  String string, {
  Polygon Function(
          List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
      builder,
  // layer
  Key? key,
  bool polygonCulling = false,
  PolygonProperties? polygonProperties,
  MapController? mapController,
}) {
  final geojson = PowerGeoJSONFeatureCollection.fromJson(string);

  var polygons = geojson.geoJSONPolygons.map(
    (e) {
      return builder != null
          ? builder(e.geometry.coordinates, e.properties)
          : e.geometry.coordinates.toPolygon(
              polygonProperties: PolygonProperties.fromMap(
                  e.properties, polygonProperties ?? const PolygonProperties()),
            );
    },
  ).toList();

  List<List<double>?> bbox = geojson.geoJSONPoints.map((e) => e.bbox).toList();
  zoomTo(bbox, mapController);
  return PolygonLayer(
    polygons: polygons,
    key: key,
    polygonCulling: polygonCulling,
  );
}

class PowerGeoJSONPolygons {
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    // layer
    Key? key,
    bool polygonCulling = false,
    Polygon Function(
            List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
        builder,
    PolygonProperties? polygonProperties,
    MapController? mapController,
  }) {
    assert((builder == null && polygonProperties != null) ||
        (polygonProperties == null && builder != null));
    var uriString = url.toUri();
    return FutureBuilder(
      future: _networkPolygons(
        uriString,
        builder: builder,
        headers: headers,
        client: client,
        polygonProperties: polygonProperties,
        key: key,
        polygonCulling: polygonCulling,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

  static Widget asset(
    String url, {
    // layer
    Key? key,
    bool polygonCulling = false,
    Polygon Function(
            List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
        builder,
    PolygonProperties? polygonProperties,
    MapController? mapController,
  }) {
    assert((builder == null && polygonProperties != null) ||
        (polygonProperties == null && builder != null));
    return FutureBuilder(
      future: _assetPolygons(
        url,
        builder: builder,
        polygonProperties: polygonProperties,
        key: key,
        polygonCulling: polygonCulling,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

  static Widget file(
    String path, {
    // layer
    Key? key,
    bool polygonCulling = false,
    PolygonProperties? polygonProperties,
    Polygon Function(
            List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
        builder,
    MapController? mapController,
  }) {
    assert((builder == null && polygonProperties != null) ||
        (polygonProperties == null && builder != null));
    return FutureBuilder(
      future: _filePolygons(
        path,
        builder: builder,
        polygonProperties: polygonProperties,
        key: key,
        polygonCulling: polygonCulling,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

  static Widget memory(
    Uint8List bytes, {
    // layer
    Key? key,
    bool polygonCulling = false,
    PolygonProperties? polygonProperties,
    Polygon Function(
            List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
        builder,
    MapController? mapController,
  }) {
    assert((builder == null && polygonProperties != null) ||
        (polygonProperties == null && builder != null));
    return FutureBuilder(
      future: _memoryPolygons(
        bytes,
        builder: builder,
        polygonProperties: polygonProperties,
        key: key,
        polygonCulling: polygonCulling,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

  static Widget string(
    String data, {
    // layer
    Key? key,
    bool polygonCulling = false,
    Polygon Function(
            List<List<List<double>>> coordinates, Map<String, dynamic>? map)?
        builder,
    PolygonProperties? polygonProperties,
    MapController? mapController,
  }) {
    assert((builder == null && polygonProperties != null) ||
        (polygonProperties == null && builder != null));
    return _string(
      data,
      builder: builder,
      polygonProperties: polygonProperties,
      key: key,
      polygonCulling: polygonCulling,
      mapController: mapController,
    );
  }
}
