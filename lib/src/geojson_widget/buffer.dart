import 'package:power_geojson/power_geojson.dart';

class BufferOptions {
  final double? _buffer;
  final bool buffersOnly;
  double get buffer => _buffer ?? 0;
  PolygonProperties? polygonBufferProperties;
  BufferOptions({
    double? buffer,
    this.buffersOnly = false,
    this.polygonBufferProperties,
  }) : _buffer = buffer;
}
