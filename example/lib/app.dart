import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:get/get.dart';
import 'package:enhanced_future_builder/enhanced_future_builder.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:power_geojson/power_geojson.dart';
import 'package:latlong2/latlong.dart';
import 'package:power_geojson_example/lib.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Home / Splash Screen
// ─────────────────────────────────────────────────────────────────────────────

class AppHome extends StatelessWidget {
  const AppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Logo icon ──
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimary.withValues(alpha: 0.12),
                border: Border.all(color: kPrimary.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.public, size: 48, color: kPrimary),
            ),
            const SizedBox(height: 28),

            // ── Title ──
            Text(
              'Power GeoJSON',
              style: monoStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              'for Flutter',
              style: GoogleFonts.inter(fontSize: 14, color: kTextSecondary),
            ),
            const SizedBox(height: 48),

            // ── CTA button with glow ──
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                boxShadow: [
                  BoxShadow(
                    color: kPrimary.withValues(alpha: 0.35),
                    blurRadius: 24,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () =>
                    Get.offAll(() => const PowerGeojsonSampleApp()),
                child: const Text('Explore Examples →'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Map Screen
// ─────────────────────────────────────────────────────────────────────────────

class PowerGeojsonSampleApp extends StatefulWidget {
  const PowerGeojsonSampleApp({super.key});

  @override
  State<PowerGeojsonSampleApp> createState() => _PowerGeojsonSampleAppState();
}

class _PowerGeojsonSampleAppState extends State<PowerGeojsonSampleApp> {
  LatLng latLng = LatLng(34.92849168609999, -2.3225879568537056);
  final MapController _mapController = MapController();
  final PopupController _popupController = PopupController();

  final List<Marker> _arcgisMarkers = [];

  // Feature list data for the bottom sheet
  static const _features = [
    _FeatureItem(
      color: Color(0xFF2195F3),
      type: 'Polygon',
      label: 'Marrakech_Region_A',
    ),
    _FeatureItem(
      color: kPolyline,
      type: 'Polyline',
      label: 'Route_Main_Street',
    ),
    _FeatureItem(color: kMarker, type: 'Point', label: 'Point_Location_X'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Image.asset('assets/power_geojson.png'),
        title: Text(
          'PowerGeoJSON Example',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w500,
            color: kTextPrimary,
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Map ──
          PopupScope(
            popupController: _popupController,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(34.926447747065936, -2.3228343908943998),
                initialZoom: 11,
                interactionOptions: InteractionOptions(
                  flags:
                      InteractiveFlag.doubleTapZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.scrollWheelZoom |
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.pinchMove,
                ),
                onTap: (_, __) => _popupController.hideAllPopups(),
                onMapEvent: (_) async {},
                onMapReady: () async => await createFiles(),
              ),
              children: [
                TileLayer(
                  // CartoDB Dark Matter tiles for the dark-theme aesthetic
                  urlTemplate:
                      'https://basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
                  retinaMode: true,
                  userAgentPackageName:
                      'com.ymrabtipacks.power_geojson_example',
                  tileProvider: NetworkTileProvider(
                    headers: {
                      'User-Agent': 'com.ymrabtipacks.power_geojson_example',
                    },
                    httpClient: Client(),
                    silenceExceptions: true,
                  ),
                  maxZoom: 19,
                ),
                AssetGeoJSONZones(),
                AssetGeoJSONPolygon(),
                if (!AppPlatform.isWeb || !AppPlatform.isWindows)
                  FileGeoJSONPolygon(),
                StringGeoJSONPolygon(),
                NetworkGeoJSONPolygon(),
                AssetGeoJSONLines(),
                if (!AppPlatform.isWeb || !AppPlatform.isWindows)
                  FileGeoJSONLines(),
                StringGeoJSONLines(),
                NetworkGeoJSONLines(),
                AssetGeoJSONMarkerPoints(popupController: _popupController),
                if (!AppPlatform.isWeb || !AppPlatform.isWindows)
                  FileGeoJSONMarkers(),
                StringGeoJSONPoints(),
                NetworkGeoJSONMarker(),
                CircleOfMap(latLng: latLng),
                MarkerLayer(markers: _arcgisMarkers),
              ],
            ),
          ),

          // ── Glassmorphism Bottom Sheet ──
          Positioned(
            left: 16,
            right: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: kSurface.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Header ──
                      Row(
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: kPrimary.withValues(alpha: 0.15),
                            ),
                            child: const Icon(
                              Icons.public,
                              size: 16,
                              color: kPrimary,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text('Power GeoJSON', style: monoStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // ── Feature list ──
                      ..._features.map(
                        (f) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 5),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: f.color,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  f.label,
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    color: kTextSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: kBackground,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  f.type,
                                  style: monoStyle(
                                    fontSize: 10,
                                    color: kTextSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ── Load GeoJSON button ──
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          child: const Text('Load GeoJSON →'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Center mapSVG() {
    return Center(
      child: EnhancedFutureBuilder(
        future: assetPolygons('assets/morocco.geojson'),
        whenDone: (polygon) {
          return ClipPath(
            clipper: PowerGeoJSONClipper(
              polygon: polygon.geometry.coordinates.toPolygon(),
            ),
            child: Container(
              color: Colors.red,
              width: Get.width / 1.23,
              height: Get.height / 1.5,
              child: Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                style: TextStyle(color: Colors.white),
              ),
            ),
          );
        },
        rememberFutureResult: false,
        whenNotDone: Center(child: CupertinoActivityIndicator()),
      ),
    );
  }
}

// ─── Helper model ────────────────────────────────────────────────────────────

class _FeatureItem {
  const _FeatureItem({
    required this.color,
    required this.type,
    required this.label,
  });
  final Color color;
  final String type;
  final String label;
}
