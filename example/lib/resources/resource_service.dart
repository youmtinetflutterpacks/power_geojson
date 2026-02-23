import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'geojson_resource.dart';

// ─── Service ──────────────────────────────────────────────────────────────────

class ResourceService extends GetxService {
  static const _prefKey = 'geojson_resources';

  // Singleton accessor
  static ResourceService get to => Get.find<ResourceService>();

  late SharedPreferences _prefs;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
  }

  // ── CRUD ───────────────────────────────────────────────────────────────────

  /// Returns all persisted resources, in insertion order.
  List<GeoJsonResource> loadAll() {
    final raw = _prefs.getStringList(_prefKey) ?? [];
    return raw.map((s) => GeoJsonResource.fromJson(jsonDecode(s) as Map<String, dynamic>)).toList();
  }

  /// Adds [resource] to the persisted list and returns the saved instance.
  ///
  /// For [GeoJsonSourceType.file] resources the caller must already have
  /// populated [resource.data] with the file's UTF-8 content (or base-64 for
  /// binary), and may optionally call [cacheFileContent] to write a copy to
  /// the app-documents directory.
  Future<GeoJsonResource> save(GeoJsonResource resource) async {
    final all = loadAll();
    all.add(resource);
    await _persist(all);
    return resource;
  }

  /// Removes [id] from the persisted list and deletes any cached file.
  Future<void> delete(String id) async {
    final all = loadAll()..removeWhere((r) => r.id == id);
    await _persist(all);
    // Delete cached file if present
    try {
      final path = await getCachedFilePath(id);
      final file = File(path);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  /// Writes [content] to the app-documents cache directory under [id].geojson.
  Future<String> cacheFileContent(String id, String content) async {
    final path = await getCachedFilePath(id);
    await File(path).writeAsString(content, flush: true);
    return path;
  }

  /// Returns the path `<appDocDir>/<id>.geojson` for the given resource id.
  Future<String> getCachedFilePath(String id) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/$id.geojson';
  }

  // ── Private ────────────────────────────────────────────────────────────────

  Future<void> _persist(List<GeoJsonResource> list) async {
    final encoded = list.map((r) => jsonEncode(r.toJson())).toList();
    await _prefs.setStringList(_prefKey, encoded);
  }
}
