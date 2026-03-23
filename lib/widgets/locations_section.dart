import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/supabase_service.dart';

class LocationsSection extends StatelessWidget {
  final List<Map<String, dynamic>> locations;

  const LocationsSection({super.key, required this.locations});

  @override
  Widget build(BuildContext context) {
    if (locations.isEmpty) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width < 768;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: isMobile
          ? Column(children: locations.map((l) => _buildLocationCard(context, l)).toList())
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: locations.map((l) => Expanded(child: _buildLocationCard(context, l))).toList(),
            ),
    );
  }

  Widget _buildLocationCard(BuildContext context, Map<String, dynamic> loc) {
    final name = loc['name'] as String? ?? '';
    final address = loc['address'] as String? ?? '';
    final phone = loc['phone'] as String? ?? '';
    final whatsapp = loc['whatsapp'] as String? ?? '';
    final mapUrl = loc['map_url'] as String? ?? '';
    final horario = loc['horario'] as String? ?? '';
    final imgPath = loc['image_path'] as String? ?? '';

    final encodedAddress = Uri.encodeComponent(address);

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2230),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A3545)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen de la sucursal o placeholder con link a Maps
          if (imgPath.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                SupabaseService.instance.getPublicImageUrl(imgPath),
                height: 180, width: double.infinity, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 180, color: const Color(0xFF2A3545),
                  child: const Icon(Icons.store, size: 48, color: Color(0xFF66BB6A)),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                if (address.isNotEmpty)
                  _infoRow(Icons.location_on, address, onTap: () {
                    final url = mapUrl.isNotEmpty ? mapUrl : 'https://www.google.com/maps/search/$encodedAddress';
                    launchUrl(Uri.parse(url));
                  }),
                if (phone.isNotEmpty)
                  _infoRow(Icons.phone, phone, onTap: () => launchUrl(Uri.parse('tel:$phone'))),
                if (horario.isNotEmpty)
                  _infoRow(Icons.schedule, horario),
                if (whatsapp.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse('https://wa.me/$whatsapp')),
                      icon: const Icon(Icons.chat, size: 18),
                      label: const Text('WhatsApp'),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF25D366)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text, {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF66BB6A)),
            const SizedBox(width: 8),
            Expanded(child: Text(text, style: TextStyle(
              fontSize: 13,
              color: onTap != null ? const Color(0xFF66BB6A) : const Color(0xFF8A9BAE),
              decoration: onTap != null ? TextDecoration.underline : null,
            ))),
          ],
        ),
      ),
    );
  }
}
