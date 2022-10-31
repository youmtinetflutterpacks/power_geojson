import 'dart:convert';

import 'package:console_tools/console_tools.dart';

var esri2geo = {};
toGeoJSON(Map<String, dynamic> data) {
  var outPut = {"type": "FeatureCollection", "features": []};
  var data2 = data['features'];
  var fl = data2.length;
  var i = 0;
  while (fl > i) {
    var ft = data['features'][i];
    /* as only ESRI based products care if all the features are the same type of geometry, check for geometry type at a feature level*/
    var outFT = {"type": "Feature", "properties": prop(ft['attributes'])};
    var geometry = ft['geometry'];
    if (geometry['x'] != null) {
      //check if it's a point
      outFT['geometry'] = point(geometry);
    } else if (geometry['points'] != null) {
      //check if it is a multipoint
      outFT['geometry'] = points(geometry);
    } else if (geometry['paths'] != null) {
      //check if a line (or "ARC" in ESRI terms)
      outFT['geometry'] = line(geometry);
    } else if (geometry['rings'] != null) {
      outFT['geometry'] = poly(geometry);
    }
    var outPut2 = outPut['features'] as List;
    outPut2.add(outFT);
    i++;
  }
  Console.log('outPut = ${json.encode(outPut)}');
}

// \.(points|x|y|paths|rings)
point(geometry) {
  //this one is easy
  return {
    "type": "Point",
    "coordinates": [geometry['x'], geometry['y']]
  };
}

points(geometry) {
  //checks if the multipoint only has one point, if so exports as point instead
  if (geometry['points'].length == 1) {
    return {"type": "Point", "coordinates": geometry['points'][0]};
  } else {
    return {"type": "MultiPoint", "coordinates": geometry['points']};
  }
}

line(geometry) {
  //checks if their are multiple paths or just one
  if (geometry['paths'].length == 1) {
    return {"type": "LineString", "coordinates": geometry['paths'][0]};
  } else {
    return {"type": "MultiLineString", "coordinates": geometry['paths']};
  }
}

poly(geometry) {
  //first we check for some easy cases, like if their is only one ring
  if (geometry['rings'].length == 1) {
    return {"type": "Polygon", "coordinates": geometry['rings']};
  } else {
    /*if it isn't that easy then we have to start checking ring direction, basically the ring goes clockwise its part of the polygon,
            if it goes counterclockwise it is a hole in the polygon, but geojson does it by haveing an array with the first element be the polygons 
            and the next elements being holes in it*/
    return decodePolygon(geometry['rings']);
  }
}

decodePolygon(a) {
  //returns the feature
  var coords = [];
  String type;
  var len = a.length;
  var i = 0;
  var len2 = coords.length - 1;
  while (len > i) {
    if (ringIsClockwise(a[i])) {
      coords.add([a[i]]);
      len2++;
    } else {
      var coord = coords[len2] as List;
      coord.add(a[i]);
    }
    i++;
  }
  if (coords.length == 1) {
    type = "Polygon";
  } else {
    type = "MultiPolygon";
  }
  return {
    "type": type,
    "coordinates": (coords.length == 1) ? coords[0] : coords
  };
}

ringIsClockwise(ringToTest) {
  var total = 0, i = 0, rLength = ringToTest.length, pt1 = ringToTest[i];
  List<int> pt2;
  for (i; i < rLength - 1; i++) {
    pt2 = ringToTest[i + 1];
    var pt22 = pt2[0];
    var pt12 = pt1[0] as int;
    var pt23 = pt2[1];
    var pt13 = pt1[1] as int;
    total += (pt22 - pt12) * (pt23 + pt13);
    pt1 = pt2;
  }
  return (total >= 0);
}

prop(Map<String, dynamic> a) {
  var p = {};
  for (var k in a.keys) {
    if (a[k] != null) {
      p[k] = a[k];
    }
  }
  return p;
}
