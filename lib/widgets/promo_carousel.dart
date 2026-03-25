import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../services/supabase_service.dart';
import 'animated_section.dart';

class PromoCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> promos;
  final List<Map<String, dynamic>> products;

  const PromoCarousel({super.key, required this.promos, required this.products});

  @override
  Widget build(BuildContext context) {
    final secondary = ThemeConfig.instance.secondary;

    if (promos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('Sin promociones por ahora', style: TextStyle(color: Color(0xFF999999)))),
      );
    }

    return SizedBox(
      height: 360,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
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

          return AnimatedSection(
            delayMs: i * 100,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: HoverScaleCard(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 230,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen con badge minimalista
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              color: const Color(0xFFF5F5F5),
                              child: imgPath.isNotEmpty
                                  ? Image.network(
                                      SupabaseService.instance.getPublicImageUrl(imgPath),
                                      height: 240, width: 230, fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 240, width: 230,
                                        color: const Color(0xFFF5F5F5),
                                        child: Icon(Icons.local_offer, color: Colors.grey[300], size: 36),
                                      ),
                                    )
                                  : Container(
                                      height: 240, width: 230,
                                      color: const Color(0xFFF5F5F5),
                                      child: Icon(Icons.local_offer, color: Colors.grey[300], size: 36),
                                    ),
                            ),
                          ),
                          if (discountPct != null && discountPct > 0)
                            Positioned(
                              top: 10, left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                color: secondary,
                                child: Text(
                                  '-${discountPct.toStringAsFixed(0)}%',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Nombre
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A)),
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Precios
                      Row(
                        children: [
                          Text(
                            '\$ ${_formatPrice(promoPrice ?? originalPrice ?? 0)}',
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF333333)),
                          ),
                          if (originalPrice != null && promoPrice != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '\$ ${_formatPrice(originalPrice)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFBBBBBB),
                                decoration: TextDecoration.lineThrough,
                                decorationColor: Color(0xFFBBBBBB),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (promoText.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          promoText,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                          maxLines: 2, overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatPrice(num price) {
    if (price >= 1000) {
      final formatted = price.toStringAsFixed(0);
      final buffer = StringBuffer();
      for (int i = 0; i < formatted.length; i++) {
        if (i > 0 && (formatted.length - i) % 3 == 0) buffer.write('.');
        buffer.write(formatted[i]);
      }
      return buffer.toString();
    }
    return price.toStringAsFixed(0);
  }
}
