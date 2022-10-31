import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// The main geodesy class
class Geodesy {
  final double _radius = 6371e3; // meters
  final double _pi = math.pi;

  /// calculate a destination point given the distance and bearing
  LatLng destinationPointByDistanceAndBearing(
      LatLng l, double distance, double bearing,
      [double? radius]) {
    radius = radius ?? _radius;

    double angularDistanceRadius = distance / radius;
    double bearingRadians = degToRadian(bearing);

    double latRadians = degToRadian(l.latitude);
    double lngRadians = degToRadian(l.longitude);

    double sinLatRadians = math.sin(latRadians);
    double cosLatRadians = math.cos(latRadians);
    double sinAngularDistanceRadius = math.sin(angularDistanceRadius);
    double cosAngularDistanceRadius = math.cos(angularDistanceRadius);
    double sinBearingRadians = math.sin(bearingRadians);
    double cosBearingRadians = math.cos(bearingRadians);

    var sinLatRadians2 = sinLatRadians * cosAngularDistanceRadius +
        cosLatRadians * sinAngularDistanceRadius * cosBearingRadians;
    double latRadians2 = math.asin(sinLatRadians2);
    var y = sinBearingRadians * sinAngularDistanceRadius * cosLatRadians;
    var x = cosAngularDistanceRadius - sinLatRadians * sinLatRadians2;
    double lngRadians2 = lngRadians + math.atan2(y, x);
    return LatLng(
        radianToDeg(latRadians2), (radianToDeg(lngRadians2) + 540) % 360 - 180);
  }

  /// calcuate the midpoint bewteen teo geo points
  LatLng midPointBetweenTwoGeoPoints(LatLng l1, LatLng l2) {
    double l1LatRadians = degToRadian(l1.latitude);
    double l1LngRadians = degToRadian(l1.longitude);
    double l2LatRadians = degToRadian(l2.latitude);
    double lngRadiansDiff = degToRadian(l2.longitude - l1.longitude);

    double vectorX = math.cos(l2LatRadians) * math.cos(lngRadiansDiff);
    double vectorY = math.cos(l2LatRadians) * math.sin(lngRadiansDiff);

    double x = math.sqrt((math.cos(l1LatRadians) + vectorX) *
            (math.cos(l1LatRadians) + vectorX) +
        vectorY * vectorY);
    double y = math.sin(l1LatRadians) + math.sin(l2LatRadians);
    double latRadians = math.atan2(y, x);
    double lngRadians =
        l1LngRadians + math.atan2(vectorY, math.cos(l1LatRadians) + vectorX);

    return LatLng(
        radianToDeg(latRadians), (radianToDeg(lngRadians) + 540) % 360 - 180);
  }

  /// calculate the geo point of intersection of two given paths
  LatLng? intersectionByPaths(LatLng l1, LatLng l2, double b1, double b2) {
    double l1LatRadians = degToRadian(l1.latitude);
    double l1LngRadians = degToRadian(l1.longitude);
    double l2LatRadians = degToRadian(l2.latitude);
    double l2LngRadians = degToRadian(l2.longitude);
    double b1Radians = degToRadian(b1);
    double b2Radians = degToRadian(b2);
    var latRadiansDiff = l2LatRadians - l1LatRadians;
    var lngRadiansDiff = l2LngRadians - l1LngRadians;

    double angularDistance = 2 *
        math.asin(math.sqrt(
            math.sin(latRadiansDiff / 2) * math.sin(latRadiansDiff / 2) +
                math.cos(l1LatRadians) *
                    math.cos(l2LatRadians) *
                    math.sin(lngRadiansDiff / 2) *
                    math.sin(lngRadiansDiff / 2)));
    if (angularDistance == 0) return null;

    double initBearingX = math.acos((math.sin(l2LatRadians) -
            math.sin(l1LatRadians) * math.cos(angularDistance)) /
        (math.sin(angularDistance) * math.cos(l1LatRadians)));
    if (initBearingX.isNaN) initBearingX = 0;
    double initBearingY = math.acos((math.sin(l1LatRadians) -
            math.sin(l2LatRadians) * math.cos(angularDistance)) /
        (math.sin(angularDistance) * math.cos(l2LatRadians)));

    var finalBearingX = math.sin(l2LngRadians - l1LngRadians) > 0
        ? initBearingX
        : 2 * _pi - initBearingX;
    var finalBearingY = math.sin(l2LngRadians - l1LngRadians) > 0
        ? 2 * _pi - initBearingY
        : initBearingY;

    var angle1 = b1Radians - finalBearingX;
    var angle2 = finalBearingY - b2Radians;

    if (math.sin(angle1) == 0 && math.sin(angle2) == 0) return null;
    if (math.sin(angle1) * math.sin(angle2) < 0) return null;

    double angle3 = math.acos(-math.cos(angle1) * math.cos(angle2) +
        math.sin(angle1) * math.sin(angle2) * math.cos(angularDistance));
    double dst13 = math.atan2(
        math.sin(angularDistance) * math.sin(angle1) * math.sin(angle2),
        math.cos(angle2) + math.cos(angle1) * math.cos(angle3));
    double lat3 = math.asin(math.sin(l1LatRadians) * math.cos(dst13) +
        math.cos(l1LatRadians) * math.sin(dst13) * math.cos(b1Radians));
    double lngRadiansDiff13 = math.atan2(
        math.sin(b1Radians) * math.sin(dst13) * math.cos(l1LatRadians),
        math.cos(dst13) - math.sin(l1LatRadians) * math.sin(lat3));
    var l3LngRadians = l1LngRadians + lngRadiansDiff13;

    return LatLng(
        radianToDeg(lat3), (radianToDeg(l3LngRadians) + 540) % 360 - 180);
  }

