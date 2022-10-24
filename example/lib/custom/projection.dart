import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as flutter_map;
import 'package:tuple/tuple.dart';

class PerojectionFlutterMap extends StatefulWidget {
  const PerojectionFlutterMap({Key? key}) : super(key: key);

  @override
  State<PerojectionFlutterMap> createState() => _PerojectionFlutterMapState();
}

class _PerojectionFlutterMapState extends State<PerojectionFlutterMap> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class CrsCustom extends flutter_map.Crs {
  @override
  // TODO: implement code
  String get code => throw UnimplementedError();

  @override
  // TODO: implement infinite
  bool get infinite => throw UnimplementedError();

  @override
  // TODO: implement projection
  flutter_map.Projection get projection => throw UnimplementedError();

  @override
  // TODO: implement transformation
  flutter_map.Transformation get transformation => throw UnimplementedError();

  @override
  // TODO: implement wrapLat
  Tuple2<double, double>? get wrapLat => throw UnimplementedError();

  @override
  // TODO: implement wrapLng
  Tuple2<double, double>? get wrapLng => throw UnimplementedError();
}
