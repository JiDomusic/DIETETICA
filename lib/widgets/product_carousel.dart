import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class ProductCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ProductCarousel({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('Próximamente...', style: TextStyle(color: Color(0xFF8A9BAE)))),
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
              color: const Color(0xFF1A2230),
              borderRadius: BorderRadius.circular(16),
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
                              height: 160,
                              width: 180,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                height: 160, width: 180, color: const Color(0xFF2A3545),
                                child: const Icon(Icons.eco, color: Color(0xFF66BB6A), size: 36),
                              ),
                            )
                          : Container(
                              height: 160, width: 180, color: const Color(0xFF2A3545),
                              child: const Icon(Icons.eco, color: Color(0xFF66BB6A), size: 36),
                            ),
                    ),
                    if (isNew)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2E7D32),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('NUEVO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700)),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 6),
                      Text('\$ ${price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF66BB6A)),
                      ),
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