  /// calculate the distance in meters between two geo points
  double distanceBetweenTwoGeoPoints(LatLng l1, LatLng l2, [double? radius]) {
    radius = radius ?? _radius;
    var R = radius;
    double l1LatRadians = degToRadian(l1.latitude);
    double l1LngRadians = degToRadian(l1.longitude);
    double l2LatRadians = degToRadian(l2.latitude);
    double l2LngRadians = degToRadian(l2.longitude);
    var latRadiansDiff = l2LatRadians - l1LatRadians;
    var lngRadiansDiff = l2LngRadians - l1LngRadians;

    double a = math.sin(latRadiansDiff / 2) * math.sin(latRadiansDiff / 2) +
        math.cos(l1LatRadians) *
            math.cos(l2LatRadians) *
            math.sin(lngRadiansDiff / 2) *
            math.sin(lngRadiansDiff / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    var distance = R * c;

    return distance;
  }

  /// calculate the bearing from point l1 to point l2
  double bearingBetweenTwoGeoPoints(LatLng l1, LatLng l2) {
    double l1LatRadians = degToRadian(l1.latitude);
    double l2LatRadians = degToRadian(l2.latitude);
    double lngRadiansDiff = degToRadian(l2.longitude - l1.longitude);
    double y = math.sin(lngRadiansDiff) * math.cos(l2LatRadians);
    double x = math.cos(l1LatRadians) * math.sin(l2LatRadians) -
        math.sin(l1LatRadians) *
            math.cos(l2LatRadians) *
            math.cos(lngRadiansDiff);
    double radians = math.atan2(y, x);

    return (radianToDeg(radians) + 360) % 360;
  }

  /// calculate the final bearing from point l1 to point l2
  double finalBearingBetweenTwoGeoPoints(LatLng l1, LatLng l2) {
    return (bearingBetweenTwoGeoPoints(l2, l1) + 180) % 360;
  }

  /// calculate signed distance from a geo point
  /// to greate circle with start and end points
  double crossTrackDistanceTo(LatLng l1, LatLng start, LatLng end,
      [double? radius]) {
    var R = radius ?? _radius;

    double distStartL1 = distanceBetweenTwoGeoPoints(start, l1, R) / R;
    double radiansStartL1 = degToRadian(bearingBetweenTwoGeoPoints(start, l1));
    double radiansEndL1 = degToRadian(bearingBetweenTwoGeoPoints(start, end));

    double x = math
        .asin(math.sin(distStartL1) * math.sin(radiansStartL1 - radiansEndL1));

    return x * R;
  }

  /// check if a given geo point is in the bouding box
  bool isGeoPointInBoudingBox(LatLng l, LatLng topLeft, LatLng bottomRight) {
    return topLeft.latitude <= l.latitude &&
            l.latitude <= bottomRight.latitude &&
            topLeft.longitude <= l.longitude &&
            l.longitude <= bottomRight.longitude
        ? true
        : false;
  }

  /// check if a given geo point is in the a polygon
  /// using even-odd rule algorithm
  bool isGeoPointInPolygon(LatLng l, List<LatLng> polygon) {
    var isInPolygon = false;

    for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
      var bool = polygon[i].latitude <= l.latitude;
      var bool2 = l.latitude < polygon[j].latitude;
      var bool3 = l.latitude < polygon[i].latitude;
      var bool4 = polygon[j].latitude <= l.latitude;
      var bool5 = bool && bool2;
      var bool6 = bool4 && bool3;
      var bool7 = bool5 || bool6;
      var d = polygon[j].longitude - polygon[i].longitude;
      var e = l.latitude - polygon[i].latitude;
      var f = polygon[j].latitude - polygon[i].latitude;
      var longitude2 = polygon[i].longitude;
      var bool8 = l.longitude < d * e / f + longitude2;
      if (bool7 && bool8) isInPolygon = !isInPolygon;
    }
    return isInPolygon;
  }

  /// Get a list of [LatLng] points within a distance from
  /// a given point
  ///
  /// Distance is in meters
  List<LatLng> pointsInRange(
      LatLng point, List<LatLng> pointsToCheck, double distance) {
    final geoFencedPoints = <LatLng>[];
    for (final p in pointsToCheck) {
      final distanceFromCenter = distanceBetweenTwoGeoPoints(point, p);
      if (distanceFromCenter <= distance) {
        geoFencedPoints.add(p);
      }
    }
    return geoFencedPoints;
  }
}
