import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/theme_config.dart';
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
    final primary = ThemeConfig.instance.primary;
    final accent = ThemeConfig.instance.accent;
    final cbuInfo = widget.config['cbu_info'] ?? '';
    final alias = widget.config['alias_cbu'] ?? '';
    final whatsapp = widget.config['whatsapp_default'] ?? '';
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.08),
            Colors.white,
            accent.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: primary.withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.06), blurRadius: 18, offset: const Offset(0, 8)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: primary.withValues(alpha: 0.07),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: _success
                ? _buildSuccessView(whatsapp, primary)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 4)),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.flash_on, color: primary, size: 18),
                                const SizedBox(width: 6),
                                const Text('Reservá y retirás en minutos', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                              ],
                            ),
                          ),
                          const Spacer(),
                          if (!isMobile && whatsapp.isNotEmpty)
                            TextButton.icon(
                              onPressed: () {
                                final msg = Uri.encodeComponent('Hola! Quiero hacer una reserva de producto.');
                                launchUrl(Uri.parse('https://wa.me/$whatsapp?text=$msg'));
                              },
                              icon: const Icon(Icons.chat_bubble_outline),
                              label: const Text('¿Dudas? Escribinos'),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        children: [
                          SizedBox(
                            width: isMobile ? double.infinity : 320,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Reservá tu producto favorito',
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color(0xFF0F1A2B)),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'Elegí, pagá por CBU y retirás sin fila. Te confirmamos por WhatsApp.',
                                  style: TextStyle(fontSize: 14, color: Color(0xFF4B5563)),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildHighlight(primary, Icons.eco, 'Productos frescos'),
                                    _buildHighlight(accent, Icons.timer, 'Confirmación rápida'),
                                    _buildHighlight(primary, Icons.verified_user, 'Pago seguro'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildSteps(primary),
                                const SizedBox(height: 14),
                                if (cbuInfo.isNotEmpty || alias.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(color: primary.withValues(alpha: 0.16)),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Datos de pago', style: TextStyle(fontWeight: FontWeight.w700, color: primary)),
                                        const SizedBox(height: 6),
                                        if (cbuInfo.isNotEmpty)
                                          SelectableText('CBU: $cbuInfo', style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                                        if (alias.isNotEmpty) ...[
                                          const SizedBox(height: 4),
                                          SelectableText('Alias: $alias', style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A))),
                                        ],
                                        const SizedBox(height: 6),
                                        const Text('Enviá el comprobante y listo.', style: TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: isMobile ? double.infinity : 420,
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: primary.withValues(alpha: 0.1)),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 18, offset: const Offset(0, 10)),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.shopping_bag_outlined, color: primary),
                                      const SizedBox(width: 8),
                                      const Text('Formulario de reserva', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      SizedBox(
                                        width: isMobile ? double.infinity : 260,
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedProductId,
                                          decoration: _inputDecoration('Producto', primary),
                                          items: widget.products.map((p) {
                                            return DropdownMenuItem(
                                              value: p['id'] as String,
                                              child: Text('${p['name']} · \$${(p['price'] as num?)?.toStringAsFixed(2) ?? '0'}', overflow: TextOverflow.ellipsis),
                                            );
                                          }).toList(),
                                          onChanged: (v) => setState(() => _selectedProductId = v),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isMobile ? double.infinity : 200,
                                        child: DropdownButtonFormField<String>(
                                          value: _selectedLocationId,
                                          decoration: _inputDecoration('Sucursal', primary),
                                          items: widget.locations.map((l) {
                                            return DropdownMenuItem(value: l['id'] as String, child: Text(l['name'] as String? ?? ''));
                                          }).toList(),
                                          onChanged: (v) => setState(() => _selectedLocationId = v),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isMobile ? double.infinity : 120,
                                        child: TextFormField(
                                          controller: _qtyCtrl,
                                          decoration: _inputDecoration('Cantidad', primary, icon: Icons.tag),
                                          keyboardType: TextInputType.number,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 12,
                                    runSpacing: 12,
                                    children: [
                                      SizedBox(
                                        width: isMobile ? double.infinity : 240,
                                        child: TextFormField(
                                          controller: _nameCtrl,
                                          decoration: _inputDecoration('Tu nombre *', primary, icon: Icons.person_outline),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isMobile ? double.infinity : 220,
                                        child: TextFormField(
                                          controller: _phoneCtrl,
                                          decoration: _inputDecoration('Teléfono *', primary, icon: Icons.call_outlined),
                                          keyboardType: TextInputType.phone,
                                        ),
                                      ),
                                      SizedBox(
                                        width: isMobile ? double.infinity : 240,
                                        child: TextFormField(
                                          controller: _emailCtrl,
                                          decoration: _inputDecoration('Email (opcional)', primary, icon: Icons.alternate_email),
                                        ),
                                      ),
                                      SizedBox(
                                        width: isMobile ? double.infinity : 260,
                                        child: TextFormField(
                                          controller: _refCtrl,
                                          decoration: _inputDecoration('Nº comprobante CBU (opcional)', primary, icon: Icons.receipt_long_outlined),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 18),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 50,
                                    child: ElevatedButton.icon(
                                      onPressed: _loading ? null : _submitReservation,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: primary,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      icon: _loading
                                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                          : const Icon(Icons.check_circle),
                                      label: Text(_loading ? 'Procesando...' : 'Confirmar Reserva', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  if (whatsapp.isNotEmpty)
                                    TextButton.icon(
                                      onPressed: () {
                                        final msg = Uri.encodeComponent('Hola! Quiero reservar un producto.');
                                        launchUrl(Uri.parse('https://wa.me/$whatsapp?text=$msg'));
                                      },
                                      icon: const Icon(Icons.chat),
                                      label: const Text('Prefiero coordinar por WhatsApp'),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(String whatsapp, Color primary) {
    return Column(
      children: [
        Icon(Icons.check_circle, color: primary, size: 64),
        const SizedBox(height: 16),
        const Text('¡Reserva enviada con éxito!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1A1A1A))),
        const SizedBox(height: 8),
        const Text('Te confirmaremos por WhatsApp.', style: TextStyle(color: Color(0xFF888888))),
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

  Widget _buildHighlight(Color color, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSteps(Color primary) {
    final steps = [
      ('Elegí el producto y sucursal', Icons.shopping_cart_checkout),
      ('Pagá por CBU/alias', Icons.credit_score_outlined),
      ('Confirmamos por WhatsApp', Icons.chat_bubble_outline),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('3 pasos simples', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF4B5563))),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(steps.length, (i) {
            final step = steps[i];
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primary.withValues(alpha: 0.16)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: primary.withValues(alpha: 0.12),
                    child: Text('${i + 1}', style: TextStyle(color: primary, fontWeight: FontWeight.w800, fontSize: 12)),
                  ),
                  const SizedBox(width: 10),
                  Icon(step.$2, size: 18, color: primary),
                  const SizedBox(width: 8),
                  Text(step.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, Color primary, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: primary) : null,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.16)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary.withValues(alpha: 0.16)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: primary, width: 1.4),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
      setState(() {
        _success = true;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}')),
      );
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
