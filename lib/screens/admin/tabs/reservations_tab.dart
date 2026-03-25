import 'package:flutter/material.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/admin_helpers.dart';

class ReservationsTab extends StatefulWidget {
  const ReservationsTab({super.key});

  @override
  State<ReservationsTab> createState() => _ReservationsTabState();
}

class _ReservationsTabState extends State<ReservationsTab> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _reservations = [];
  bool _loading = true;
  String _filterStatus = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _reservations = await _svc.getReservations(status: _filterStatus.isEmpty ? null : _filterStatus);
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
                  const Icon(Icons.shopping_bag, color: Color(0xFFF0A830)),
                  const SizedBox(width: 8),
                  Text('Reservas (${_reservations.length})', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                ],
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  value: _filterStatus.isEmpty ? null : _filterStatus,
                  decoration: const InputDecoration(labelText: 'Estado', contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('Todas')),
                    DropdownMenuItem(value: 'pending', child: Text('Pendientes')),
                    DropdownMenuItem(value: 'confirmed', child: Text('Confirmadas')),
                    DropdownMenuItem(value: 'paid', child: Text('Pagadas')),
                    DropdownMenuItem(value: 'picked_up', child: Text('Retiradas')),
                    DropdownMenuItem(value: 'canceled', child: Text('Canceladas')),
                  ],
                  onChanged: (v) {
                    _filterStatus = v ?? '';
                    _load();
                  },
                ),
              ),
              IconButton(icon: const Icon(Icons.refresh), onPressed: _load, tooltip: 'Actualizar'),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Gestioná las reservas de productos. Podés confirmar, marcar como pagada, retirada o cancelar (devuelve stock).', style: TextStyle(fontSize: 12, color: Color(0xFF777777))),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _reservations.length,
            itemBuilder: (context, i) {
              final r = _reservations[i];
              final productName = (r['products'] as Map?)?['name'] ?? 'Producto';
              final locationName = (r['locations'] as Map?)?['name'] ?? '';
              final status = r['status'] as String? ?? 'pending';
              final date = DateTime.tryParse(r['created_at'] as String? ?? '')?.toLocal();

              return Card(
                color: Colors.white,
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _statusChip(status),
                          const SizedBox(width: 8),
                          Expanded(child: Text(productName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14))),
                          Text('x${r['qty']}', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFFF0A830))),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text('Cliente: ${r['customer_name'] ?? ''} · Tel: ${r['customer_phone'] ?? ''}', style: const TextStyle(fontSize: 12)),
                      if (locationName.isNotEmpty) Text('Sucursal: $locationName', style: const TextStyle(fontSize: 12, color: Color(0xFF777777))),
                      if ((r['payment_ref'] as String? ?? '').isNotEmpty) Text('Comprobante: ${r['payment_ref']}', style: const TextStyle(fontSize: 12, color: Color(0xFF777777))),
                      if (date != null) Text('Fecha: ${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}', style: const TextStyle(fontSize: 11, color: Color(0xFF777777))),
                      const SizedBox(height: 8),
                      // Acciones
                      Wrap(
                        spacing: 8,
                        children: [
                          if (status == 'pending')
                            _actionBtn('Confirmar', Icons.check, Colors.blue, () => _updateStatus(r, 'confirmed')),
                          if (status == 'confirmed')
                            _actionBtn('Marcar Pagada', Icons.payment, const Color(0xFFF0A830), () => _updateStatus(r, 'paid')),
                          if (status == 'paid')
                            _actionBtn('Retirada', Icons.shopping_bag, const Color(0xFF4CAF50), () => _updateStatus(r, 'picked_up')),
                          if (status != 'canceled' && status != 'picked_up')
                            _actionBtn('Cancelar', Icons.cancel, Colors.red, () => _cancel(r)),
                        ],
                      ),
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

  Widget _statusChip(String status) {
    Color color;
    String label;
    switch (status) {
      case 'pending': color = Colors.orange; label = 'Pendiente'; break;
      case 'confirmed': color = Colors.blue; label = 'Confirmada'; break;
      case 'paid': color = const Color(0xFFF0A830); label = 'Pagada'; break;
      case 'picked_up': color = const Color(0xFF4CAF50); label = 'Retirada'; break;
      case 'canceled': color = Colors.red; label = 'Cancelada'; break;
      default: color = const Color(0xFF777777); label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: color)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, VoidCallback onPressed) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 14, color: color),
      label: Text(label, style: TextStyle(fontSize: 11, color: color)),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
      ),
    );
  }

  Future<void> _updateStatus(Map<String, dynamic> r, String newStatus) async {
    try {
      await _svc.updateReservationStatus(r['id'] as String, newStatus);
      showSuccessSnack(context, 'Reserva actualizada a $newStatus');
      _load();
    } catch (e) {
      showSuccessSnack(context, 'Error: $e', isError: true);
    }
  }

  Future<void> _cancel(Map<String, dynamic> r) async {
    if (await showConfirmDialog(context, 'Cancelar reserva? Se devolverá el stock.')) {
      try {
        await _svc.cancelReservation(r['id'] as String);
        showSuccessSnack(context, 'Reserva cancelada y stock devuelto');
        _load();
      } catch (e) {
        showSuccessSnack(context, 'Error: $e', isError: true);
      }
    }
  }
}
