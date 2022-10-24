import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:power_geojson/src/data.dart';
import 'package:power_geojson/src/extensions/extensions.dart';
import 'package:power_geojson/src/extensions/polygon.dart';
import 'package:power_geojson/src/geojson_widget/markers/properties.dart';
import 'package:power_geojson/src/geojson_widget/polygon/properties.dart';
import 'package:power_geojson/src/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'properties.dart';

Future<File> _createFile() async {
  var instance = await SharedPreferences.getInstance();
  /* var pathShared = instance.getString('geojson'); */
  var list = await getExternalDir();
  var directory = ((list == null || list.isEmpty) ? Directory('path') : list[0]).path;
  final path = "$directory/geojson.json";
  final File file = File(path);
  var exists = await file.exists();
  if (!exists) {
    var savedFile = await file.writeAsString(geojsonfile);
    await instance.setString('geojson', savedFile.path);
    return savedFile;
  }
  return file;
}

Future<List<Polygon>> _filePolygons(
  String path, {
  Map<LayerPolygonIndexes, String>? layerProperties,
  required PolygonProperties polygonLayerProperties,
  MapController? mapController,
}) async {
  final file = File(path);
  var exists = await file.exists();
  if (exists) {
    var readasstring = await file.readAsString();
    return _string(
      readasstring,
      layerMap: layerProperties,
      polygonPropertie: polygonLayerProperties,
      mapController: mapController,
    );
  } else {
    return [];
  }
}

Future<List<Polygon>> _memoryPolygons(
  Uint8List list, {
  Map<LayerPolygonIndexes, String>? layerProperties,
  required PolygonProperties polygonLayerProperties,
  MapController? mapController,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    layerMap: layerProperties,
    polygonPropertie: polygonLayerProperties,
    mapController: mapController,
  );
}

Future<List<Polygon>> _assetPolygons(
  String path, {
  Map<LayerPolygonIndexes, String>? layerProperties,
  required PolygonProperties polygonProperties,
  MapController? mapController,
}) async {
  final string = await rootBundle.loadString(path);
  await _createFile();
  return _string(
    string,
    layerMap: layerProperties,
    polygonPropertie: polygonProperties,
    mapController: mapController,
  );
}

Future<List<Polygon>> _networkPolygons(
  Uri urlString, {
  Client? client,
  Map<String, String>? headers,
  Map<LayerPolygonIndexes, String>? layerProperties,
  required PolygonProperties polygonLayerProperties,
  MapController? mapController,
}) async {
  var method = client == null ? get : client.get;
  var response = await method(urlString, headers: headers);
  var string = response.body;
  return _string(
    string,
    layerMap: layerProperties,
    polygonPropertie: polygonLayerProperties,
    mapController: mapController,
  );
}

List<Polygon> _string(
  String string, {
  Map<LayerPolygonIndexes, String>? layerMap,
  required PolygonProperties polygonPropertie,
  MapController? mapController,
}) {
  final geojson = GeoJSONFeatureCollection.fromMap(jsonDecode(string));
  List<List<Polygon>> polygons = geojson.features.map((elm) {
    if (elm != null) {
      var geometry = elm.geometry;
      var properties = elm.properties;
      var polygonProperties = PolygonProperties.fromMap(
        properties,
        layerMap,
        polygonLayerProperties: polygonPropertie,
      );
      if (geometry is GeoJSONPolygon) {
        return [geometry.coordinates.toPolygon(polygonProperties: polygonProperties)];
      } else if (geometry is GeoJSONMultiPolygon) {
        var coordinates = geometry.coordinates;
        return coordinates.map((e) {
          return e.toPolygon(polygonProperties: polygonProperties);
        }).toList();
      }
      var bbox = elm.bbox;
      if (bbox != null && mapController != null) {
        var latLngBounds = LatLngBounds(
          latlong2.LatLng(bbox[1], bbox[0]),
          latlong2.LatLng(bbox[3], bbox[2]),
        );
        mapController.fitBounds(latLngBounds);
      }
    }
    return [Polygon(points: [])];
  }).toList();
  return polygons.expand((element) => element).toList();
}

