import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';

class ReservationSection extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> locations;
  final Map<String, String> config;

  const ReservationSection({super.key, required this.products, required this.locations, required this.config});

  @override
  State<ReservationSection> createState() => _ReservationSectionState();
}

class _ReservationSectionState extends State<ReservationSection> {
  String? _selectedProductId;
  String? _selectedLocationId;
  final _qtyCtrl = TextEditingController(text: '1');
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  bool _loading = false;
  bool _success = false;

  @override
  Widget build(BuildContext context) {
    final cbuInfo = widget.config['cbu_info'] ?? '';
    final alias = widget.config['alias_cbu'] ?? '';
    final whatsapp = widget.config['whatsapp_default'] ?? '';
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF141A22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
      ),
      child: _success ? _buildSuccessView(whatsapp) : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shopping_bag, color: Color(0xFF66BB6A)),
              SizedBox(width: 8),
              Text('Reservá tu producto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Elegí el producto, pagá por CBU y pasá a retirarlo. Te confirmamos por WhatsApp.',
            style: TextStyle(fontSize: 13, color: Color(0xFF8A9BAE)),
          ),
          const SizedBox(height: 20),

          // Datos de pago CBU
          if (cbuInfo.isNotEmpty || alias.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Datos de pago:', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF66BB6A))),
                  if (cbuInfo.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    SelectableText('CBU: $cbuInfo', style: const TextStyle(fontSize: 13)),
                  ],
                  if (alias.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    SelectableText('Alias: $alias', style: const TextStyle(fontSize: 13)),
                  ],
                ],
              ),
            ),

          // Formulario
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 300,
                child: DropdownButtonFormField<String>(
                  value: _selectedProductId,
                  decoration: const InputDecoration(labelText: 'Producto'),
                  items: widget.products.map((p) {
                    return DropdownMenuItem(
                      value: p['id'] as String,
                      child: Text('${p['name']} - \$${(p['price'] as num?)?.toStringAsFixed(2) ?? '0'}', overflow: TextOverflow.ellipsis),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedProductId = v),
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 250,
                child: DropdownButtonFormField<String>(
                  value: _selectedLocationId,
                  decoration: const InputDecoration(labelText: 'Sucursal'),
                  items: widget.locations.map((l) {
                    return DropdownMenuItem(value: l['id'] as String, child: Text(l['name'] as String? ?? ''));
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedLocationId = v),
                ),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 100,
                child: TextFormField(controller: _qtyCtrl, decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: isMobile ? double.infinity : 250,
                child: TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Tu nombre *')),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 200,
                child: TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Teléfono *'), keyboardType: TextInputType.phone),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 250,
                child: TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email (opcional)')),
              ),
              SizedBox(
                width: isMobile ? double.infinity : 300,
                child: TextFormField(controller: _refCtrl, decoration: const InputDecoration(labelText: 'Nº comprobante CBU (opcional)')),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: isMobile ? double.infinity : 250,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _loading ? null : _submitReservation,
              icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle),
              label: Text(_loading ? 'Procesando...' : 'Confirmar Reserva'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(String whatsapp) {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF66BB6A), size: 64),
        const SizedBox(height: 16),
        const Text('¡Reserva enviada con éxito!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Te confirmaremos por WhatsApp.', style: TextStyle(color: Color(0xFF8A9BAE))),
        const SizedBox(height: 20),
        if (whatsapp.isNotEmpty)
          ElevatedButton.icon(
            onPressed: () {
              final msg = Uri.encodeComponent('Hola! Acabo de hacer una reserva de producto. Mi nombre es ${_nameCtrl.text}');
              launchUrl(Uri.parse('https://wa.me/$whatsapp?text=$msg'));
            },
            icon: const Icon(Icons.chat),
            label: const Text('Enviar WhatsApp'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
          ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => setState(() {
            _success = false;
            _selectedProductId = null;
            _selectedLocationId = null;
            _nameCtrl.clear();
            _phoneCtrl.clear();
            _emailCtrl.clear();
            _refCtrl.clear();
            _qtyCtrl.text = '1';
          }),
          child: const Text('Hacer otra reserva'),
        ),
      ],
    );
  }

  Future<void> _submitReservation() async {
    if (_selectedProductId == null || _selectedLocationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seleccioná producto y sucursal')));
      return;
    }
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nombre y teléfono son obligatorios')));
      return;
    }

    setState(() => _loading = true);
    try {
      await SupabaseService.instance.createReservation(
        productId: _selectedProductId!,
        locationId: _selectedLocationId!,
        qty: int.tryParse(_qtyCtrl.text) ?? 1,
        customerName: _nameCtrl.text.trim(),
        customerPhone: _phoneCtrl.text.trim(),
        customerEmail: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        paymentRef: _refCtrl.text.trim().isEmpty ? null : _refCtrl.text.trim(),
      );
      setState(() { _success = true; _loading = false; });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')));
    }
  }

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _refCtrl.dispose();
    super.dispose();
  }
}
