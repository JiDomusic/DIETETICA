import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/admin_helpers.dart';

class GalleryTab extends StatefulWidget {
  const GalleryTab({super.key});

  @override
  State<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends State<GalleryTab> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _items = await _svc.getGallery(activeOnly: false);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.photo_library, color: Color(0xFF66BB6A)),
              const SizedBox(width: 8),
              Text('Galería (${_items.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              ElevatedButton.icon(onPressed: _add, icon: const Icon(Icons.add, size: 18), label: const Text('Agregar')),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Subí fotos de tus locales, productos, equipo. Aparecen en el carrusel de galería del home. Solo JPG/PNG.', style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE))),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12),
            itemCount: _items.length,
            itemBuilder: (context, i) {
              final item = _items[i];
              final imgPath = item['image_path'] as String? ?? '';

              return Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: imgPath.isNotEmpty
                        ? Image.network(_svc.getPublicImageUrl(imgPath), fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2A3545), child: const Icon(Icons.broken_image)))
                        : Container(color: const Color(0xFF2A3545)),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                      child: Text(item['title'] as String? ?? '', style: const TextStyle(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _miniBtn(Icons.edit, () => _edit(item)),
                        const SizedBox(width: 4),
                        _miniBtn(Icons.delete, () => _delete(item), color: Colors.red),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _miniBtn(IconData icon, VoidCallback onPressed, {Color? color}) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 16, color: color ?? Colors.white),
      ),
    );
  }

  Future<void> _add() async {
    final result = await _showDialog(null);
    if (result != null) {
      await _svc.upsertGalleryItem(result);
      showSuccessSnack(context, 'Imagen agregada a galería');
      _load();
    }
  }

  Future<void> _edit(Map<String, dynamic> item) async {
    final result = await _showDialog(item);
    if (result != null) {
      result['id'] = item['id'];
      await _svc.upsertGalleryItem(result);
      showSuccessSnack(context, 'Actualizada');
      _load();
    }
  }

  Future<void> _delete(Map<String, dynamic> item) async {
    if (await showConfirmDialog(context, 'Eliminar imagen de la galería?')) {
      await _svc.deleteGalleryItem(item['id'] as String);
      showSuccessSnack(context, 'Eliminada');
      _load();
    }
  }

  Future<Map<String, dynamic>?> _showDialog(Map<String, dynamic>? existing) async {
    final titleCtrl = TextEditingController(text: existing?['title'] as String? ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] as String? ?? '');
    String imagePath = existing?['image_path'] as String? ?? '';

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Nueva Imagen' : 'Editar Imagen'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ImagePickerField(
                  currentPath: imagePath,
                  folder: 'gallery',
                  onChanged: (path) => setDialogState(() => imagePath = path),
                ),
                const SizedBox(height: 8),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (imagePath.isEmpty) { showSuccessSnack(ctx, 'Subí una imagen', isError: true); return; }
                Navigator.pop(ctx, {'title': titleCtrl.text, 'description': descCtrl.text, 'image_path': imagePath, 'active': true});
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
