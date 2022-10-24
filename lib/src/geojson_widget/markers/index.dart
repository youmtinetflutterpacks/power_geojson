import 'dart:convert';
import 'dart:io';
import 'package:console_tools/console_tools.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geojson_vi/geojson_vi.dart';
import 'package:http/http.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:power_geojson/src/data.dart';
import 'package:power_geojson/src/extensions/extensions.dart';
import 'package:power_geojson/src/extensions/marker.dart';
import 'package:power_geojson/src/geojson_widget/markers/properties.dart';
import 'package:power_geojson/src/geojson_widget/polygon/properties.dart';
import 'package:power_geojson/src/utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
export 'properties.dart';
export 'create_circle.dart';

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

Future<Widget> _fileMarkers(
  String path, {
  Map<LayerPolygonIndexes, String>? layerProperties,
  required MarkerProperties markerLayerProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Offset? rotateOrigin,
  AlignmentGeometry? rotateAlignment = Alignment.center,
  bool rotate = false,
  Key? key,
}) async {
  final file = File(path);
  var exists = await file.exists();
  if (exists) {
    var readasstring = await file.readAsString();
    return _string(
      readasstring,
      markerPropertie: markerLayerProperties,
      mapController: mapController,
      key: key,
      bufferOptions: bufferOptions,
      layerBufferProperties: layerProperties,
      rotateAlignment: rotateAlignment,
      rotateOrigin: rotateOrigin,
      rotate: rotate,
    );
  } else {
    return const SizedBox();
  }
}

Future<Widget> _memoryMarkers(
  Uint8List list, {
  Map<LayerPolygonIndexes, String>? layerProperties,
  required MarkerProperties markerLayerProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Offset? rotateOrigin,
  AlignmentGeometry? rotateAlignment = Alignment.center,
  bool rotate = false,
  Key? key,
}) async {
  File file = File.fromRawPath(list);
  var string = await file.readAsString();
  return _string(
    string,
    markerPropertie: markerLayerProperties,
    mapController: mapController,
    key: key,
    bufferOptions: bufferOptions,
    layerBufferProperties: layerProperties,
    rotateAlignment: rotateAlignment,
    rotateOrigin: rotateOrigin,
    rotate: rotate,
  );
}

Future<Widget> _assetMarkers(
  String path, {
  Map<LayerPolygonIndexes, String>? layerProperties,
  required MarkerProperties markerProperties,
  MapController? mapController,
  //
  BufferOptions? bufferOptions,
  Offset? rotateOrigin,
  AlignmentGeometry? rotateAlignment = Alignment.center,
  bool rotate = false,
  Key? key,
}) async {
  final string = await rootBundle.loadString(path);
  await _createFile();
  return _string(
    string,
    markerPropertie: markerProperties,
    mapController: mapController,
    //
    key: key,
    bufferOptions: bufferOptions,
    layerBufferProperties: layerProperties,
    rotateAlignment: rotateAlignment,
    rotateOrigin: rotateOrigin,
    rotate: rotate,
  );
}

Future<Widget> _networkMarkers(
  Uri urlString, {
  Client? client,
  Map<String, String>? headers,
  Map<LayerPolygonIndexes, String>? layerProperties,
  required MarkerProperties markerLayerProperties,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Offset? rotateOrigin,
  AlignmentGeometry? rotateAlignment = Alignment.center,
  bool rotate = false,
  Key? key,
}) async {
  var method = client == null ? get : client.get;
  var response = await method(urlString, headers: headers);
  var string = response.body;
  return _string(
    string,
    markerPropertie: markerLayerProperties,
    mapController: mapController,
    key: key,
    bufferOptions: bufferOptions,
    layerBufferProperties: layerProperties,
    rotateAlignment: rotateAlignment,
    rotateOrigin: rotateOrigin,
    rotate: rotate,
  );
}

class CercleMarker {
  CircleLayer circleLayer;
  List<Marker> markers;
  CercleMarker({required this.circleLayer, required this.markers});
}

Widget _string(
  String string, {
  required MarkerProperties markerPropertie,
  MapController? mapController,
  BufferOptions? bufferOptions,
  Key? key,
  AlignmentGeometry? rotateAlignment = Alignment.center,
  Offset? rotateOrigin,
  bool rotate = false,
  Map<LayerPolygonIndexes, String>? layerBufferProperties,
}) {
  final geojson = GeoJSONFeatureCollection.fromMap(jsonDecode(string));

  var features = geojson.features;
  List<CercleMarker> markers = List.generate(features.length, (int index) {
    GeoJSONFeature? elm = features[index];
    List<Marker> listMarkers = [];
    const PolygonProperties polygonDefault = PolygonProperties();
    PolygonProperties polygonProperties = polygonDefault;
    if (bufferOptions != null) {
      var polygonBufferProperties = bufferOptions.polygonBufferProperties;
      if (polygonBufferProperties != null) {
        Console.log(polygonBufferProperties.fillColor);
        polygonProperties = polygonBufferProperties;
      }
    }
    if (elm != null) {
      var geometry = elm.geometry;
      var props = elm.properties;
      var layerBuffer = layerBufferProperties;
      var markerPropsFromMap = MarkerProperties.fromMap(props, layerBuffer, markerPropertie);
      var layerPropsFromMap = PolygonProperties.fromMap(props, layerBuffer);
      polygonProperties = layerPropsFromMap;

      zoomTo(elm, mapController);
      if (geometry is GeoJSONPoint) {
        listMarkers = [geometry.coordinates.toMarker(markerProperties: markerPropsFromMap)];
      } else if (geometry is GeoJSONMultiPoint) {
        var coordinates = geometry.coordinates;
        listMarkers = [...coordinates.map((e) => e.toMarker(markerProperties: markerPropsFromMap))];
      }
    } else {
      listMarkers = ifElmNull;
    }

    return CercleMarker(
      circleLayer: CircleLayer(
        circles: listMarkers.toBuffers(
          bufferOptions != null ? bufferOptions.buffer : 0,
          polygonProperties,
        ),
        key: key,
      ),
      markers: listMarkers,
    );
  });
  return Stack(
    children: [
      if (bufferOptions != null) ...markers.map((e) => e.circleLayer),
      if ((bufferOptions != null && !bufferOptions.buffersOnly) || bufferOptions == null)
        ...markers.map(
          (e) {
            return MarkerLayer(
              rotate: rotate,
              rotateAlignment: rotateAlignment,
              rotateOrigin: rotateOrigin,
              markers: e.markers,
              key: key,
            );
          },
        ),
    ],
  );
}

