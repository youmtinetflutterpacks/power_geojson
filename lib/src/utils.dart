import 'dart:io';
import 'package:latlong2/latlong.dart' as latlong2;
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:power_geojson/src/geodesy.dart';

double dmFromMeters(double distanceMETERS) {
  Geodesy geodesy = Geodesy();
  var origin = const latlong2.LatLng(0, 0);
  var destination = geodesy.destinationPointByDistanceAndBearing(
    origin,
    distanceMETERS + 0.0,
    -10 + 0.0,
  );
  var distanceDMS = (origin.latitude - destination.latitude).abs();
  /* DestinationDS(destination: destination, dm:  */ /* ) */
  return distanceDMS;
}

Future<Directory> getDocumentsDir() async => await path_provider.getApplicationDocumentsDirectory();

Future<List<Directory>?> getExternalDir() async {
  var externalStorageDirectories = await path_provider.getExternalStorageDirectories();
  return externalStorageDirectories;
}
