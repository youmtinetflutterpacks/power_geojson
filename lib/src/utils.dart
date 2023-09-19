import 'dart:io';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:flutter_map/plugin_api.dart';
import 'package:latlong2/latlong.dart';
import 'package:power_geojson/src/src.dart';

void zoomTo(List<List<double>?> features, MapController? mapController) {
  var atLeast = features.firstWhereOrNull((fe) => fe != null);
  if (atLeast == null) return;
  if (mapController == null) return;
  var firstBounds = LatLngBounds.fromPoints([
    LatLng(atLeast[1], atLeast[0]),
    LatLng(atLeast[3], atLeast[2]),
  ]);
  var latLngBounds = features.fold<LatLngBounds>(
    firstBounds,
    (previousValue, bbox) {
      if (bbox == null) return previousValue;
      var elementBounds = LatLngBounds.fromPoints([
        LatLng(bbox[1], bbox[0]),
        LatLng(bbox[3], bbox[2]),
      ]);
      previousValue.extendBounds(elementBounds);
      return previousValue;
    },
  );
  mapController.fitBounds(latLngBounds, options: const FitBoundsOptions());
}

Future<Directory> getDocumentsDir() async =>
    await path_provider.getApplicationDocumentsDirectory();

Future<List<Directory>?> getExternalDir() async {
  var externalStorageDirectories =
      await path_provider.getExternalStorageDirectories();
  return externalStorageDirectories;
}
