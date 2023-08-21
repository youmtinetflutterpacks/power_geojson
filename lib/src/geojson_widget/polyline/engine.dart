import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:http/http.dart';
import 'package:power_geojson/power_geojson.dart';

class BufferPolyline {
  PolygonLayer bufferLayer;
  PolylineLayer polylines;
  BufferPolyline({required this.bufferLayer, required this.polylines});
}

Future<Widget> _filePolylines(
  String path, {
  required PolylineProperties polylineLayerProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Key? key,
  bool polylineCulling = false,
}) async {
  final file = File(path);
  var exists = await file.exists();
  if (exists) {
    var readasstring = await file.readAsString();
    return _string(
      readasstring,
      polylinePropertie: polylineLayerProperties,
      mapController: mapController,
      key: key,
      bufferOptions: bufferOptions,
      polylineCulling: polylineCulling,
    );
  } else {
    return const Text('Not Found');
  }
}

Future<Widget> _memoryPolylines(
  Uint8List list, {
  required PolylineProperties polylineLayerProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Key? key,
  bool polylineCulling = false,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    polylinePropertie: polylineLayerProperties,
    mapController: mapController,
    bufferOptions: bufferOptions,
    key: key,
    polylineCulling: polylineCulling,
  );
}

Future<Widget> _assetPolylines(
  String path, {
  required PolylineProperties polylineProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Key? key,
  bool polylineCulling = false,
}) async {
  final string = await rootBundle.loadString(path);
  return _string(
    string,
    polylinePropertie: polylineProperties,
    mapController: mapController,
    bufferOptions: bufferOptions,
    key: key,
    polylineCulling: polylineCulling,
  );
}

Future<Widget> _networkPolylines(
  Uri urlString, {
  Client? client,
  Map<String, String>? headers,
  Key? key,
  required PolylineProperties polylineLayerProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
  bool polylineCulling = false,
}) async {
  var method = client == null ? get : client.get;
  var response = await method(urlString, headers: headers);
  var string = response.body;
  return _string(
    string,
    polylinePropertie: polylineLayerProperties,
    mapController: mapController,
    bufferOptions: bufferOptions,
    key: key,
    polylineCulling: polylineCulling,
  );
}

Widget _string(
  String string, {
  Key? key,
  required PolylineProperties polylinePropertie,
  MapController? mapController,
  BufferOptions? bufferOptions,
  required bool polylineCulling,
}) {
  final geojson = GeoJSONFeatureCollection.fromMap(jsonDecode(string));

  var features = geojson.features;
  List<List<Widget>> polylines = features.map((feature) {
    List<Polyline> listPolylines = [];
    PolygonProperties polygonBufferProperties = const PolygonProperties();
    if (feature != null) {
      var geometry = feature.geometry;
      var properties = feature.properties;

      PolylineProperties polylineProperties = PolylineProperties.fromMap(properties, polylinePropertie);
      polygonBufferProperties = PolygonProperties.fromMap(properties, getBufferProperties(bufferOptions));

      if (geometry is GeoJSONLineString) {
        listPolylines = [geometry.coordinates.toPolyline(polylineProperties: polylineProperties)];
      } else if (geometry is GeoJSONMultiLineString) {
        var coordinates = geometry.coordinates;
        listPolylines = coordinates.map((e) {
          return e.toPolyline(polylineProperties: polylineProperties);
        }).toList();
      }
    }
    zoomTo(features, mapController);

    var fStack = [
      if (bufferOptions != null)
        PolygonLayer(
          polygons: listPolylines.toBuffers(
            bufferOptions.buffer,
            polygonBufferProperties,
          ),
          key: key,
        ),
      if ((bufferOptions != null && !bufferOptions.buffersOnly) || bufferOptions == null)
        PolylineLayer(
          polylineCulling: polylineCulling,
          polylines: listPolylines,
          key: key,
        ),
    ];
    return fStack;
  }).toList();
  return Stack(children: polylines.expand((element) => element).toList());
}

class PowerGeoJSONPolylines {
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    // layer
    Key? key,
    PolylineProperties polylineLayerProperties = const PolylineProperties(),
    MapController? mapController,
    bool polylineCulling = false,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    var uriString = url.toUri();
    return FutureBuilder(
      future: _networkPolylines(
        uriString,
        headers: headers,
        client: client,
        polylineLayerProperties: polylineLayerProperties,
        mapController: mapController,
        key: key,
        bufferOptions: bufferOptions,
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
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _assetPolylines(
        url,
        polylineProperties: polylineProperties,
        mapController: mapController,
        bufferOptions: bufferOptions,
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
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _filePolylines(
        path,
        polylineLayerProperties: polylineProperties,
        mapController: mapController,
        polylineCulling: polylineCulling,
        key: key,
        bufferOptions: bufferOptions,
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
    PolylineProperties polylineLayerProperties = const PolylineProperties(),
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _memoryPolylines(
        bytes,
        polylineLayerProperties: polylineLayerProperties,
        mapController: mapController,
        key: key,
        bufferOptions: bufferOptions,
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
    PolylineProperties polylineLayerProperties = const PolylineProperties(),
    MapController? mapController,
    Key? key,
    bool polylineCulling = false,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    return _string(
      data,
      polylinePropertie: polylineLayerProperties,
      bufferOptions: bufferOptions,
      key: key,
      polylineCulling: polylineCulling,
      mapController: mapController,
    );
  }
}
