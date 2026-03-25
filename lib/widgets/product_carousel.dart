import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../services/supabase_service.dart';
import 'animated_section.dart';

class ProductCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> products;

  const ProductCarousel({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final primary = ThemeConfig.instance.primary;

    if (products.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text('Próximamente...', style: TextStyle(color: Color(0xFF999999)))),
      );
    }

    return SizedBox(
      height: 320,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: products.length,
        itemBuilder: (context, i) {
          final p = products[i];
          final imgPath = p['image_path'] as String? ?? '';
          final name = p['name'] as String? ?? '';
          final price = p['price'] as num? ?? 0;
          final isNew = p['is_new'] == true;

          return AnimatedSection(
            delayMs: i * 80,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: HoverScaleCard(
                borderRadius: BorderRadius.circular(4),
                child: SizedBox(
                  width: 210,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen limpia, sin bordes
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Container(
                          color: const Color(0xFFF5F5F5),
                          child: imgPath.isNotEmpty
                              ? Image.network(
                                  SupabaseService.instance.getPublicImageUrl(imgPath),
                                  height: 220, width: 210, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _placeholder(primary),
                                )
                              : _placeholder(primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Nombre - tipografía limpia
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Precio - simple, sin container
                      Text(
                        '\$ ${_formatPrice(price)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF333333),
                        ),
                      ),
                      if (isNew) ...[
                        const SizedBox(height: 6),
                        const Text(
                          'Nuevo',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF999999),
                          ),
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

  Widget _placeholder(Color primary) {
    return Container(
      height: 220, width: 210,
      color: const Color(0xFFF5F5F5),
      child: Center(child: Icon(Icons.eco, color: Colors.grey[300], size: 36)),
    );
  }
}
