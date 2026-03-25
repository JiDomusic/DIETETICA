import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';

class AnalyticsTab extends StatefulWidget {
  const AnalyticsTab({super.key});

  @override
  State<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends State<AnalyticsTab> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _topProducts = [];
  List<Map<String, dynamic>> _salesSummary = [];
  List<Map<String, dynamic>> _lowStock = [];
  List<Map<String, dynamic>> _locations = [];
  bool _loading = true;
  String? _selectedLocation;
  int _days = 30;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final results = await Future.wait([
        _svc.getTopProducts(),
        _svc.getStockMovementsSummary(locationId: _selectedLocation, days: _days),
        _svc.getLowStock(),
        _svc.getLocations(),
      ]);
      setState(() {
        _topProducts = results[0] as List<Map<String, dynamic>>;
        _salesSummary = results[1] as List<Map<String, dynamic>>;
        _lowStock = results[2] as List<Map<String, dynamic>>;
        _locations = results[3] as List<Map<String, dynamic>>;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
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
          // Filtros
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.analytics, color: Color(0xFFF0A830)),
                  SizedBox(width: 8),
                  Text('Analytics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width < 700 ? double.infinity : 200,
                child: DropdownButtonFormField<String>(
                  value: _selectedLocation,
                  decoration: const InputDecoration(labelText: 'Sucursal', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('Todas')),
                    ..._locations.map((l) => DropdownMenuItem(value: l['id'] as String, child: Text(l['name'] as String? ?? ''))),
                  ],
                  onChanged: (v) { _selectedLocation = v; _load(); },
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width < 700 ? double.infinity : 120,
                child: DropdownButtonFormField<int>(
                  value: _days,
                  decoration: const InputDecoration(labelText: 'Periodo', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: const [
                    DropdownMenuItem(value: 7, child: Text('7 días')),
                    DropdownMenuItem(value: 30, child: Text('30 días')),
                    DropdownMenuItem(value: 90, child: Text('90 días')),
                  ],
                  onChanged: (v) { _days = v ?? 30; _load(); },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text('Estadísticas de productos más vistos, más vendidos y alertas de stock bajo.', style: TextStyle(fontSize: 12, color: Color(0xFF777777))),

          const SizedBox(height: 24),

          // STOCK BAJO - ALERTAS
          if (_lowStock.isNotEmpty) ...[
            _card(
              'Stock Bajo',
              Icons.warning,
              Colors.red,
              Column(
                children: _lowStock.map((s) {
                  return ListTile(
                    dense: true,
                    leading: const Icon(Icons.warning, color: Colors.red, size: 18),
                    title: Text('${(s['products'] as Map?)?['name'] ?? ''} (${(s['products'] as Map?)?['sku'] ?? ''})'),
                    subtitle: Text('${(s['locations'] as Map?)?['name'] ?? ''} · Qty: ${s['qty']} / Min: ${s['min_qty'] ?? 0}'),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 20),
          ],

          // TOP PRODUCTOS VISTOS
          _card(
            'Productos Más Vistos',
            Icons.visibility,
            const Color(0xFFF0A830),
            _topProducts.isEmpty
                ? const Padding(padding: EdgeInsets.all(16), child: Text('Sin datos aún', style: TextStyle(color: Color(0xFF777777))))
                : Column(
                    children: _topProducts.asMap().entries.map((entry) {
                      final i = entry.key;
                      final p = entry.value;
                      return ListTile(
                        dense: true,
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: const Color(0xFFF0A830),
                          child: Text('${i + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                        ),
                        title: Text(p['product_name'] as String? ?? ''),
                        trailing: Text('${p['view_count']} vistas', style: const TextStyle(color: Color(0xFFF0A830), fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                  ),
          ),
          const SizedBox(height: 20),

          // VENTAS POR PRODUCTO
          _card(
            'Movimientos de Stock (últimos $_days días)',
            Icons.trending_up,
            const Color(0xFFFF8F00),
            _salesSummary.isEmpty
                ? const Padding(padding: EdgeInsets.all(16), child: Text('Sin movimientos', style: TextStyle(color: Color(0xFF777777))))
                : Column(
                    children: _salesSummary.map((s) {
                      return ListTile(
                        dense: true,
                        title: Text(s['product_name'] as String? ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Vendido: ${s['total_sold']}', style: const TextStyle(color: Color(0xFFFF8F00), fontSize: 12)),
                            const SizedBox(width: 12),
                            Text('Devuelto: ${s['total_returned']}', style: const TextStyle(color: Color(0xFF777777), fontSize: 12)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _card(String title, IconData icon, Color color, Widget content) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          content,
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
