import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:http/http.dart';
import 'package:power_geojson/power_geojson.dart';
export 'properties.dart';

class BufferPolygon {
  PolygonLayer bufferLayer;
  List<Polygon> polygons;
  BufferPolygon({required this.bufferLayer, required this.polygons});
}

Future<Widget> _filePolygons(
  String path, {
  required PolygonProperties polygonLayerProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Key? key,
  bool polygonCulling = false,
}) async {
  final file = File(path);
  var exists = await file.exists();
  if (exists) {
    var readasstring = await file.readAsString();
    return _string(
      readasstring,
      polygonProperties: polygonLayerProperties,
      bufferOptions: bufferOptions,
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
  required PolygonProperties polygonLayerProperties,
  bool polygonCulling = false,
  BufferOptions? bufferOptions,
  Key? key,
  MapController? mapController,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    polygonProperties: polygonLayerProperties,
    key: key,
    bufferOptions: bufferOptions,
    polygonCulling: polygonCulling,
    mapController: mapController,
  );
}

Future<Widget> _assetPolygons(
  String path, {
  required PolygonProperties polygonLayerProperties,
  bool polygonCulling = false,
  Key? key,
  BufferOptions? bufferOptions,
  MapController? mapController,
}) async {
  final string = await rootBundle.loadString(path);
  return _string(
    string,
    polygonProperties: polygonLayerProperties,
    key: key,
    bufferOptions: bufferOptions,
    polygonCulling: polygonCulling,
    mapController: mapController,
  );
}

Future<Widget> _networkPolygons(
  Uri urlString, {
  Client? client,
  Map<String, String>? headers,
  required PolygonProperties polygonLayerProperties,
  bool polygonCulling = false,
  Key? key,
  BufferOptions? bufferOptions,
  MapController? mapController,
}) async {
  var method = client == null ? get : client.get;
  var response = await method(urlString, headers: headers);
  var string = response.body;
  return _string(
    string,
    polygonProperties: polygonLayerProperties,
    key: key,
    bufferOptions: bufferOptions,
    polygonCulling: polygonCulling,
    mapController: mapController,
  );
}

Widget _string(
  String string, {
  // layer
  Key? key,
  bool polygonCulling = false,
  PolygonProperties polygonProperties = const PolygonProperties(),
  MapController? mapController,
  // buffer
  BufferOptions? bufferOptions,
}) {
  Console.log(string.length);
  final geojson = GeoJSONFeatureCollection.fromMap(jsonDecode(string));
  var features = geojson.features;
  var polygons = features.map((feature) {
    PolygonProperties polygonBufferProperties = const PolygonProperties();
    List<Polygon> listPolygons = [];
    if (feature != null) {
      var geometry = feature.geometry;
      var properties = feature.properties;
      var polygonnProperties = PolygonProperties.fromMap(properties, polygonProperties);

      polygonBufferProperties = PolygonProperties.fromMap(properties, getBufferProperties(bufferOptions));
      if (geometry is GeoJSONPolygon) {
        listPolygons = [geometry.coordinates.toPolygon(polygonProperties: polygonnProperties)];
      } else if (geometry is GeoJSONMultiPolygon) {
        var coordinates = geometry.coordinates;
        listPolygons = coordinates.map((e) {
          return e.toPolygon(polygonProperties: polygonnProperties);
        }).toList();
      }
    }
    zoomTo(features, mapController);
    return PolygonLayer(
      polygons: bufferOptions != null
          ? bufferOptions.buffersOnly
              ? listPolygons.toBuffers(
                  bufferOptions.buffer,
                  polygonBufferProperties,
                )
              : listPolygons.toBuffersWithOriginals(
                  bufferOptions.buffer,
                  polygonBufferProperties: polygonBufferProperties,
                )
          : listPolygons,
      key: key,
      polygonCulling: polygonCulling,
    );
  }).toList();
  return Stack(children: polygons);
}

class PowerGeoJSONPolygons {
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    // layer
    Key? key,
    bool polygonCulling = false,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    var uriString = url.toUri();
    return FutureBuilder(
      future: _networkPolygons(
        uriString,
        headers: headers,
        client: client,
        polygonLayerProperties: polygonProperties,
        key: key,
        polygonCulling: polygonCulling,
        mapController: mapController,
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

  static Widget asset(
    String url, {
    // layer
    Key? key,
    bool polygonCulling = false,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _assetPolygons(
        url,
        polygonLayerProperties: polygonProperties,
        key: key,
        polygonCulling: polygonCulling,
        mapController: mapController,
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

  static Widget file(
    String path, {
    // layer
    Key? key,
    bool polygonCulling = false,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _filePolygons(
        path,
        polygonLayerProperties: polygonProperties,
        key: key,
        polygonCulling: polygonCulling,
        mapController: mapController,
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
    // layer
    Key? key,
    bool polygonCulling = false,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _memoryPolygons(
        bytes,
        polygonLayerProperties: polygonProperties,
        key: key,
        polygonCulling: polygonCulling,
        mapController: mapController,
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

  static Widget string(
    String data, {
    // layer
    Key? key,
    bool polygonCulling = false,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    // buffer
    BufferOptions? bufferOptions,
  }) {
    return _string(
      data,
      polygonProperties: polygonProperties,
      key: key,
      polygonCulling: polygonCulling,
      mapController: mapController,
      bufferOptions: bufferOptions,
    );
  }
}