List<Marker> get ifElmNull {
  return [
    Marker(
      point: latlong2.LatLng(0, 0),
      builder: (BuildContext context) {
        return const SizedBox();
      },
    ),
  ];
}

void zoomTo(GeoJSONFeature elm, MapController? mapController) {
  var bbox = elm.bbox;
  if (bbox != null && mapController != null) {
    var latLngBounds = LatLngBounds(
      latlong2.LatLng(bbox[1], bbox[0]),
      latlong2.LatLng(bbox[3], bbox[2]),
    );
    mapController.fitBounds(latLngBounds);
  }
}

//format('#{:06%1%2%3}',rand(0,255),rand(0,255),rand(0,255))
class PowerGeoJSONMarkers {
  static Widget network(
    String url, {
    Client? client,
    Map<String, String>? headers,
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    bool rotate = false,
    BufferOptions? bufferOptions,
    AlignmentGeometry? rotateAlignment = Alignment.center,
    Offset? rotateOrigin,
  }) {
    var uriString = url.toUri();
    return FutureBuilder(
      future: _networkMarkers(
        uriString,
        headers: headers,
        client: client,
        layerProperties: layerBufferProperties,
        markerLayerProperties: markerLayerProperties,
        mapController: mapController,
        bufferOptions: bufferOptions,
        key: key,
        rotate: rotate,
        rotateAlignment: rotateAlignment,
        rotateOrigin: rotateOrigin,
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
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    required MarkerProperties markerProperties,
    MapController? mapController,
    BufferOptions? bufferOptions,
    Key? key,
    bool rotate = false,
    AlignmentGeometry? rotateAlignment = Alignment.center,
    Offset? rotateOrigin,
  }) {
    return FutureBuilder(
      future: _assetMarkers(
        url,
        layerProperties: layerBufferProperties,
        markerProperties: markerProperties,
        mapController: mapController,
        bufferOptions: bufferOptions,
        key: key,
        rotate: rotate,
        rotateAlignment: rotateAlignment,
        rotateOrigin: rotateOrigin,
      ),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.done) {
          if (snap.hasData) {
            // Map<LayerPolygonIndexes, String> layerProps = layerBufferProperties ?? {LayerPolygonIndexes.fillColor:"color"};
            return snap.data ?? const SizedBox();
          }
        } else if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CupertinoActivityIndicator());
        }
        return const SizedBox();
      },
    );
  }

// The argument type 'Map<LayerPolygonIndexes, String>?' can't be assigned to
//the parameter type 'Map<LayerPolygonIndexes, String>?'
  static Widget file(
    String path, {
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    bool rotate = false,
    BufferOptions? bufferOptions,
    AlignmentGeometry? rotateAlignment = Alignment.center,
    Offset? rotateOrigin,
  }) {
    return FutureBuilder(
      future: _fileMarkers(
        path,
        layerProperties: layerBufferProperties,
        markerLayerProperties: markerLayerProperties,
        mapController: mapController,
        bufferOptions: bufferOptions,
        key: key,
        rotate: rotate,
        rotateAlignment: rotateAlignment,
        rotateOrigin: rotateOrigin,
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
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    bool rotate = false,
    BufferOptions? bufferOptions,
    AlignmentGeometry? rotateAlignment = Alignment.center,
    Offset? rotateOrigin,
  }) {
    return FutureBuilder(
      future: _memoryMarkers(
        bytes,
        layerProperties: layerBufferProperties,
        markerLayerProperties: markerLayerProperties,
        mapController: mapController,
        bufferOptions: bufferOptions,
        key: key,
        rotate: rotate,
        rotateAlignment: rotateAlignment,
        rotateOrigin: rotateOrigin,
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
    Map<LayerPolygonIndexes, String>? layerBufferProperties,
    required MarkerProperties markerLayerProperties,
    MapController? mapController,
    Key? key,
    bool rotate = false,
    AlignmentGeometry? rotateAlignment = Alignment.center,
    Offset? rotateOrigin,
    BufferOptions? bufferOptions,
  }) {
    return _string(
      data,
      markerPropertie: markerLayerProperties,
      key: key,
      bufferOptions: bufferOptions,
      layerBufferProperties: layerBufferProperties,
      rotateAlignment: rotateAlignment,
      rotateOrigin: rotateOrigin,
      rotate: rotate,
    );
  }
}
