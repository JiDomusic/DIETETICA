import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/admin_helpers.dart';

class LocationsTab extends StatefulWidget {
  const LocationsTab({super.key});

  @override
  State<LocationsTab> createState() => _LocationsTabState();
}

class _LocationsTabState extends State<LocationsTab> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _locations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _locations = await _svc.getLocations(activeOnly: false);
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.store, color: Color(0xFFF0A830)),
                  const SizedBox(width: 8),
                  Text('Sucursales (${_locations.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              ElevatedButton.icon(onPressed: _add, icon: const Icon(Icons.add, size: 18), label: const Text('Nueva Sucursal')),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Cargá las 3 sucursales con nombre, dirección completa (se genera mapa automático con Google Maps), teléfono, WhatsApp, horario e imagen.',
            style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _locations.length,
            itemBuilder: (context, i) {
              final loc = _locations[i];
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.store, color: Color(0xFFF0A830), size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text(loc['name'] as String? ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700))),
                          IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _edit(loc)),
                          IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _delete(loc)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if ((loc['address'] as String? ?? '').isNotEmpty)
                        _info(Icons.location_on, loc['address'] as String),
                      if ((loc['phone'] as String? ?? '').isNotEmpty)
                        _info(Icons.phone, loc['phone'] as String),
                      if ((loc['whatsapp'] as String? ?? '').isNotEmpty)
                        _info(Icons.chat, 'WhatsApp: ${loc['whatsapp']}'),
                      if ((loc['horario'] as String? ?? '').isNotEmpty)
                        _info(Icons.schedule, loc['horario'] as String),
                      if ((loc['map_url'] as String? ?? '').isNotEmpty)
                        _info(Icons.map, 'Maps: ${loc['map_url']}'),
                      _info(Icons.circle, loc['active'] == true ? 'Activa' : 'Inactiva'),
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

  Widget _info(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFF777777)),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, color: Color(0xFF777777)))),
        ],
      ),
    );
  }

  Future<void> _add() async {
    final result = await _showDialog(null);
    if (result != null) {
      await _svc.upsertLocation(result);
      showSuccessSnack(context, 'Sucursal creada con éxito');
      _load();
    }
  }

  Future<void> _edit(Map<String, dynamic> loc) async {
    final result = await _showDialog(loc);
    if (result != null) {
      result['id'] = loc['id'];
      await _svc.upsertLocation(result);
      showSuccessSnack(context, 'Sucursal actualizada');
      _load();
    }
  }

  Future<void> _delete(Map<String, dynamic> loc) async {
    if (await showConfirmDialog(context, 'Eliminar sucursal "${loc['name']}"? Se perderá su stock asociado.')) {
      await _svc.deleteLocation(loc['id'] as String);
      showSuccessSnack(context, 'Eliminada');
      _load();
    }
  }

  Future<Map<String, dynamic>?> _showDialog(Map<String, dynamic>? existing) async {
    final nameCtrl = TextEditingController(text: existing?['name'] as String? ?? '');
    final addressCtrl = TextEditingController(text: existing?['address'] as String? ?? '');
    final phoneCtrl = TextEditingController(text: existing?['phone'] as String? ?? '');
    final waCtrl = TextEditingController(text: existing?['whatsapp'] as String? ?? '');
    final mapCtrl = TextEditingController(text: existing?['map_url'] as String? ?? '');
    final horarioCtrl = TextEditingController(text: existing?['horario'] as String? ?? '');
    String imagePath = existing?['image_path'] as String? ?? '';
    bool active = existing?['active'] as bool? ?? true;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Nueva Sucursal' : 'Editar Sucursal'),
          content: SizedBox(
            width: MediaQuery.of(ctx).size.width < 580 ? MediaQuery.of(ctx).size.width - 80 : 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre *', hintText: 'Ej: Sucursal Centro')),
                  const SizedBox(height: 8),
                  TextField(controller: addressCtrl, decoration: const InputDecoration(labelText: 'Dirección completa *', hintText: 'Se usa para generar el mapa en el Home')),
                  const SizedBox(height: 8),
                  TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'Teléfono')),
                  const SizedBox(height: 8),
                  TextField(controller: waCtrl, decoration: const InputDecoration(labelText: 'WhatsApp (con cód. país)', hintText: '549341...')),
                  const SizedBox(height: 8),
                  TextField(controller: horarioCtrl, decoration: const InputDecoration(labelText: 'Horario de atención')),
                  const SizedBox(height: 8),
                  TextField(controller: mapCtrl, decoration: const InputDecoration(labelText: 'URL de Google Maps (opcional)', hintText: 'Si no ponés, se genera automáticamente desde la dirección')),
                  const SizedBox(height: 12),
                  ImagePickerField(
                    currentPath: imagePath,
                    folder: 'locations',
                    onChanged: (path) => setDialogState(() => imagePath = path),
                  ),
                  SwitchListTile(title: const Text('Activa'), value: active, onChanged: (v) => setDialogState(() => active = v)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty) return;
                Navigator.pop(ctx, {
                  'name': nameCtrl.text,
                  'address': addressCtrl.text,
                  'phone': phoneCtrl.text,
                  'whatsapp': waCtrl.text,
                  'map_url': mapCtrl.text,
                  'horario': horarioCtrl.text,
                  'image_path': imagePath,
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
