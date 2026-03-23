import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/admin_helpers.dart';

class ProductsTab extends StatefulWidget {
  const ProductsTab({super.key});

  @override
  State<ProductsTab> createState() => _ProductsTabState();
}

class _ProductsTabState extends State<ProductsTab> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;
  String _filterCategory = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _svc.getAllProducts(),
      _svc.getCategories(activeOnly: false),
    ]);
    setState(() {
      _products = results[0] as List<Map<String, dynamic>>;
      _categories = results[1] as List<Map<String, dynamic>>;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filterCategory.isEmpty) return _products;
    return _products.where((p) => p['category_id'] == _filterCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        // Barra superior
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.inventory_2, color: Color(0xFF66BB6A)),
              const SizedBox(width: 8),
              Text('Productos (${_filtered.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(width: 16),
              // Filtro por categoría
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _filterCategory.isEmpty ? null : _filterCategory,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Todas')),
                    ..._categories.map((c) => DropdownMenuItem(
                      value: c['id'] as String, child: Text(c['name'] as String? ?? ''),
                    )),
                  ],
                  onChanged: (v) => setState(() => _filterCategory = v ?? ''),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _addProduct,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Nuevo Producto'),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Creá, editá y eliminá productos. Subí imagen JPG/PNG, asigná categoría, precio y marcá como nuevo, destacado o promo.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE)),
          ),
        ),
        const SizedBox(height: 8),
        // Lista
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _filtered.length,
            itemBuilder: (context, i) {
              final p = _filtered[i];
              final imgPath = p['image_path'] as String? ?? '';
              final catName = (p['categories'] as Map?)?['name'] as String? ?? 'Sin categoría';

              return Card(
                color: const Color(0xFF1A2230),
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: imgPath.isNotEmpty
                        ? Image.network(_svc.getPublicImageUrl(imgPath), width: 50, height: 50, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 40))
                        : Container(width: 50, height: 50, color: const Color(0xFF2A3545), child: const Icon(Icons.eco, size: 24, color: Color(0xFF66BB6A))),
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(p['name'] as String? ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                      if (p['is_promo'] == true) _chip('PROMO', const Color(0xFFFF8F00)),
                      if (p['is_new'] == true) _chip('NUEVO', const Color(0xFF2E7D32)),
                      if (p['is_featured'] == true) _chip('DEST', const Color(0xFF1565C0)),
                    ],
                  ),
                  subtitle: Text(
                    '$catName · SKU: ${p['sku']} · \$${(p['price'] as num?)?.toStringAsFixed(2) ?? '0'} · ${p['is_active'] == true ? 'Activo' : 'Inactivo'}',
                    style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BAE)),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit, size: 18), onPressed: () => _editProduct(p)),
                      IconButton(icon: const Icon(Icons.delete, size: 18, color: Colors.red), onPressed: () => _deleteProduct(p)),
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

  Widget _chip(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white)),
    );
  }

  Future<void> _addProduct() async {
    final result = await _showProductDialog(null);
    if (result != null) {
      try {
        await _svc.upsertProduct(result);
        showSuccessSnack(context, 'Producto creado con éxito');
        _load();
      } catch (e) {
        showSuccessSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _editProduct(Map<String, dynamic> p) async {
    final result = await _showProductDialog(p);
    if (result != null) {
      try {
        result['id'] = p['id'];
        await _svc.upsertProduct(result);
        showSuccessSnack(context, 'Producto actualizado con éxito');
        _load();
      } catch (e) {
        showSuccessSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _deleteProduct(Map<String, dynamic> p) async {
    final confirm = await showConfirmDialog(context, 'Eliminar "${p['name']}"? Se eliminará también su stock.');
    if (confirm) {
      try {
        await _svc.deleteProduct(p['id'] as String);
        showSuccessSnack(context, 'Producto eliminado');
        _load();
      } catch (e) {
        showSuccessSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<Map<String, dynamic>?> _showProductDialog(Map<String, dynamic>? existing) async {
    final nameCtrl = TextEditingController(text: existing?['name'] as String? ?? '');
    final skuCtrl = TextEditingController(text: existing?['sku'] as String? ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] as String? ?? '');
    final priceCtrl = TextEditingController(text: (existing?['price'] as num?)?.toString() ?? '');
    String? categoryId = existing?['category_id'] as String?;
    String imagePath = existing?['image_path'] as String? ?? '';
    bool isActive = existing?['is_active'] as bool? ?? true;
    bool isPromo = existing?['is_promo'] as bool? ?? false;
    bool isNew = existing?['is_new'] as bool? ?? false;
    bool isFeatured = existing?['is_featured'] as bool? ?? false;

    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Nuevo Producto' : 'Editar Producto'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre *')),
                  const SizedBox(height: 8),
                  TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU (único) *', hintText: 'ej: FS-001')),
                  const SizedBox(height: 8),
                  TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 3),
                  const SizedBox(height: 8),
                  TextField(controller: priceCtrl, decoration: const InputDecoration(labelText: 'Precio *', prefixText: '\$ '), keyboardType: TextInputType.number),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: categoryId,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('Sin categoría')),
                      ..._categories.map((c) => DropdownMenuItem(value: c['id'] as String, child: Text(c['name'] as String? ?? ''))),
                    ],
                    onChanged: (v) => setDialogState(() => categoryId = v),
                  ),
                  const SizedBox(height: 12),
                  ImagePickerField(
                    currentPath: imagePath,
                    folder: 'products',
                    onChanged: (path) => setDialogState(() => imagePath = path),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(title: const Text('Activo'), value: isActive, onChanged: (v) => setDialogState(() => isActive = v)),
                  SwitchListTile(title: const Text('En promoción'), value: isPromo, onChanged: (v) => setDialogState(() => isPromo = v), activeColor: const Color(0xFFFF8F00)),
                  SwitchListTile(title: const Text('Producto nuevo'), value: isNew, onChanged: (v) => setDialogState(() => isNew = v), activeColor: const Color(0xFF2E7D32)),
                  SwitchListTile(title: const Text('Destacado'), value: isFeatured, onChanged: (v) => setDialogState(() => isFeatured = v), activeColor: const Color(0xFF1565C0)),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isEmpty || skuCtrl.text.isEmpty || priceCtrl.text.isEmpty) {
                  showSuccessSnack(ctx, 'Completá nombre, SKU y precio', isError: true);
                  return;
                }
                Navigator.pop(ctx, {
                  'name': nameCtrl.text,
                  'sku': skuCtrl.text,
                  'description': descCtrl.text,
                  'price': double.tryParse(priceCtrl.text) ?? 0,
                  'category_id': categoryId,
                  'image_path': imagePath,
                  'is_active': isActive,
                  'is_promo': isPromo,
                  'is_new': isNew,
                  'is_featured': isFeatured,
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
