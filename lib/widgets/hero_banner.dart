import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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
  final _pageCtrl = PageController(viewportFraction: 0.92);
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
              Text('Cúrcuma', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Colors.white)),
              Text('Dietética natural para tu bienestar', style: TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 420,
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
              final ctaLabel = banner['cta_label'] as String? ?? '';
              final ctaUrl = banner['cta_url'] as String? ?? '';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imgPath.isNotEmpty)
                        Image.network(
                          SupabaseService.instance.getPublicImageUrl(imgPath),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.black.withValues(alpha: 0.25),
                              Colors.black.withValues(alpha: 0.6),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 22,
                        top: 22,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_florist, size: 16, color: Colors.white.withValues(alpha: 0.9)),
                              const SizedBox(width: 6),
                              const Text('Sabor + bienestar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 28,
                        left: 22,
                        right: 22,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (title.isNotEmpty)
                                    Text(
                                      title,
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                        height: 1.1,
                                      ),
                                    ),
                                  if (subtitle.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      subtitle,
                                      style: const TextStyle(fontSize: 15, color: Colors.white70, height: 1.4),
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          _buildPill(primary, 'Natural'),
                                          _buildPill(accent, 'Hecho en Argentina'),
                                          _buildPill(Colors.white.withValues(alpha: 0.12), 'Envíos y reservas', textColor: Colors.white),
                                        ],
                                      ),
                                      if (ctaLabel.isNotEmpty && ctaUrl.isNotEmpty)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: primary,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                          ),
                                          onPressed: () => launchUrl(Uri.parse(ctaUrl)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(ctaLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                                              const SizedBox(width: 6),
                                              const Icon(Icons.north_east, size: 16),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_allBanners.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _allBanners.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _currentPage == i ? 26 : 10,
                    height: 10,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: _currentPage == i ? primary : Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black.withValues(alpha: 0.08)),
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

  Widget _buildPill(Color color, String label, {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: color.opacity < 0.2 ? 0.24 : 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? (color.computeLuminance() > 0.5 ? Colors.black87 : Colors.white),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
