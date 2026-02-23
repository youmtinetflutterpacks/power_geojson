import 'dart:ui';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme.dart';
import 'geojson_resource.dart';
import 'map_state_controller.dart';
import 'resource_service.dart';

// ─── Entry point ──────────────────────────────────────────────────────────────

Future<void> showLoadGeoJSONModal(BuildContext context) {
  return showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (_) => const _LoadGeoJSONSheet());
}

// ─── Bottom Sheet ─────────────────────────────────────────────────────────────

class _LoadGeoJSONSheet extends StatefulWidget {
  const _LoadGeoJSONSheet();

  @override
  State<_LoadGeoJSONSheet> createState() => _LoadGeoJSONSheetState();
}

class _LoadGeoJSONSheetState extends State<_LoadGeoJSONSheet> {
  bool _showForm = false;

  void _toggleForm() => setState(() => _showForm = !_showForm);

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.88),
          decoration: BoxDecoration(
            color: kSurface.withValues(alpha: 0.85),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Handle bar ─────────────────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(height: 16),

              // ── Header ─────────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: kPrimary.withValues(alpha: 0.15)),
                      child: const Icon(Icons.layers_outlined, size: 18, color: kPrimary),
                    ),
                    const SizedBox(width: 12),
                    Text('GeoJSON Resources', style: monoStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(Icons.close, size: 20, color: kTextSecondary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),

              // ── Scrollable body ────────────────────────────────────────────
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resource list
                      Obx(() {
                        final resources = MapStateController.to.customResources;
                        if (resources.isEmpty && !_showForm) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 24),
                            child: Center(
                              child: Text(
                                'No custom resources yet.\nTap "+ Add Resource" to load GeoJSON.',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.inter(fontSize: 13, color: kTextSecondary),
                              ),
                            ),
                          );
                        }
                        return Column(children: resources.map((r) => _ResourceRow(resource: r)).toList());
                      }),

                      const SizedBox(height: 8),

                      // Add / collapse button
                      if (!_showForm)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _toggleForm,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('+ Add Resource'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: kPrimary,
                              side: BorderSide(color: kPrimary.withValues(alpha: 0.5)),
                              shape: const StadiumBorder(),
                            ),
                          ),
                        ),

                      // Inline add form
                      if (_showForm) _AddResourceForm(onAdded: () => setState(() => _showForm = false), onCancel: () => setState(() => _showForm = false)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Resource Row ─────────────────────────────────────────────────────────────

class _ResourceRow extends StatelessWidget {
  const _ResourceRow({required this.resource});
  final GeoJsonResource resource;

  @override
  Widget build(BuildContext context) {
    final dotColor = _geomColor(resource.geomType);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle, color: dotColor),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  resource.label.isEmpty ? '(unlabelled)' : resource.label,
                  style: GoogleFonts.inter(fontSize: 13, color: kTextPrimary, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
                Text('${resource.sourceType.name} · ${resource.geomType.name}', style: GoogleFonts.inter(fontSize: 11, color: kTextSecondary)),
              ],
            ),
          ),
          if (resource.isCustom)
            GestureDetector(
              onTap: () => MapStateController.to.removeResource(resource.id),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.delete_outline, size: 18, color: Colors.redAccent.withValues(alpha: 0.8)),
              ),
            ),
        ],
      ),
    );
  }

  static Color _geomColor(GeoJsonGeomType t) {
    switch (t) {
      case GeoJsonGeomType.polygon:
        return const Color(0xFF2195F3);
      case GeoJsonGeomType.polyline:
        return kPolyline;
      case GeoJsonGeomType.point:
        return kMarker;
      case GeoJsonGeomType.auto:
        return kPrimary;
    }
  }
}

// ─── Add Resource Form ────────────────────────────────────────────────────────

class _AddResourceForm extends StatefulWidget {
  const _AddResourceForm({required this.onAdded, required this.onCancel});
  final VoidCallback onAdded;
  final VoidCallback onCancel;

  @override
  State<_AddResourceForm> createState() => _AddResourceFormState();
}

class _AddResourceFormState extends State<_AddResourceForm> {
  final _formKey = GlobalKey<FormState>();

  GeoJsonSourceType _sourceType = GeoJsonSourceType.network;
  GeoJsonGeomType _geomType = GeoJsonGeomType.auto;

  final _urlCtrl = TextEditingController();
  final _stringCtrl = TextEditingController();
  final _labelCtrl = TextEditingController();

  String? _pickedFileName;
  String? _pickedFileContent;

  bool _loading = false;

  @override
  void dispose() {
    _urlCtrl.dispose();
    _stringCtrl.dispose();
    _labelCtrl.dispose();
    super.dispose();
  }

  // ── File picker ────────────────────────────────────────────────────────────

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['geojson', 'json'], withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final sizeBytes = file.size;
    const maxBytes = 25 * 1024 * 1024; // 25 MB

