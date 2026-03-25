import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import 'animated_section.dart';

class GalleryCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const GalleryCarousel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          final imgPath = item['image_path'] as String? ?? '';
          final title = item['title'] as String? ?? '';
          final desc = item['description'] as String? ?? '';

          return AnimatedSection(
            delayMs: i * 100,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: HoverScaleCard(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 320,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: const Color(0xFFF5F5F5),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: imgPath.isNotEmpty
                            ? Image.network(
                                SupabaseService.instance.getPublicImageUrl(imgPath),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: const Color(0xFFF0F0F0),
                                  child: Icon(Icons.photo, size: 40, color: Colors.grey[300]),
                                ),
                              )
                            : Container(color: const Color(0xFFF0F0F0), child: Icon(Icons.photo, size: 40, color: Colors.grey[300])),
                      ),
                      if (title.isNotEmpty || desc.isNotEmpty)
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (title.isNotEmpty) Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white)),
                                if (desc.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(desc, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.8)), maxLines: 2),
                                ],
                              ],
                            ),
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
