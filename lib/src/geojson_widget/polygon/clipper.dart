import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' hide Path;
import 'package:power_geojson/power_geojson.dart';

class PowerGeoJSONClipper extends CustomClipper<Path> {
  final Polygon polygon;
  PowerGeoJSONClipper({required this.polygon});
  @override
  Path getClip(Size size) {
    Path path = Path();
    String d = '';

    double minLats = polygon.points.map((e) => e.latitude).toList().min;
    double minLngs = polygon.points.map((e) => e.longitude).toList().min;
    double maxLats = polygon.points.map((e) => e.latitude).toList().max;
    double maxLngs = polygon.points.map((e) => e.longitude).toList().max;

    polygon.points.forEachIndexed((i, e) {
      var lng = (e.longitude - minLngs) / (maxLngs - minLngs) * size.width;
      var lat = (maxLats - e.latitude) / (maxLats - minLats) * size.height;
      if (i == 0) {
        path.moveTo(lng, lat);
        d += 'M$lng $lat';
      } else {
        path.lineTo(lng, lat);
        d += 'L$lng $lat';
      }
    });
    d += 'Z';
    for (var hole in (polygon.holePointsList ?? <List<LatLng>>[])) {
      hole.forEachIndexed((i, e) {
        var lng = (e.longitude - minLngs) / (maxLngs - minLngs) * size.width;
        var lat = (maxLats - e.latitude) / (maxLats - minLats) * size.height;
        if (i == 0) {
          path.moveTo(lng, lat);
          d += 'M$lng $lat';
        } else {
          path.lineTo(lng, lat);
          d += 'L$lng $lat';
        }
      });
      d += 'Z';
    }
    path.close();
    log('<svg version="1.2" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 ${size.width.ceil()} ${size.height.ceil()}" width="50%"><path  fill-rule="evenodd" fill="brown" d="$d" /></svg>');
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
