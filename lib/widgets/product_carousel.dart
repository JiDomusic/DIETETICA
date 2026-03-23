import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../services/supabase_service.dart';

class ProductCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ProductCarousel({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final primary = ThemeConfig.instance.primary;

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('Próximamente...', style: TextStyle(color: Color(0xFF888888)))),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          final imgPath = p['image_path'] as String? ?? '';
          final name = p['name'] as String? ?? '';
          final price = p['price'] as num? ?? 0;
          final isNew = p['is_new'] == true;

          return Container(
            width: 180,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE8E8E8)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: imgPath.isNotEmpty
                          ? Image.network(
                              SupabaseService.instance.getPublicImageUrl(imgPath),
                              height: 160, width: 180, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 160, width: 180, color: primary.withValues(alpha: 0.08),
                                child: Icon(Icons.eco, color: primary, size: 36),
                              ),
                            )
                          : Container(
                              height: 160, width: 180, color: primary.withValues(alpha: 0.08),
                              child: Icon(Icons.eco, color: primary, size: 36),
                            ),
                    ),
                    if (isNew)
                      Positioned(
                        top: 8, left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(8)),
                          child: const Text('NUEVO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1A1A1A)), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text('\$ ${price.toStringAsFixed(2)}', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: primary)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
