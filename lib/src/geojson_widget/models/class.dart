import 'package:latlong2/latlong.dart' as latlong2;

class DestinationDS {
  final double _dm;
  final latlong2.LatLng _destination;
  DestinationDS({
    required double dm,
    required latlong2.LatLng destination,
  })  : _destination = destination,
        _dm = dm;
  double get dm => _dm;
  latlong2.LatLng get destination => _destination;
}
