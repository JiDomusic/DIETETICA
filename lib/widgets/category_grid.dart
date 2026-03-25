import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../services/supabase_service.dart';
import '../screens/public/category_products_screen.dart';
import 'animated_section.dart';

/// Categorías en scroll horizontal (tipo Netflix/ecommerce moderno)
class CategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;

  const CategoryGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) return const SizedBox.shrink();

    final isMobile = MediaQuery.of(context).size.width < 768;

    return SizedBox(
      height: isMobile ? 180 : 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: categories.length,
        itemBuilder: (context, i) {
          final cat = categories[i];
          final name = cat['name'] as String? ?? '';
          final imgPath = cat['image_path'] as String? ?? '';
          final catId = cat['id'] as String? ?? '';

          return AnimatedSection(
            delayMs: i * 80,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: HoverScaleCard(
                scale: 1.04,
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (_, __, ___) => CategoryProductsScreen(
                        categoryId: catId,
                        categoryName: name,
                      ),
                      transitionsBuilder: (_, animation, __, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.05),
                              end: Offset.zero,
                            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
                            child: child,
                          ),
                        );
                      },
                      transitionDuration: const Duration(milliseconds: 400),
                    ),
                  );
                },
                child: Container(
                  width: isMobile ? 150 : 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFFF5F5F5),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imgPath.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            SupabaseService.instance.getPublicImageUrl(imgPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      // Gradient overlay
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: const [0.3, 1.0],
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.65),
                            ],
                          ),
                        ),
                      ),
                      // Texto
                      Positioned(
                        bottom: 14,
                        left: 14,
                        right: 14,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Ver productos',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 3),
                                Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white.withValues(alpha: 0.8)),
                              ],
                            ),
                          ],
                        ),
                      ),
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
}
