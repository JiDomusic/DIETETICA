import 'dart:async';
import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../services/supabase_service.dart';

class HeroBanner extends StatefulWidget {
  final List<Map<String, dynamic>> banners;
  final List<Map<String, dynamic>> homeBanners;

  const HeroBanner({super.key, required this.banners, required this.homeBanners});

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  Timer? _timer;

  List<Map<String, dynamic>> get _allBanners => [...widget.banners, ...widget.homeBanners];

  @override
  void initState() {
    super.initState();
    if (_allBanners.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 5), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % _allBanners.length;
        _pageCtrl.animateToPage(next, duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = ThemeConfig.instance.primary;
    final accent = ThemeConfig.instance.accent;

    if (_allBanners.isEmpty) {
      return Container(
        height: 300,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [primary, accent]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.eco, size: 60, color: Colors.white),
              SizedBox(height: 12),
              Text('Dietética Centro', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Alimentos saludables para tu bienestar', style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageCtrl,
            itemCount: _allBanners.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (context, i) {
              final banner = _allBanners[i];
              final imgPath = banner['image_path'] as String? ?? '';
              final title = banner['title'] as String? ?? '';
              final subtitle = banner['subtitle'] as String? ?? '';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: const Color(0xFFF0F0F0),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (imgPath.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          SupabaseService.instance.getPublicImageUrl(imgPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 32,
                      left: 24,
                      right: 24,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (title.isNotEmpty)
                            Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Colors.white)),
                          if (subtitle.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.white70)),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          if (_allBanners.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _allBanners.length,
                  (i) => Container(
                    width: _currentPage == i ? 24 : 8,
                    height: 8,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: _currentPage == i ? primary : Colors.white54,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }
}
