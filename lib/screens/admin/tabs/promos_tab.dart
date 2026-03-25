import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/admin_helpers.dart';

class PromosTab extends StatefulWidget {
  const PromosTab({super.key});

  @override
  State<PromosTab> createState() => _PromosTabState();
}

class _PromosTabState extends State<PromosTab> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _promos = [];
  List<Map<String, dynamic>> _products = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _svc.getPromos(activeOnly: false),
      _svc.getAllProducts(),
    ]);
    setState(() {
      _promos = results[0] as List<Map<String, dynamic>>;
      _products = results[1] as List<Map<String, dynamic>>;
      _loading = false;
    });
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
                  const Icon(Icons.local_offer, color: Color(0xFFFF8F00)),
                  const SizedBox(width: 8),
                  Text('Promociones (${_promos.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _addPromo,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nueva Promo'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF8F00)),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Creá promociones para tus productos. Podés poner descuento %, precio promo, texto y fechas.', style: TextStyle(fontSize: 12, color: Color(0xFF777777))),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _promos.length,
            itemBuilder: (context, i) {
              final promo = _promos[i];
              final productName = (promo['products'] as Map?)?['name'] ?? 'Producto';
              final title = promo['title'] as String? ?? productName;
              final discount = promo['discount_pct'] as num?;
              final active = promo['active'] == true;

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.local_offer, color: active ? const Color(0xFFFF8F00) : const Color(0xFF777777)),
                  title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: Text(
                    '$productName · ${discount != null ? '-${discount.toStringAsFixed(0)}%' : ''} · ${active ? 'Activa' : 'Inactiva'}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF777777)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editPromo(promo)),
                      IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deletePromo(promo)),
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

  Future<void> _addPromo() async {
    final result = await _showPromoDialog(null);
    if (result != null) {
      await _svc.upsertPromo(result);
      showSuccessSnack(context, 'Promoción creada con éxito');
      _load();
    }
  }

  Future<void> _editPromo(Map<String, dynamic> p) async {
    final result = await _showPromoDialog(p);
    if (result != null) {
      result['id'] = p['id'];
      await _svc.upsertPromo(result);
      showSuccessSnack(context, 'Promoción actualizada');
      _load();
    }
  }

  Future<void> _deletePromo(Map<String, dynamic> p) async {
    if (await showConfirmDialog(context, 'Eliminar promoción?')) {
      await _svc.deletePromo(p['id'] as String);
      showSuccessSnack(context, 'Eliminada');
      _load();
    }
  }

  Future<Map<String, dynamic>?> _showPromoDialog(Map<String, dynamic>? existing) async {
    final titleCtrl = TextEditingController(text: existing?['title'] as String? ?? '');
    final textCtrl = TextEditingController(text: existing?['promo_text'] as String? ?? '');
    final discCtrl = TextEditingController(text: (existing?['discount_pct'] as num?)?.toString() ?? '');
    final priceCtrl = TextEditingController(text: (existing?['promo_price'] as num?)?.toString() ?? '');
    String? productId = existing?['product_id'] as String?;
    bool active = existing?['active'] as bool? ?? true;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Nueva Promoción' : 'Editar Promoción'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: productId,
                  decoration: const InputDecoration(labelText: 'Producto *'),
                  items: _products.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text(p['name'] as String? ?? ''))).toList(),
                  onChanged: (v) => setDialogState(() => productId = v),
                ),
                const SizedBox(height: 8),
                TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Título de promo')),
                const SizedBox(height: 8),
                TextField(controller: textCtrl, decoration: const InputDecoration(labelText: 'Texto promo (ej: 2x1, Llevate 3...)'), maxLines: 2),
                const SizedBox(height: 8),
                TextField(controller: discCtrl, decoration: const InputDecoration(labelText: 'Descuento %', suffixText: '%'), keyboardType: TextInputType.number),
                const SizedBox(height: 8),
                TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio promo', prefixText: '\$ '), keyboardType: TextInputType.number),
                SwitchListTile(title: const Text('Activa'), value: active, onChanged: (v) => setDialogState(() => active = v)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (productId == null) return;
                Navigator.pop(ctx, {
                  'product_id': productId,
                  'title': titleCtrl.text,
                  'promo_text': textCtrl.text,
                  'discount_pct': double.tryParse(discCtrl.text),
                  'promo_price': double.tryParse(priceCtrl.text),
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