class PowerGeoJSONPolygons {
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    Map<LayerPolygonIndexes, String>? layerProperties,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    Key? key,
    bool polygonCulling = false,
    BufferOptions? bufferOptions,
  }) {
    var uriString = url.toUri();
    return FutureBuilder(
      future: _networkPolygons(
        uriString,
        headers: headers,
        client: client,
        layerProperties: layerProperties,
        polygonLayerProperties: polygonProperties,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            var polygons2 = snap.data ?? [];
            return PolygonLayer(
              polygons: bufferOptions != null
                  ? bufferOptions.buffersOnly
                      ? polygons2.toBuffers(
                          bufferOptions.buffer,
                          bufferOptions.polygonBufferProperties ?? polygonProperties,
                        )
                      : polygons2.toBuffersWithOriginals(
                          bufferOptions.buffer,
                          bufferOptions.polygonBufferProperties ?? polygonProperties,
                        )
                  : polygons2,
              key: key,
              polygonCulling: polygonCulling,
            );
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
    Map<LayerPolygonIndexes, String>? layerProperties,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    Key? key,
    bool polygonCulling = false,
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _assetPolygons(
        url,
        layerProperties: layerProperties,
        polygonProperties: polygonProperties,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            var polygons2 = snap.data ?? [];
            return PolygonLayer(
              polygons: bufferOptions != null
                  ? bufferOptions.buffersOnly
                      ? polygons2.toBuffers(
                          bufferOptions.buffer,
                          bufferOptions.polygonBufferProperties ?? polygonProperties,
                        )
                      : polygons2.toBuffersWithOriginals(
                          bufferOptions.buffer,
                          bufferOptions.polygonBufferProperties ?? polygonProperties,
                        )
                  : polygons2,
              key: key,
              polygonCulling: polygonCulling,
            );
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
    Map<LayerPolygonIndexes, String>? layerProperties,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    Key? key,
    bool polygonCulling = false,
    BufferOptions? bufferOptions,
  }) {
    return FutureBuilder(
      future: _filePolygons(
        path,
        layerProperties: layerProperties,
        polygonLayerProperties: polygonProperties,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            var polygons2 = snap.data ?? [];
            return PolygonLayer(
              polygons: bufferOptions != null
                  ? bufferOptions.buffersOnly
                      ? polygons2.toBuffers(
                          bufferOptions.buffer,
                          bufferOptions.polygonBufferProperties ?? polygonProperties,
                        )
                      : polygons2.toBuffersWithOriginals(
                          bufferOptions.buffer,
                          bufferOptions.polygonBufferProperties ?? polygonProperties,
                        )
                  : polygons2,
              key: key,
              polygonCulling: polygonCulling,
            );
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
    Map<LayerPolygonIndexes, String>? layerProperties,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    Key? key,
    BufferOptions? bufferOptions,
    bool polygonCulling = false,
  }) {
    return FutureBuilder(
      future: _memoryPolygons(
        bytes,
        layerProperties: layerProperties,
        polygonLayerProperties: polygonProperties,
        mapController: mapController,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            var polygons2 = snap.data ?? [];
            return PolygonLayer(
              polygons: bufferOptions != null
                  ? bufferOptions.buffersOnly
                      ? polygons2.toBuffers(
                          bufferOptions.buffer,
                          bufferOptions.polygonBufferProperties ?? polygonProperties,
                        )
                      : polygons2.toBuffersWithOriginals(
                          bufferOptions.buffer,
                          bufferOptions.polygonBufferProperties ?? polygonProperties,
                        )
                  : polygons2,
              key: key,
              polygonCulling: polygonCulling,
            );
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
    Map<LayerPolygonIndexes, String>? layerProperties,
    PolygonProperties polygonProperties = const PolygonProperties(),
    MapController? mapController,
    Key? key,
    BufferOptions? bufferOptions,
    bool polygonCulling = false,
  }) {
    var polygons2 = _string(
      data,
      polygonPropertie: polygonProperties,
    );
    return PolygonLayer(
      polygons: bufferOptions != null
          ? bufferOptions.buffersOnly
              ? polygons2.toBuffers(
                  bufferOptions.buffer,
                  bufferOptions.polygonBufferProperties ?? polygonProperties,
                )
              : polygons2.toBuffersWithOriginals(
                  bufferOptions.buffer,
                  bufferOptions.polygonBufferProperties ?? polygonProperties,
                )
          : polygons2,
      key: key,
      polygonCulling: polygonCulling,
    );
  }
}
