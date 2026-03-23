import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/admin_helpers.dart';

class VideosTab extends StatefulWidget {
  const VideosTab({super.key});

  @override
  State<VideosTab> createState() => _VideosTabState();
}

class _VideosTabState extends State<VideosTab> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _videos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _videos = await _svc.getVideos(activeOnly: false);
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
              const Icon(Icons.play_circle, color: Color(0xFF66BB6A)),
              const SizedBox(width: 8),
              Text('Videos (${_videos.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              ElevatedButton.icon(onPressed: _add, icon: const Icon(Icons.add, size: 18), label: const Text('Agregar Video')),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Agregá videos de YouTube u otra URL. Ponés título, descripción y opcionalmente una miniatura JPG/PNG.', style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE))),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _videos.length,
            itemBuilder: (context, i) {
              final v = _videos[i];
              return Card(
                color: const Color(0xFF1A2230),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.play_circle_fill, color: Color(0xFFFF8F00)),
                  title: Text(v['title'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text('${v['video_url'] ?? ''}\n${v['active'] == true ? 'Activo' : 'Inactivo'}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BAE))),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _edit(v)),
                      IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _delete(v)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _add() async {
    final result = await _showDialog(null);
    if (result != null) {
      await _svc.upsertVideo(result);
      showSuccessSnack(context, 'Video agregado con éxito');
      _load();
    }
  }

  Future<void> _edit(Map<String, dynamic> v) async {
    final result = await _showDialog(v);
    if (result != null) {
      result['id'] = v['id'];
      await _svc.upsertVideo(result);
      showSuccessSnack(context, 'Video actualizado');
      _load();
    }
  }

  Future<void> _delete(Map<String, dynamic> v) async {
    if (await showConfirmDialog(context, 'Eliminar video "${v['title']}"?')) {
      await _svc.deleteVideo(v['id'] as String);
      showSuccessSnack(context, 'Eliminado');
      _load();
    }
  }

  Future<Map<String, dynamic>?> _showDialog(Map<String, dynamic>? existing) async {
    final titleCtrl = TextEditingController(text: existing?['title'] as String? ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] as String? ?? '');
    final urlCtrl = TextEditingController(text: existing?['video_url'] as String? ?? '');
    String thumbPath = existing?['thumbnail_path'] as String? ?? '';
    bool active = existing?['active'] as bool? ?? true;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Nuevo Video' : 'Editar Video'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título *')),
                const SizedBox(height: 8),
                TextField(controller: urlCtrl, decoration: const InputDecoration(labelText: 'URL del video *', hintText: 'https://youtube.com/...')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2),
                const SizedBox(height: 8),
                ImagePickerField(
                  currentPath: thumbPath,
                  folder: 'video-thumbs',
                  onChanged: (path) => setDialogState(() => thumbPath = path),
                ),
                SwitchListTile(title: const Text('Activo'), value: active, onChanged: (v) => setDialogState(() => active = v)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || urlCtrl.text.isEmpty) return;
                Navigator.pop(ctx, {
                  'title': titleCtrl.text,
                  'description': descCtrl.text,
                  'video_url': urlCtrl.text,
                  'thumbnail_path': thumbPath,
                  'active': active,
                });
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
