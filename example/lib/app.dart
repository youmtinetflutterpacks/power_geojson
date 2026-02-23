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

  void _openLoadModal(BuildContext context) => showLoadGeoJSONModal(context);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final ctrl = MapStateController.to;
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
                  initialCenter: LatLng(
                    34.926447747065936,
                    -2.3228343908943998,
                  ),
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
                  if (ctrl.showAsset.value) AssetGeoJSONZones(),
                  if (ctrl.showAsset.value) AssetGeoJSONPolygon(),
                  if (ctrl.showFile.value &&
                      (!AppPlatform.isWeb || !AppPlatform.isWindows))
                    FileGeoJSONPolygon(),
                  if (ctrl.showString.value) StringGeoJSONPolygon(),
                  if (ctrl.showNetwork.value) NetworkGeoJSONPolygon(),
                  if (ctrl.showAsset.value) AssetGeoJSONLines(),
                  if (ctrl.showFile.value &&
                      (!AppPlatform.isWeb || !AppPlatform.isWindows))
                    FileGeoJSONLines(),
                  if (ctrl.showString.value) StringGeoJSONLines(),
                  if (ctrl.showNetwork.value) NetworkGeoJSONLines(),
                  if (ctrl.showAsset.value)
                    AssetGeoJSONMarkerPoints(popupController: _popupController),
                  if (ctrl.showFile.value &&
                      (!AppPlatform.isWeb || !AppPlatform.isWindows))
                    FileGeoJSONMarkers(),
                  if (ctrl.showString.value) StringGeoJSONPoints(),
                  if (ctrl.showNetwork.value) NetworkGeoJSONMarker(),
                  if (ctrl.showMemory.value) CircleOfMap(latLng: latLng),
                  if (ctrl.showMemory.value)
                    MarkerLayer(markers: _arcgisMarkers),
                  // ── Custom resources ─────────────────────────────────────
                  ...ctrl.customResources.map(
                    (r) => _CustomResourceLayer(resource: r),
                  ),
                ],
              ),
            ),

            // ── Glassmorphism Bottom Sheet ──
            Positioned(
              left: AppPlatform.isWeb ? null : 16,
              right: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    constraints: BoxConstraints(maxWidth: 440),
                    // width: AppPlatform.isWeb ? 340 : null,
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
                            Text(
                              'Power GeoJSON',
                              style: monoStyle(fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // ── Layer toggles row ─────────────────────────────
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _LayerToggleChip(
                                label: 'Network',
                                color: kPrimary,
                                value: ctrl.showNetwork.value,
                                onChanged: (v) => ctrl.showNetwork.value = v,
                              ),
                              const SizedBox(width: 8),
                              _LayerToggleChip(
                                label: 'Asset',
                                color: const Color(0xFF2195F3),
                                value: ctrl.showAsset.value,
                                onChanged: (v) => ctrl.showAsset.value = v,
                              ),
                              const SizedBox(width: 8),
                              if (!AppPlatform.isWeb)
                                _LayerToggleChip(
                                  label: 'File',
                                  color: kPolyline,
                                  value: ctrl.showFile.value,
                                  onChanged: (v) => ctrl.showFile.value = v,
                                ),
                              const SizedBox(width: 8),
                              _LayerToggleChip(
                                label: 'String',
                                color: kMarker,
                                value: ctrl.showString.value,
                                onChanged: (v) => ctrl.showString.value = v,
                              ),
                              const SizedBox(width: 8),
                              _LayerToggleChip(
                                label: 'Memory',
                                color: kIndigo,
                                value: ctrl.showMemory.value,
                                onChanged: (v) => ctrl.showMemory.value = v,
                              ),
                            ],
                          ),
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
                            onPressed: () => _openLoadModal(context),
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
    }); // end Obx
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

// ─── Layer Toggle Chip ────────────────────────────────────────────────────────

class _LayerToggleChip extends StatelessWidget {
  const _LayerToggleChip({
    required this.label,
    required this.color,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final Color color;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: value
              ? color.withValues(alpha: 0.15)
              : kBackground.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: value
                ? color.withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: value ? color : kTextSecondary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: value ? color : kTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Custom Resource Layer ────────────────────────────────────────────────────

/// Renders a single [GeoJsonResource] as a map layer.
class _CustomResourceLayer extends StatelessWidget {
  const _CustomResourceLayer({required this.resource});
  final GeoJsonResource resource;

  @override
  Widget build(BuildContext context) {
    switch (resource.sourceType) {
      case GeoJsonSourceType.network:
        return _buildNetwork();
      case GeoJsonSourceType.file:
      case GeoJsonSourceType.string:
        return _buildString();
    }
  }

  String get _data => resource.data ?? '';
  String get _url => resource.url ?? '';

  Widget _buildNetwork() {
    switch (resource.geomType) {
      case GeoJsonGeomType.polygon:
        return PowerGeoJSONPolygons.network(
          _url,
          polygonProperties: const PolygonProperties(),
        );
      case GeoJsonGeomType.polyline:
        return PowerGeoJSONPolylines.network(
          _url,
          polylineProperties: const PolylineProperties(),
        );
      case GeoJsonGeomType.point:
        return PowerGeoJSONMarkers.network(
          _url,
          markerProperties: const MarkerProperties(),
          builder: (ctx, mp, layerProps) =>
              const Icon(Icons.location_pin, color: kPrimary, size: 24),
        );
      case GeoJsonGeomType.auto:
        // Default to polygon for network auto-detect
        return PowerGeoJSONFeatureCollections.network(
          _url,
          featureCollectionProperties: FeatureCollectionProperties(),
          builder: (featureCollectionProperties, map) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFF140042),
              ),
              child: Image.asset('assets/power_geojson.png'),
            );
          },
        );
    }
  }

  Widget _buildString() {
    if (_data.isEmpty) return const SizedBox.shrink();
    switch (resource.geomType) {
      case GeoJsonGeomType.polygon:
        return PowerGeoJSONPolygons.string(
          _data,
          polygonProperties: const PolygonProperties(),
        );
      case GeoJsonGeomType.polyline:
        return PowerGeoJSONPolylines.string(
          _data,
          polylineProperties: const PolylineProperties(),
        );
      case GeoJsonGeomType.point:
        return PowerGeoJSONMarkers.string(
          _data,
          markerProperties: const MarkerProperties(),
          builder: (ctx, mp, layerProps) =>
              const Icon(Icons.location_pin, color: kMarker, size: 24),
        );
      case GeoJsonGeomType.auto:
        return PowerGeoJSONFeatureCollections.string(
          _data,
          featureCollectionProperties: FeatureCollectionProperties(),
          builder: (featureCollectionProperties, properties) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Color(0xFF140042),
              ),
              child: Image.asset('assets/power_geojson.png'),
            );
          },
        );
    }
  }
}
