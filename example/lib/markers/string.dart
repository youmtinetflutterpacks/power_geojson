import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:power_geojson/power_geojson.dart';

class StringGeoJSONPoints extends StatelessWidget {
  const StringGeoJSONPoints({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.string(
      stringMarkers,
      /* builder: (context, markerProperties, properties) {
        return SvgPicture.asset(
          "assets/icons/position.svg",
          color: const Color(0xFFEF2874),
        );
      }, */
      markerProperties: const MarkerProperties(),
      mapController: _mapController,
    );
  }
}

class StringGeoJSONMultiPoints extends StatelessWidget {
  const StringGeoJSONMultiPoints({
    Key? key,
    MapController? mapController,
  })  : _mapController = mapController,
        super(key: key);

  final MapController? _mapController;

  @override
  Widget build(BuildContext context) {
    return PowerGeoJSONMarkers.string(
      stringMultiMarkers,
      builder: (context, markerProperties, properties) {
        return SvgPicture.asset(
          "assets/icons/position.svg",
          height: 300,
          width: 300,
          color: const Color(0xFF72077C),
        );
      },
      markerProperties: const MarkerProperties(),
      mapController: _mapController,
    );
  }
}

const stringMarkers =
    '''{"type":"FeatureCollection","features":[{"type":"Feature","id":0,"geometry":{"type":"Point","coordinates":[-2.3734106322103194,34.904704658531713]},"properties":{"FID":0,"Id":0}},{"type":"Feature","id":1,"geometry":{"type":"Point","coordinates":[-2.382360633803299,34.890489950119331]},"properties":{"FID":1,"Id":0}},{"type":"Feature","id":2,"geometry":{"type":"Point","coordinates":[-2.3768326916429294,34.876538477047923]},"properties":{"FID":2,"Id":0}},{"type":"Feature","id":3,"geometry":{"type":"Point","coordinates":[-2.3857826932359094,34.873642888297255]},"properties":{"FID":3,"Id":0}},{"type":"Feature","id":4,"geometry":{"type":"Point","coordinates":[-2.3999974016482888,34.868114946136885]},"properties":{"FID":4,"Id":0}},{"type":"Feature","id":5,"geometry":{"type":"Point","coordinates":[-2.3844665165310595,34.849162001587047]},"properties":{"FID":5,"Id":0}},{"type":"Feature","id":6,"geometry":{"type":"Point","coordinates":[-2.4700180023463059,34.874959065002102]},"properties":{"FID":6,"Id":0}},{"type":"Feature","id":7,"geometry":{"type":"Point","coordinates":[-2.4573827059797466,34.89996642239425]},"properties":{"FID":7,"Id":0}},{"type":"Feature","id":8,"geometry":{"type":"Point","coordinates":[-2.4939724183745753,34.909706130010143]},"properties":{"FID":8,"Id":0}},{"type":"Feature","id":9,"geometry":{"type":"Point","coordinates":[-2.5231915412222441,34.885488478640909]},"properties":{"FID":9,"Id":0}},{"type":"Feature","id":10,"geometry":{"type":"Point","coordinates":[-2.522401835199334,34.870747299546579]},"properties":{"FID":10,"Id":0}},{"type":"Feature","id":11,"geometry":{"type":"Point","coordinates":[-2.510029774173745,34.884698772617995]},"properties":{"FID":11,"Id":0}},{"type":"Feature","id":12,"geometry":{"type":"Point","coordinates":[-2.4871282995093553,34.860217885907787]},"properties":{"FID":12,"Id":0}},{"type":"Feature","id":13,"geometry":{"type":"Point","coordinates":[-2.4781782979163758,34.864956122045243]},"properties":{"FID":13,"Id":0}},{"type":"Feature","id":14,"geometry":{"type":"Point","coordinates":[-2.4744930031427961,34.847582589541219]},"properties":{"FID":14,"Id":0}},{"type":"Feature","id":15,"geometry":{"type":"Point","coordinates":[-2.4734400617789158,34.839422293971154]},"properties":{"FID":15,"Id":0}},{"type":"Feature","id":16,"geometry":{"type":"Point","coordinates":[-2.4392194674528174,34.859428179884873]},"properties":{"FID":16,"Id":0}},{"type":"Feature","id":17,"geometry":{"type":"Point","coordinates":[-2.434481231315357,34.868378181477851]},"properties":{"FID":17,"Id":0}},{"type":"Feature","id":18,"geometry":{"type":"Point","coordinates":[-2.4621209421172066,34.886804655345756]},"properties":{"FID":18,"Id":0}}]}''';
const stringMultiMarkers =
    '''{"type":"FeatureCollection","features":[{"type":"Feature","id":0,"geometry":{"type":"MultiPoint","coordinates":[[-2.391310635396279,34.859954650566806],[-2.3781488683477798,34.857585532498078],[-2.37420033823323,34.842844353403763],[-2.3963121068747086,34.836789940561452],[-2.4081576972183583,34.864956122045243],[-2.4265841710862577,34.889963479437398],[-2.4550135879110164,34.889700244096417],[-2.477125356552496,34.876012006365983],[-2.4929194770106951,34.887331126027689],[-2.5102930095147147,34.912075248078871],[-2.5289827187235838,34.909442894669169],[-2.5252974239500041,34.898123775007463],[-2.5229283058812744,34.909442894669169],[-2.4634371188220561,34.906284070577527],[-2.5229283058812744,34.864429651363302],[-2.4937091830336051,34.862060533294574],[-2.4244782883584977,34.872326711592407],[-2.4081576972183583,34.874695829661135],[-2.3973650482385889,34.876538477047923],[-2.3884150466456093,34.881803183867319],[-2.3889415173275492,34.888910538073517],[-2.3855194578949392,34.901809069781038],[-2.3852562225539691,34.909706130010143],[-2.3747268089151694,34.897334068984549],[-2.3699885727777099,34.884962007958961],[-2.3713047494825599,34.868114946136885],[-2.477125356552496,34.855742885111297]]},"properties":{"FID":0,"Id":0}},{"type":"Feature","id":1,"geometry":{"type":"MultiPoint","coordinates":[[-2.4005238723302291,34.857585532498092],[-2.3902576940323996,34.844160530108624],[-2.3828871044852398,34.837053175902433],[-2.4221091702897684,34.836526705220493],[-2.4131591686967884,34.892069362165159],[-2.4144753454016383,34.909442894669183],[-2.440272408816698,34.908916423987236]]},"properties":{"FID":1,"Id":0}},{"type":"Feature","id":2,"geometry":{"type":"MultiPoint","coordinates":[[-2.4613312360942965,34.874695829661142],[-2.4702812376872765,34.881803183867333],[-2.4742297678018259,34.889437008755465],[-2.5000268312168856,34.892859068188073],[-2.4842327107586861,34.902335540462992]]},"properties":{"FID":2,"Id":0}}]}''';
