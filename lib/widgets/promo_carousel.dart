import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class PromoCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> promos;
  final List<Map<String, dynamic>> products;

  const PromoCarousel({super.key, required this.promos, required this.products});

  @override
  Widget build(BuildContext context) {
    if (promos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('Sin promociones por ahora', style: TextStyle(color: Color(0xFF8A9BAE)))),
      );
    }

    return SizedBox(
      height: 300,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: promos.length,
        itemBuilder: (context, i) {
          final promo = promos[i];
          final product = promo['products'] as Map<String, dynamic>?;
          final title = promo['title'] as String? ?? product?['name'] ?? '';
          final promoText = promo['promo_text'] as String? ?? '';
          final discountPct = promo['discount_pct'] as num?;
          final promoPrice = promo['promo_price'] as num?;
          final originalPrice = product?['price'] as num?;
          final imgPath = product?['image_path'] as String? ?? '';

          return Container(
            width: 220,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2230),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFF8F00).withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: imgPath.isNotEmpty
                          ? Image.network(
                              SupabaseService.instance.getPublicImageUrl(imgPath),
                              height: 160, width: 220, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(height: 160, width: 220, color: const Color(0xFF2A3545),
                                child: const Icon(Icons.local_offer, color: Color(0xFFFF8F00), size: 40)),
                            )
                          : Container(height: 160, width: 220, color: const Color(0xFF2A3545),
                              child: const Icon(Icons.local_offer, color: Color(0xFFFF8F00), size: 40)),
                    ),
                    if (discountPct != null && discountPct > 0)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: const Color(0xFFFF8F00), borderRadius: BorderRadius.circular(10)),
                          child: Text('-${discountPct.toStringAsFixed(0)}%',
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.black)),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                      if (promoText.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(promoText, style: const TextStyle(fontSize: 11, color: Color(0xFFFF8F00)), maxLines: 2, overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (originalPrice != null && promoPrice != null) ...[
                            Text('\$ ${originalPrice.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 12, color: Color(0xFF8A9BAE), decoration: TextDecoration.lineThrough)),
                            const SizedBox(width: 8),
                          ],
                          Text('\$ ${(promoPrice ?? originalPrice ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF66BB6A))),
                        ],
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
