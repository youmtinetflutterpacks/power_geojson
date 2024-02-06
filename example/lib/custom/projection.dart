import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

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

class CrsCustom extends Crs {
  @override
  String get code => throw UnimplementedError();

  @override
  bool get infinite => throw UnimplementedError();

  @override
  Projection get projection => throw UnimplementedError();

  @override
  Transformation get transformation => throw UnimplementedError();

  @override
  (double, double)? get wrapLat => throw UnimplementedError();

  @override
  (double, double)? get wrapLng => throw UnimplementedError();
}