    if (sizeBytes > maxBytes) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File exceeds the 25 MB limit.'), backgroundColor: Colors.redAccent));
      }
      return;
    }

    final bytes = file.bytes;
    if (bytes == null) return;

    setState(() {
      _pickedFileName = file.name;
      _pickedFileContent = String.fromCharCodes(bytes);
    });
  }

  // ── Submission ─────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final label = _labelCtrl.text.trim().isEmpty ? _defaultLabel() : _labelCtrl.text.trim();

      late GeoJsonResource resource;

      switch (_sourceType) {
        case GeoJsonSourceType.network:
          resource = GeoJsonResource(label: label, sourceType: GeoJsonSourceType.network, geomType: _geomType, url: _urlCtrl.text.trim());

        case GeoJsonSourceType.file:
          // Cache the file content to app documents dir
          final tmpResource = GeoJsonResource(label: label, sourceType: GeoJsonSourceType.file, geomType: _geomType, data: _pickedFileContent);
          await ResourceService.to.cacheFileContent(tmpResource.id, _pickedFileContent!);
          resource = tmpResource;

        case GeoJsonSourceType.string:
          resource = GeoJsonResource(label: label, sourceType: GeoJsonSourceType.string, geomType: _geomType, data: _stringCtrl.text.trim());
      }

      await MapStateController.to.addResource(resource);
      widget.onAdded();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _defaultLabel() {
    switch (_sourceType) {
      case GeoJsonSourceType.network:
        return 'Network (${DateTime.now().millisecondsSinceEpoch})';
      case GeoJsonSourceType.file:
        return _pickedFileName ?? 'File layer';
      case GeoJsonSourceType.string:
        return 'String layer';
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimary.withValues(alpha: 0.2)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Source-type segmented control ──────────────────────────────
            _SectionLabel('Source Type'),
            const SizedBox(height: 8),
            _TypeSegment(
              selected: _sourceType,
              onChanged: (t) => setState(() {
                _sourceType = t;
                _pickedFileName = null;
                _pickedFileContent = null;
              }),
            ),
            const SizedBox(height: 16),

            // ── Source input ───────────────────────────────────────────────
            if (_sourceType == GeoJsonSourceType.network) ...[
              _SectionLabel('URL'),
              const SizedBox(height: 6),
              _GlassField(
                controller: _urlCtrl,
                hint: 'https://example.com/layer.geojson',
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'URL is required';
                  final uri = Uri.tryParse(v.trim());
                  if (uri == null || (!uri.scheme.startsWith('http'))) {
                    return 'Enter a valid http(s) URL';
                  }
                  return null;
                },
              ),
            ] else if (_sourceType == GeoJsonSourceType.file) ...[
              _SectionLabel('GeoJSON File (≤ 25 MB)'),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.folder_open_outlined, size: 18),
                  label: Text(_pickedFileName ?? 'Browse GeoJSON file…', overflow: TextOverflow.ellipsis),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: kPrimary,
                    side: BorderSide(color: kPrimary.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    alignment: Alignment.centerLeft,
                  ),
                ),
              ),
              // validator shim (invisible field)
              if (_pickedFileContent == null && _loading)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('Please select a file.', style: GoogleFonts.inter(fontSize: 11, color: Colors.redAccent)),
                ),
            ] else ...[
              _SectionLabel('Raw GeoJSON'),
              const SizedBox(height: 6),
              _GlassField(
                controller: _stringCtrl,
                hint: '{ "type": "FeatureCollection", … }',
                maxLines: 6,
                minLines: 5,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'GeoJSON string is required';
                  }
                  return null;
                },
              ),
            ],

            const SizedBox(height: 16),

            // ── Label ──────────────────────────────────────────────────────
            _SectionLabel('Label (optional)'),
            const SizedBox(height: 6),
            _GlassField(controller: _labelCtrl, hint: 'My layer'),
            const SizedBox(height: 16),

            // ── Geometry type ──────────────────────────────────────────────
            _SectionLabel('Geometry Type'),
            const SizedBox(height: 8),
            _GeomDropdown(value: _geomType, onChanged: (t) => setState(() => _geomType = t)),
            const SizedBox(height: 20),

            // ── Action buttons ─────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: Text('Cancel', style: GoogleFonts.inter(color: kTextSecondary)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    child: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Add to Map'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small Widgets ────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: kTextSecondary, letterSpacing: 0.6),
    );
  }
}

class _GlassField extends StatelessWidget {
  const _GlassField({required this.controller, required this.hint, this.validator, this.maxLines = 1, this.minLines});

  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final int maxLines;
  final int? minLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      minLines: minLines,
      validator: validator,
      style: GoogleFonts.jetBrainsMono(fontSize: 12, color: kTextPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(fontSize: 12, color: kTextSecondary),
        filled: true,
        fillColor: kBackground.withValues(alpha: 0.6),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: kPrimary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}

class _TypeSegment extends StatelessWidget {
  const _TypeSegment({required this.selected, required this.onChanged});
  final GeoJsonSourceType selected;
  final ValueChanged<GeoJsonSourceType> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: GeoJsonSourceType.values.map((t) {
        final isSelected = t == selected;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(t),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 6),
              padding: const EdgeInsets.symmetric(vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? kPrimary : kBackground.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? kPrimary : Colors.white.withValues(alpha: 0.1)),
              ),
              child: Center(
                child: Text(
                  t.name[0].toUpperCase() + t.name.substring(1),
                  style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : kTextSecondary),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _GeomDropdown extends StatelessWidget {
  const _GeomDropdown({required this.value, required this.onChanged});
  final GeoJsonGeomType value;
  final ValueChanged<GeoJsonGeomType> onChanged;

  static const _labels = {GeoJsonGeomType.auto: 'Auto (detect)', GeoJsonGeomType.polygon: 'Polygon', GeoJsonGeomType.polyline: 'Polyline', GeoJsonGeomType.point: 'Point'};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: kBackground.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<GeoJsonGeomType>(
          value: value,
          dropdownColor: kSurface,
          isExpanded: true,
          style: GoogleFonts.inter(fontSize: 13, color: kTextPrimary),
          items: GeoJsonGeomType.values.map((t) => DropdownMenuItem(value: t, child: Text(_labels[t]!))).toList(),
          onChanged: (t) {
            if (t != null) onChanged(t);
          },
        ),
      ),
    );
  }
}
