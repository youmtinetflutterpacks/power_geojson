import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart';
import 'package:power_geojson/power_geojson.dart';

Future<Widget> _filePolylines(
  String path, {
  required PolylineProperties polylineProperties,
  Polyline Function(
          PolylineProperties polylineProperties, Map<String, dynamic>? map)?
      builder,
  MapController? mapController,
  Key? key,
  bool polylineCulling = false,
}) async {
  final file = File(path);
  var exists = await file.exists();
  if (exists) {
    var readasstring = await file.readAsString();
    return _string(
      readasstring,
      polylineProperties: polylineProperties,
      builder: builder,
      mapController: mapController,
      key: key,
      polylineCulling: polylineCulling,
    );
  } else {
    return const Text('Not Found');
  }
}

Future<Widget> _memoryPolylines(
  Uint8List list, {
  required PolylineProperties polylineProperties,
  Polyline Function(
          PolylineProperties polylineProperties, Map<String, dynamic>? map)?
      builder,
  MapController? mapController,
  Key? key,
  bool polylineCulling = false,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    polylineProperties: polylineProperties,
    builder: builder,
    mapController: mapController,
    key: key,
    polylineCulling: polylineCulling,
  );
}

Future<Widget> _assetPolylines(
  String path, {
  required PolylineProperties polylineProperties,
  Polyline Function(
          PolylineProperties polylineProperties, Map<String, dynamic>? map)?
      builder,
  MapController? mapController,
  Key? key,
  bool polylineCulling = false,
}) async {
  final string = await rootBundle.loadString(path);
  return _string(
    string,
    polylineProperties: polylineProperties,
    builder: builder,
    mapController: mapController,
    key: key,
    polylineCulling: polylineCulling,
  );
}

Future<Widget> _networkPolylines(
  Uri urlString, {
  Client? client,
  Map<String, String>? headers,
  Key? key,
  required PolylineProperties polylineProperties,
  Polyline Function(
          PolylineProperties polylineProperties, Map<String, dynamic>? map)?
      builder,
  MapController? mapController,
  bool polylineCulling = false,
}) async {
  var method = client == null ? get : client.get;
  var response = await method(urlString, headers: headers);
  var string = response.body;
  return _string(
    string,
    polylineProperties: polylineProperties,
    builder: builder,
    mapController: mapController,
    key: key,
    polylineCulling: polylineCulling,
  );
}

Widget _string(
  String string, {
  Key? key,
  required PolylineProperties polylineProperties,
  Polyline Function(
          PolylineProperties polylineProperties, Map<String, dynamic>? map)?
      builder,
  MapController? mapController,
  required bool polylineCulling,
}) {
  final geojson = PowerGeoJSONFeatureCollection.fromJson(string);

  var polylines = geojson.geoJSONLineStrings.map(
    (e) {
      return builder != null
          ? builder(polylineProperties, e.properties)
          : e.geometry.coordinates.toPolyline(
              polylineProperties:
                  PolylineProperties.fromMap(e.properties, polylineProperties),
            );
    },
  ).toList();

  List<List<double>?> bbox = geojson.geoJSONPoints.map((e) => e.bbox).toList();
  zoomTo(bbox, mapController);
  return PolylineLayer(
    polylines: polylines,
    key: key,
    polylineCulling: polylineCulling,
  );
}

class PowerGeoJSONPolylines {
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    // layer
    Key? key,
    PolylineProperties polylineProperties = const PolylineProperties(),
    Polyline Function(
            PolylineProperties polylineProperties, Map<String, dynamic>? map)?
        builder,
    MapController? mapController,
    bool polylineCulling = false,
  }) {
    var uriString = url.toUri();
    return FutureBuilder(
      future: _networkPolylines(
        uriString,
        headers: headers,
        client: client,
        polylineProperties: polylineProperties,
        builder: builder,
        mapController: mapController,
        key: key,
        polylineCulling: polylineCulling,
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
    PolylineProperties polylineProperties = const PolylineProperties(),
    Polyline Function(
            PolylineProperties polylineProperties, Map<String, dynamic>? map)?
        builder,
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
  }) {
    return FutureBuilder(
      future: _assetPolylines(
        url,
        polylineProperties: polylineProperties,
        builder: builder,
        mapController: mapController,
        key: key,
        polylineCulling: polylineCulling,
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
    PolylineProperties polylineProperties = const PolylineProperties(),
    Polyline Function(
            PolylineProperties polylineProperties, Map<String, dynamic>? map)?
        builder,
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
  }) {
    return FutureBuilder(
      future: _filePolylines(
        path,
        polylineProperties: polylineProperties,
        builder: builder,
        mapController: mapController,
        polylineCulling: polylineCulling,
        key: key,
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
    PolylineProperties polylineProperties = const PolylineProperties(),
    Polyline Function(
            PolylineProperties polylineProperties, Map<String, dynamic>? map)?
        builder,
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
  }) {
    return FutureBuilder(
      future: _memoryPolylines(
        bytes,
        polylineProperties: polylineProperties,
        builder: builder,
        mapController: mapController,
        key: key,
        polylineCulling: polylineCulling,
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
    PolylineProperties polylineProperties = const PolylineProperties(),
    Polyline Function(
            PolylineProperties polylineProperties, Map<String, dynamic>? map)?
        builder,
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
  }) {
    return _string(
      data,
      polylineProperties: polylineProperties,
      builder: builder,
      key: key,
      polylineCulling: polylineCulling,
      mapController: mapController,
    );
  }
}
