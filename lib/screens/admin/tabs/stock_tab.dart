import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/admin_helpers.dart';

class StockTab extends StatefulWidget {
  const StockTab({super.key});

  @override
  State<StockTab> createState() => _StockTabState();
}

class _StockTabState extends State<StockTab> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _stock = [];
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _movements = [];
  bool _loading = true;
  String _filterLocation = '';
  bool _showMovements = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _svc.getStock(),
      _svc.getLocations(),
      _svc.getAllProducts(),
      _svc.getStockMovements(),
    ]);
    setState(() {
      _stock = results[0] as List<Map<String, dynamic>>;
      _locations = results[1] as List<Map<String, dynamic>>;
      _products = results[2] as List<Map<String, dynamic>>;
      _movements = results[3] as List<Map<String, dynamic>>;
      _loading = false;
    });
  }

  List<Map<String, dynamic>> get _filtered {
    if (_filterLocation.isEmpty) return _stock;
    return _stock.where((s) => s['location_id'] == _filterLocation).toList();
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 700;

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warehouse, color: Color(0xFFF0A830)),
                      const SizedBox(width: 8),
                      Text('Stock (${_filtered.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => setState(() => _showMovements = !_showMovements),
                    icon: Icon(_showMovements ? Icons.inventory : Icons.history, size: 16),
                    label: Text(_showMovements ? 'Ver Stock' : 'Ver Movimientos'),
                  ),
                  ElevatedButton.icon(
                    onPressed: _addStock,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Cargar Stock'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Acá ves el stock de cada producto en cada sucursal. Podés ajustar cantidades manualmente. '
                'Los movimientos registran cada cambio.',
                style: TextStyle(fontSize: 12, color: Color(0xFF777777)),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: _isMobile ? double.infinity : 250,
                child: DropdownButtonFormField<String>(
                  value: _filterLocation.isEmpty ? null : _filterLocation,
                  decoration: const InputDecoration(labelText: 'Filtrar por sucursal', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: [
                    const DropdownMenuItem(value: '', child: Text('Todas')),
                    ..._locations.map((l) => DropdownMenuItem(value: l['id'] as String, child: Text(l['name'] as String? ?? ''))),
                  ],
                  onChanged: (v) => setState(() => _filterLocation = v ?? ''),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _showMovements ? _buildMovements() : _buildStockList(),
        ),
      ],
    );
  }

  Widget _buildStockList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filtered.length,
      itemBuilder: (context, i) {
        final s = _filtered[i];
        final qty = s['qty'] as int? ?? 0;
        final minQty = s['min_qty'] as int? ?? 0;
        final productName = (s['products'] as Map?)?['name'] ?? '';
        final sku = (s['products'] as Map?)?['sku'] ?? '';
        final locationName = (s['locations'] as Map?)?['name'] ?? '';
        final isLow = qty <= minQty;

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isLow ? Colors.red.withValues(alpha: 0.2) : const Color(0xFF4CAF50).withValues(alpha: 0.2),
              child: Text('$qty', style: TextStyle(
                color: isLow ? Colors.red : const Color(0xFFF0A830),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              )),
            ),
            title: Text('$productName ($sku)', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(
              '$locationName · Min: $minQty ${isLow ? '⚠️ STOCK BAJO' : ''}',
              style: TextStyle(fontSize: 11, color: isLow ? Colors.red : const Color(0xFF777777)),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, size: 20, color: Color(0xFFFF8F00)),
                  tooltip: 'Decrementar',
                  onPressed: () => _adjustStock(s, -1),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 20, color: Color(0xFFF0A830)),
                  tooltip: 'Incrementar',
                  onPressed: () => _adjustStock(s, 1),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'Editar cantidad',
                  onPressed: () => _editStockQty(s),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMovements() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _movements.length,
      itemBuilder: (context, i) {
        final m = _movements[i];
        final delta = m['delta'] as int? ?? 0;
        final reason = m['reason'] as String? ?? '';
        final productName = (m['products'] as Map?)?['name'] ?? '';
        final locationName = (m['locations'] as Map?)?['name'] ?? '';
        final date = DateTime.tryParse(m['created_at'] as String? ?? '')?.toLocal();

        return Card(
          color: Colors.white,
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: Icon(
              delta > 0 ? Icons.arrow_upward : Icons.arrow_downward,
              color: delta > 0 ? const Color(0xFFF0A830) : Colors.red,
              size: 20,
            ),
            title: Text('$productName: ${delta > 0 ? '+' : ''}$delta', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            subtitle: Text('$locationName · $reason · ${date != null ? '${date.day}/${date.month} ${date.hour}:${date.minute.toString().padLeft(2, '0')}' : ''}',
              style: const TextStyle(fontSize: 11, color: Color(0xFF777777))),
          ),
        );
      },
    );
  }

  Future<void> _adjustStock(Map<String, dynamic> s, int delta) async {
    try {
      if (delta > 0) {
        await _svc.incrementStock(s['product_id'], s['location_id'], delta.abs());
      } else {
        await _svc.decrementStock(s['product_id'], s['location_id'], delta.abs());
      }
      showSuccessSnack(context, 'Stock ajustado');
      _load();
    } catch (e) {
      showSuccessSnack(context, 'Error: $e', isError: true);
    }
  }

  Future<void> _editStockQty(Map<String, dynamic> s) async {
    final ctrl = TextEditingController(text: (s['qty'] as int? ?? 0).toString());
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar Stock'),
        content: TextField(controller: ctrl, decoration: const InputDecoration(labelText: 'Nueva cantidad'), keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, int.tryParse(ctrl.text)),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
    if (result != null) {
      try {
        await _svc.setStock(s['product_id'], s['location_id'], result);
        showSuccessSnack(context, 'Stock actualizado a $result');
        _load();
      } catch (e) {
        showSuccessSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _addStock() async {
    String? productId;
    String? locationId;
    final qtyCtrl = TextEditingController(text: '0');
    final minCtrl = TextEditingController(text: '0');

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Cargar Stock'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: productId,
                decoration: const InputDecoration(labelText: 'Producto *'),
                items: _products.map((p) => DropdownMenuItem(value: p['id'] as String, child: Text('${p['name']} (${p['sku']})'))).toList(),
                onChanged: (v) => setDialogState(() => productId = v),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: locationId,
                decoration: const InputDecoration(labelText: 'Sucursal *'),
                items: _locations.map((l) => DropdownMenuItem(value: l['id'] as String, child: Text(l['name'] as String? ?? ''))).toList(),
                onChanged: (v) => setDialogState(() => locationId = v),
              ),
              const SizedBox(height: 8),
              TextField(controller: qtyCtrl, decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number),
              const SizedBox(height: 8),
              TextField(controller: minCtrl, decoration: const InputDecoration(labelText: 'Stock mínimo (alerta)'), keyboardType: TextInputType.number),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () {
                if (productId == null || locationId == null) return;
                Navigator.pop(ctx, true);
              },
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );

    if (result == true && productId != null && locationId != null) {
      try {
        await _svc.setStock(productId!, locationId!, int.tryParse(qtyCtrl.text) ?? 0);
        showSuccessSnack(context, 'Stock cargado con éxito');
        _load();
      } catch (e) {
        showSuccessSnack(context, 'Error: $e', isError: true);
      }
    }
  }
}
