import 'package:flutter/material.dart';
// import 'package:flutter_map/plugin_api.dart';
// import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart' as cluster;
// import 'package:latlong2/latlong.dart' as latlong2;
// import 'package:power_geojson/power_geojson.dart';

class ClustersMarkers extends StatelessWidget {
  const ClustersMarkers({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // CupertinoLocalizationAr();
    /* var markerClusterLayerWidget = cluster.MarkerClusterLayerWidget(
        options: cluster.MarkerClusterLayerOptions(
      maxClusterRadius: 45,
      polygonOptions: const cluster.PolygonOptions(),
      size: const Size(40, 40),
      anchor: AnchorPos.align(AnchorAlign.center),
      fitBoundsOptions: const FitBoundsOptions(
        padding: EdgeInsets.all(50),
        maxZoom: 15,
      ),
      markers: pointsWifi.map((e) {
        var geometry = e["geometry"];
        var latitude = geometry!["y"] ?? 0;
        var longitude = geometry["x"] ?? 0;
        return Marker(
          point: latlong2.LatLng(latitude, longitude),
          rotate: true,
          builder: ((context) {
            var indexOf = pointsWifi.indexOf(e);
            return Icon(
              Icons.wifi,
              color: indexOf == 20 ? Colors.red : Colors.black,
            );
          }),
        );
      }).toList(),
      builder: (context, markers) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF361EA1),
          ),
          child: Center(
            child: Text(
              markers.length.toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        );
      },
    )); */
    /* var popupMarkerLayerWidget = PopupMarkerLayerWidget(
      options: PopupMarkerLayerOptions(
        popupSnap: PopupSnap.markerBottom,
        markers: getMarkers(),
        markerRotate: false,
        onPopupEvent: (event, selectedMarkers) {
          Console.log(selectedMarkers, color: ConsoleColors.red);
        },
        popupBuilder: (context, marker) {
          return Container(
            width: 200,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: const Color(0x88361EA1),
            ),
            child: Center(
              child: Text(
                marker.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      ),
    ); */
    return const SizedBox();
  }
}
