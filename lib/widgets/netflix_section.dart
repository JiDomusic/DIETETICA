import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class NetflixSection extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> categories;

  const NetflixSection({super.key, required this.products, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();

    // Agrupar por categoría
    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final p in products) {
      final catName = (p['categories'] as Map?)?['name'] as String? ?? 'Sin categoría';
      grouped.putIfAbsent(catName, () => []).add(p);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(entry.key, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
              ),
              SizedBox(
                height: 200,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: entry.value.length,
                  itemBuilder: (context, i) {
                    final p = entry.value[i];
                    final imgPath = p['image_path'] as String? ?? '';
                    final name = p['name'] as String? ?? '';

                    return Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFF1A2230),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: imgPath.isNotEmpty
                                ? Image.network(
                                    SupabaseService.instance.getPublicImageUrl(imgPath),
                                    height: 150, width: 140, fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      height: 150, width: 140, color: const Color(0xFF2A3545),
                                      child: const Icon(Icons.eco, color: Color(0xFF66BB6A)),
                                    ),
                                  )
                                : Container(
                                    height: 150, width: 140, color: const Color(0xFF2A3545),
                                    child: const Icon(Icons.eco, color: Color(0xFF66BB6A)),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                              maxLines: 2, overflow: TextOverflow.ellipsis),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
