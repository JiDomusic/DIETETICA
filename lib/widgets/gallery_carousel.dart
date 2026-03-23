import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class GalleryCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const GalleryCarousel({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, i) {
          final item = items[i];
          final imgPath = item['image_path'] as String? ?? '';
          final title = item['title'] as String? ?? '';
          final desc = item['description'] as String? ?? '';

          return Container(
            width: 300,
            margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFFF5F5F5),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: imgPath.isNotEmpty
                      ? Image.network(
                          SupabaseService.instance.getPublicImageUrl(imgPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF0F0F0),
                            child: Icon(Icons.photo, size: 40, color: Colors.grey[400]),
                          ),
                        )
                      : Container(color: const Color(0xFFF0F0F0), child: Icon(Icons.photo, size: 40, color: Colors.grey[400])),
                ),
                if (title.isNotEmpty || desc.isNotEmpty)
                  Positioned(
                    bottom: 0, left: 0, right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title.isNotEmpty) Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white)),
                          if (desc.isNotEmpty) Text(desc, style: const TextStyle(fontSize: 12, color: Colors.white70), maxLines: 2),
                        ],
                      ),
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
