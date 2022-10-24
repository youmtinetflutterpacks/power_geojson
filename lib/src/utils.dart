import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:dart_jts/dart_jts.dart' as dart_jts;
import 'package:power_geojson/src/geodesy.dart';

double dmFromMeters(double distanceMETERS) {
  Geodesy geodesy = Geodesy();
  var origin = latlong2.LatLng(0, 0);
  var destination = geodesy.destinationPointByDistanceAndBearing(
    origin,
    distanceMETERS + 0.0,
    -10 + 0.0,
  );
  var distanceDMS = (origin.latitude - destination.latitude).abs();
  /* DestinationDS(destination: destination, dm:  */ /* ) */
  return distanceDMS;
}

Polygon calcBuffer(double distanceDMS, List<List<double>> ring) {
  var precesion = dart_jts.PrecisionModel.fixedPrecision(0);
  final geometryFactory = dart_jts.GeometryFactory.defaultPrecision();
  var listCoordinate = ring.map((e) => dart_jts.Coordinate(e[0], e[1])).toList();
  var listLinearRing = dart_jts.LinearRing(listCoordinate, precesion, 10);
  final polygons = geometryFactory.createPolygon(listLinearRing, null);
  final buffer = dart_jts.BufferOp.bufferOp3(polygons, distanceDMS, 10);
  var bufferBolygon = buffer as dart_jts.Polygon;
  var listPointsPolygon = bufferBolygon.shell!.points
      .toCoordinateArray()
      .map((e) => latlong2.LatLng(e.x, e.y))
      .toList();
  var polygon = Polygon(
    points: listPointsPolygon,
    isFilled: true,
    color: const Color(0xFFF321D0).withOpacity(0.5),
  );
  return polygon;
}

Future<Directory> getDocumentsDir() async => await path_provider.getApplicationDocumentsDirectory();

Future<List<Directory>?> getExternalDir() async {
  var externalStorageDirectories = await path_provider.getExternalStorageDirectories();
  return externalStorageDirectories;
}
