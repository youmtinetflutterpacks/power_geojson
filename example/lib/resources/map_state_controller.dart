import 'package:get/get.dart';

import 'geojson_resource.dart';
import 'resource_service.dart';

// ─── Controller ───────────────────────────────────────────────────────────────

class MapStateController extends GetxController {
  // Singleton accessor
  static MapStateController get to => Get.find<MapStateController>();

  // ── Predefined-layer toggles ───────────────────────────────────────────────

  /// Show/hide the Network GeoJSON layers.
  final showNetwork = true.obs;

  /// Show/hide the Asset GeoJSON layers.
  final showAsset = true.obs;

  /// Show/hide the File GeoJSON layers.
  final showFile = true.obs;

  /// Show/hide the String GeoJSON layers.
  final showString = true.obs;

  /// Show/hide the Memory (CircleLayer / ArcGIS markers) layer.
  final showMemory = true.obs;

  // ── Custom resources ───────────────────────────────────────────────────────

  final RxList<GeoJsonResource> customResources = <GeoJsonResource>[].obs;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _loadResources();
  }

  void _loadResources() {
    customResources.assignAll(ResourceService.to.loadAll());
  }

  // ── Public helpers ─────────────────────────────────────────────────────────

  /// Adds [resource] to the persisted store and to the reactive list.
  Future<void> addResource(GeoJsonResource resource) async {
    final saved = await ResourceService.to.save(resource);
    customResources.add(saved);
  }

  /// Removes the resource with [id] from the store and the reactive list.
  Future<void> removeResource(String id) async {
    await ResourceService.to.delete(id);
    customResources.removeWhere((r) => r.id == id);
  }

  /// Refreshes the resource list from persistent storage.
  void refreshResources() => _loadResources();
}
