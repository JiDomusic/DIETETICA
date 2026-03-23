import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/admin_helpers.dart';

/// Tab para editar secciones del Home, banners, navbar y banners opcionales
class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _homeBanners = [];
  List<Map<String, dynamic>> _navItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _svc.getSections(publishedOnly: false),
        _svc.getBanners(activeOnly: false),
        _svc.getHomeBanners(activeOnly: false),
        _svc.getNavbarItems(activeOnly: false),
      ]);
      setState(() {
        _sections = results[0] as List<Map<String, dynamic>>;
        _banners = results[1] as List<Map<String, dynamic>>;
        _homeBanners = results[2] as List<Map<String, dynamic>>;
        _navItems = results[3] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) showSuccessSnack(context, 'Error cargando: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            'Home - Secciones',
            'Editá las secciones del home. Cada sección tiene título, subtítulo, layout y posición. '
            'Podés agregar, editar, reordenar y ocultar secciones.',
          ),
          const SizedBox(height: 20),

          // ========== SECCIONES ==========
          _sectionHeader('Secciones del Home', Icons.view_agenda, onAdd: _addSection),
          ..._sections.map((s) => _buildSectionCard(s)),

          const SizedBox(height: 30),

          // ========== BANNERS DEL HERO ==========
          _sectionHeader('Banners del Carrusel Principal', Icons.panorama, onAdd: _addBanner),
          ..._banners.map((b) => _buildBannerCard(b)),

          const SizedBox(height: 30),

          // ========== BANNERS OPCIONALES ==========
          _sectionHeader('Banners Opcionales', Icons.add_photo_alternate, onAdd: _addHomeBanner),
          const Text('Banners temporales que aparecen en el hero. Podés programar fechas.', style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE))),
          const SizedBox(height: 8),
          ..._homeBanners.map((b) => _buildHomeBannerCard(b)),

          const SizedBox(height: 30),

          // ========== NAVBAR ==========
          _sectionHeader('Barra de Navegación', Icons.menu, onAdd: _addNavItem),
          const Text('Editá los links de la barra superior. Cada uno apunta a una sección.', style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE))),
          const SizedBox(height: 8),
          ..._navItems.map((n) => _buildNavItemCard(n)),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF66BB6A)),
          const SizedBox(width: 12),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF8A9BAE))),
            ],
          )),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, IconData icon, {VoidCallback? onAdd}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF66BB6A), size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const Spacer(),
          if (onAdd != null)
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF66BB6A)),
              onPressed: onAdd,
              tooltip: 'Agregar',
            ),
        ],
      ),
    );
  }

  // ========== SECCIONES ==========
  Widget _buildSectionCard(Map<String, dynamic> s) {
    final published = s['published'] == true;
    return Card(
      color: const Color(0xFF1A2230),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          published ? Icons.visibility : Icons.visibility_off,
          color: published ? const Color(0xFF66BB6A) : const Color(0xFF8A9BAE),
          size: 20,
        ),
        title: Text(s['title'] as String? ?? '', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text('Layout: ${s['layout']} · Posición: ${s['position']}', style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BAE))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editSection(s), tooltip: 'Editar'),
            IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteSection(s), tooltip: 'Eliminar'),
          ],
        ),
      ),
    );
  }

  Future<void> _addSection() async {
    final result = await _showSectionDialog(null);
    if (result != null) {
      await _svc.upsertSection(result);
      showSuccessSnack(context, 'Sección creada con éxito');
      _load();
    }
  }

  Future<void> _editSection(Map<String, dynamic> s) async {
    final result = await _showSectionDialog(s);
    if (result != null) {
      result['id'] = s['id'];
      await _svc.upsertSection(result);
      showSuccessSnack(context, 'Sección actualizada con éxito');
      _load();
    }
  }

  Future<void> _deleteSection(Map<String, dynamic> s) async {
    final confirm = await showConfirmDialog(context, 'Eliminar sección "${s['title']}"?');
    if (confirm) {
      await _svc.deleteSection(s['id'] as String);
      showSuccessSnack(context, 'Sección eliminada');
      _load();
    }
  }

  Future<Map<String, dynamic>?> _showSectionDialog(Map<String, dynamic>? existing) async {
    final titleCtrl = TextEditingController(text: existing?['title'] as String? ?? '');
    final subtitleCtrl = TextEditingController(text: existing?['subtitle'] as String? ?? '');
    final slugCtrl = TextEditingController(text: existing?['slug'] as String? ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] as String? ?? '');
    final posCtrl = TextEditingController(text: (existing?['position'] ?? 0).toString());
    String layout = existing?['layout'] as String? ?? 'carousel';
    bool published = existing?['published'] as bool? ?? true;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Nueva Sección' : 'Editar Sección'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título *')),
                const SizedBox(height: 8),
                TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Subtítulo')),
                const SizedBox(height: 8),
                TextField(controller: slugCtrl, decoration: const InputDecoration(labelText: 'Slug (único) *', hintText: 'ej: promos')),
                const SizedBox(height: 8),
                TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: layout,
                  decoration: const InputDecoration(labelText: 'Layout'),
                  items: const [
                    DropdownMenuItem(value: 'banner', child: Text('Banner hero')),
                    DropdownMenuItem(value: 'carousel', child: Text('Carrusel horizontal')),
                    DropdownMenuItem(value: 'netflix', child: Text('Netflix (por categorías)')),
                    DropdownMenuItem(value: 'grid', child: Text('Grilla')),
                    DropdownMenuItem(value: 'locations', child: Text('Sucursales')),
                    DropdownMenuItem(value: 'custom', child: Text('Custom (reservas, etc)')),
                  ],
                  onChanged: (v) => setDialogState(() => layout = v ?? layout),
                ),
                const SizedBox(height: 8),
                TextField(controller: posCtrl, decoration: const InputDecoration(labelText: 'Posición'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Publicada'),
                  value: published,
                  onChanged: (v) => setDialogState(() => published = v),
                  activeColor: const Color(0xFF66BB6A),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (titleCtrl.text.isEmpty || slugCtrl.text.isEmpty) return;
                Navigator.pop(ctx, {
                  'title': titleCtrl.text,
                  'subtitle': subtitleCtrl.text,
                  'slug': slugCtrl.text,
                  'description': descCtrl.text,
                  'layout': layout,
                  'position': int.tryParse(posCtrl.text) ?? 0,
                  'published': published,
                });
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== BANNERS ==========
  Widget _buildBannerCard(Map<String, dynamic> b) {
    return Card(
      color: const Color(0xFF1A2230),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.panorama, size: 20),
        title: Text(b['title'] as String? ?? '(Sin título)', style: const TextStyle(fontSize: 14)),
        subtitle: Text('Pos: ${b['position']} · ${b['active'] == true ? 'Activo' : 'Inactivo'}', style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BAE))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editBanner(b)),
            IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteBanner(b)),
          ],
        ),
      ),
    );
  }

  Future<void> _addBanner() async {
    final result = await _showBannerDialog(null);
    if (result != null) {
      await _svc.upsertBanner(result);
      showSuccessSnack(context, 'Banner creado con éxito');
      _load();
    }
  }

  Future<void> _editBanner(Map<String, dynamic> b) async {
    final result = await _showBannerDialog(b);
    if (result != null) {
      result['id'] = b['id'];
      await _svc.upsertBanner(result);
      showSuccessSnack(context, 'Banner actualizado');
      _load();
    }
  }

  Future<void> _deleteBanner(Map<String, dynamic> b) async {
    final confirm = await showConfirmDialog(context, 'Eliminar banner?');
    if (confirm) {
      await _svc.deleteBanner(b['id'] as String);
      showSuccessSnack(context, 'Banner eliminado');
      _load();
    }
  }

  Future<Map<String, dynamic>?> _showBannerDialog(Map<String, dynamic>? existing) async {
    final titleCtrl = TextEditingController(text: existing?['title'] as String? ?? '');
    final subtitleCtrl = TextEditingController(text: existing?['subtitle'] as String? ?? '');
    final posCtrl = TextEditingController(text: (existing?['position'] ?? 0).toString());
    String? sectionId = existing?['section_id'] as String?;
    bool active = existing?['active'] as bool? ?? true;
    String imagePath = existing?['image_path'] as String? ?? '';

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Nuevo Banner' : 'Editar Banner'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 8),
                TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Subtítulo')),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: sectionId,
                  decoration: const InputDecoration(labelText: 'Sección'),
                  items: _sections.map((s) => DropdownMenuItem(value: s['id'] as String, child: Text(s['title'] as String? ?? ''))).toList(),
                  onChanged: (v) => setDialogState(() => sectionId = v),
                ),
                const SizedBox(height: 8),
                ImagePickerField(
                  currentPath: imagePath,
                  folder: 'banners',
                  onChanged: (path) => setDialogState(() => imagePath = path),
                ),
                const SizedBox(height: 8),
                TextField(controller: posCtrl, decoration: const InputDecoration(labelText: 'Posición'), keyboardType: TextInputType.number),
                SwitchListTile(title: const Text('Activo'), value: active, onChanged: (v) => setDialogState(() => active = v)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {
                'title': titleCtrl.text,
                'subtitle': subtitleCtrl.text,
                'section_id': sectionId,
                'image_path': imagePath,
                'position': int.tryParse(posCtrl.text) ?? 0,
                'active': active,
              }),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== HOME BANNERS ==========
  Widget _buildHomeBannerCard(Map<String, dynamic> b) {
    return Card(
      color: const Color(0xFF1A2230),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(b['title'] as String? ?? '(Sin título)', style: const TextStyle(fontSize: 14)),
        subtitle: Text('${b['active'] == true ? 'Activo' : 'Inactivo'}', style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BAE))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editHomeBanner(b)),
            IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteHomeBanner(b)),
          ],
        ),
      ),
    );
  }

  Future<void> _addHomeBanner() async {
    final result = await _showHomeBannerDialog(null);
    if (result != null) {
      await _svc.upsertHomeBanner(result);
      showSuccessSnack(context, 'Banner opcional creado');
      _load();
    }
  }

  Future<void> _editHomeBanner(Map<String, dynamic> b) async {
    final result = await _showHomeBannerDialog(b);
    if (result != null) {
      result['id'] = b['id'];
      await _svc.upsertHomeBanner(result);
      showSuccessSnack(context, 'Banner actualizado');
      _load();
    }
  }

  Future<void> _deleteHomeBanner(Map<String, dynamic> b) async {
    final confirm = await showConfirmDialog(context, 'Eliminar banner opcional?');
    if (confirm) {
      await _svc.deleteHomeBanner(b['id'] as String);
      showSuccessSnack(context, 'Eliminado');
      _load();
    }
  }

  Future<Map<String, dynamic>?> _showHomeBannerDialog(Map<String, dynamic>? existing) async {
    final titleCtrl = TextEditingController(text: existing?['title'] as String? ?? '');
    final subtitleCtrl = TextEditingController(text: existing?['subtitle'] as String? ?? '');
    bool active = existing?['active'] as bool? ?? true;
    String imagePath = existing?['image_path'] as String? ?? '';

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Nuevo Banner Opcional' : 'Editar Banner'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título')),
                const SizedBox(height: 8),
                TextField(controller: subtitleCtrl, decoration: const InputDecoration(labelText: 'Subtítulo')),
                const SizedBox(height: 8),
                ImagePickerField(
                  currentPath: imagePath,
                  folder: 'home-banners',
                  onChanged: (path) => setDialogState(() => imagePath = path),
                ),
                SwitchListTile(title: const Text('Activo'), value: active, onChanged: (v) => setDialogState(() => active = v)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, {
                'title': titleCtrl.text,
                'subtitle': subtitleCtrl.text,
                'image_path': imagePath,
                'active': active,
              }),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  // ========== NAVBAR ==========
  Widget _buildNavItemCard(Map<String, dynamic> n) {
    return Card(
      color: const Color(0xFF1A2230),
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.link, size: 18),
        title: Text(n['label'] as String? ?? '', style: const TextStyle(fontSize: 14)),
        subtitle: Text('Apunta a: ${n['section_slug'] ?? n['url'] ?? ''}', style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BAE))),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editNavItem(n)),
            IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteNavItem(n)),
          ],
        ),
      ),
    );
  }

  Future<void> _addNavItem() async {
    final result = await _showNavItemDialog(null);
    if (result != null) {
      await _svc.upsertNavbarItem(result);
      showSuccessSnack(context, 'Item de nav creado');
      _load();
    }
  }

  Future<void> _editNavItem(Map<String, dynamic> n) async {
    final result = await _showNavItemDialog(n);
    if (result != null) {
      result['id'] = n['id'];
      await _svc.upsertNavbarItem(result);
      showSuccessSnack(context, 'Actualizado');
      _load();
    }
  }

  Future<void> _deleteNavItem(Map<String, dynamic> n) async {
    final confirm = await showConfirmDialog(context, 'Eliminar "${n['label']}" del navbar?');
    if (confirm) {
      await _svc.deleteNavbarItem(n['id'] as String);
      showSuccessSnack(context, 'Eliminado');
      _load();
    }
  }

  Future<Map<String, dynamic>?> _showNavItemDialog(Map<String, dynamic>? existing) async {
    final labelCtrl = TextEditingController(text: existing?['label'] as String? ?? '');
    final posCtrl = TextEditingController(text: (existing?['position'] ?? 0).toString());
    String? sectionSlug = existing?['section_slug'] as String?;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? 'Nuevo Item' : 'Editar Item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: labelCtrl, decoration: const InputDecoration(labelText: 'Texto del link *')),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: sectionSlug,
              decoration: const InputDecoration(labelText: 'Sección destino'),
              items: _sections.map((s) => DropdownMenuItem(value: s['slug'] as String, child: Text(s['title'] as String? ?? ''))).toList(),
              onChanged: (v) => sectionSlug = v,
            ),
            const SizedBox(height: 8),
            TextField(controller: posCtrl, decoration: const InputDecoration(labelText: 'Posición'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              if (labelCtrl.text.isEmpty) return;
              Navigator.pop(ctx, {
                'label': labelCtrl.text,
                'section_slug': sectionSlug,
                'position': int.tryParse(posCtrl.text) ?? 0,
                'active': true,
              });
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
}
