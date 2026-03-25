import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../services/supabase_service.dart';
import 'animated_section.dart';

class NetflixSection extends StatelessWidget {
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> categories;

  const NetflixSection({super.key, required this.products, required this.categories});

  @override
  Widget build(BuildContext context) {
    final primary = ThemeConfig.instance.primary;

    if (products.isEmpty) return const SizedBox.shrink();

    final grouped = <String, List<Map<String, dynamic>>>{};
    for (final p in products) {
      final catName = (p['categories'] as Map?)?['name'] as String? ?? 'Sin categoría';
      grouped.putIfAbsent(catName, () => []).add(p);
    }

    int sectionIndex = 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {
        final delay = sectionIndex * 120;
        sectionIndex++;
        return AnimatedSection(
          delayMs: delay,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 4,
                        height: 20,
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(entry.key, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: primary)),
                    ],
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: entry.value.length,
                    itemBuilder: (context, i) {
                      final p = entry.value[i];
                      final imgPath = p['image_path'] as String? ?? '';
                      final name = p['name'] as String? ?? '';
                      final price = p['price'] as num? ?? 0;

                      return Padding(
                        padding: const EdgeInsets.only(right: 14),
                        child: HoverScaleCard(
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 155,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              border: Border.all(color: const Color(0xFFF0F0F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: imgPath.isNotEmpty
                                      ? Image.network(
                                          SupabaseService.instance.getPublicImageUrl(imgPath),
                                          height: 150, width: 155, fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Container(
                                            height: 150, width: 155,
                                            color: primary.withValues(alpha: 0.08),
                                            child: Icon(Icons.eco, color: primary.withValues(alpha: 0.3)),
                                          ),
                                        )
                                      : Container(
                                          height: 150, width: 155,
                                          color: primary.withValues(alpha: 0.08),
                                          child: Icon(Icons.eco, color: primary.withValues(alpha: 0.3)),
                                        ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)),
                                        maxLines: 2, overflow: TextOverflow.ellipsis),
                                      const SizedBox(height: 4),
                                      Text('\$ ${price.toStringAsFixed(0)}',
                                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: primary)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
