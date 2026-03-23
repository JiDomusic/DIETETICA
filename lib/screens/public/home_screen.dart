import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme_config.dart';
import '../../services/supabase_service.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/product_carousel.dart';
import '../../widgets/netflix_section.dart';
import '../../widgets/category_grid.dart';
import '../../widgets/locations_section.dart';
import '../../widgets/gallery_carousel.dart';
import '../../widgets/video_grid.dart';
import '../../widgets/reservation_section.dart';
import '../../widgets/promo_carousel.dart';
import '../../widgets/whatsapp_fab.dart';
import '../admin/admin_login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _svc = SupabaseService.instance;
  final _scrollController = ScrollController();

  Map<String, String> _config = {};
  List<Map<String, dynamic>> _sections = [];
  List<Map<String, dynamic>> _navItems = [];
  List<Map<String, dynamic>> _homeBanners = [];
  bool _loading = true;
  String _searchQuery = '';

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _promos = [];
  List<Map<String, dynamic>> _locations = [];
  List<Map<String, dynamic>> _gallery = [];
  List<Map<String, dynamic>> _videos = [];
  List<Map<String, dynamic>> _banners = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _svc.getSiteConfig(),
        _svc.getSections(),
        _svc.getNavbarItems(),
        _svc.getHomeBanners(),
        _svc.getProducts(),
        _svc.getCategories(),
        _svc.getPromos(),
        _svc.getLocations(),
        _svc.getGallery(),
        _svc.getVideos(),
        _svc.getBanners(),
      ]);

      if (!mounted) return;
      setState(() {
        _config = results[0] as Map<String, String>;
        _sections = results[1] as List<Map<String, dynamic>>;
        _navItems = results[2] as List<Map<String, dynamic>>;
        _homeBanners = results[3] as List<Map<String, dynamic>>;
        _products = results[4] as List<Map<String, dynamic>>;
        _categories = results[5] as List<Map<String, dynamic>>;
        _promos = results[6] as List<Map<String, dynamic>>;
        _locations = results[7] as List<Map<String, dynamic>>;
        _gallery = results[8] as List<Map<String, dynamic>>;
        _videos = results[9] as List<Map<String, dynamic>>;
        _banners = results[10] as List<Map<String, dynamic>>;
        _loading = false;
      });

      // Actualizar colores dinámicos
      ThemeConfig.instance.loadFromConfig(_config);
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 768;

  Color get _primary => ThemeConfig.instance.primary;
  Color get _accent => ThemeConfig.instance.accent;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator(color: _primary)),
      );
    }

    final siteName = _config['site_name'] ?? 'Dietética Centro';
    final whatsapp = _config['whatsapp_default'] ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ========== APP BAR / NAVBAR ==========
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: _isMobile ? 56 : 64,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 1,
            shadowColor: Colors.black12,
            title: Row(
              children: [
                Icon(Icons.eco, color: _primary, size: 28),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(siteName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: _primary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Spacer(),
                if (!_isMobile) ..._buildNavLinks(),
                SizedBox(
                  width: _isMobile ? 120 : 200,
                  height: 36,
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Buscar...',
                      prefixIcon: const Icon(Icons.search, size: 18),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.admin_panel_settings, size: 20, color: Colors.grey[600]),
                  tooltip: 'Admin',
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                  ),
                ),
              ],
            ),
          ),

          // ========== BÚSQUEDA ==========
          if (_searchQuery.isNotEmpty)
            _buildSearchResults()
          else ...[
            for (final section in _sections)
              _buildSection(section),
          ],

          // Footer
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),
      floatingActionButton: whatsapp.isNotEmpty
          ? WhatsAppFAB(phoneNumber: whatsapp)
          : null,
    );
  }

  List<Widget> _buildNavLinks() {
    return _navItems.map((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: TextButton(
          onPressed: () {
            final slug = item['section_slug'] as String?;
            if (slug != null) {
              final idx = _sections.indexWhere((s) => s['slug'] == slug);
              if (idx >= 0) {
                _scrollController.animateTo(
                  idx * 400.0,
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                );
              }
            }
          },
          child: Text(
            item['label'] as String? ?? '',
            style: TextStyle(color: _primary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildSearchResults() {
    final filtered = _products.where((p) {
      final name = (p['name'] as String? ?? '').toLowerCase();
      final desc = (p['description'] as String? ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();

    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Text(
            'Resultados para "${_searchQuery}" (${filtered.length})',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 16),
          if (filtered.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Text('No se encontraron productos', style: TextStyle(color: Color(0xFF888888))),
              ),
            )
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: filtered.map((p) => _buildProductCard(p)).toList(),
            ),
        ]),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    final imgPath = product['image_path'] as String? ?? '';
    final name = product['name'] as String? ?? '';
    final price = product['price'];
    final desc = product['description'] as String? ?? '';
    final isPromo = product['is_promo'] == true;

    return Container(
      width: _isMobile ? MediaQuery.of(context).size.width - 40 : 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isPromo ? _primary : const Color(0xFFE8E8E8)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: imgPath.isNotEmpty
                ? Image.network(
                    _svc.getPublicImageUrl(imgPath),
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 160,
                      color: const Color(0xFFF0F0F0),
                      child: Icon(Icons.image, size: 40, color: Colors.grey[400]),
                    ),
                  )
                : Container(
                    height: 160,
                    color: _primary.withValues(alpha: 0.08),
                    child: Center(child: Icon(Icons.eco, size: 40, color: _primary)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPromo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 6),
                    decoration: BoxDecoration(
                      color: _primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('PROMO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
                  ),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A)), maxLines: 2, overflow: TextOverflow.ellipsis),
                if (desc.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF888888)), maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
                const SizedBox(height: 8),
                Text(
                  '\$ ${(price as num?)?.toStringAsFixed(2) ?? '0.00'}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section) {
    final slug = section['slug'] as String? ?? '';
    final title = section['title'] as String? ?? '';
    final subtitle = section['subtitle'] as String? ?? '';
    final layout = section['layout'] as String? ?? 'carousel';
    final showTitle = section['show_title'] as bool? ?? true;

    Widget content;
    switch (layout) {
      case 'banner':
        content = HeroBanner(banners: _banners.where((b) => b['section_id'] == section['id']).toList(), homeBanners: _homeBanners);
      case 'carousel' when slug == 'promos':
        content = PromoCarousel(promos: _promos, products: _products);
      case 'carousel' when slug == 'nuevos':
        content = ProductCarousel(products: _products.where((p) => p['is_new'] == true).toList());
      case 'carousel' when slug == 'galeria':
        content = GalleryCarousel(items: _gallery);
      case 'carousel':
        content = ProductCarousel(products: _products.where((p) => p['is_featured'] == true).toList());
      case 'netflix':
        content = NetflixSection(products: _products.where((p) => p['is_featured'] == true).toList(), categories: _categories);
      case 'grid' when slug == 'categorias':
        content = CategoryGrid(categories: _categories);
      case 'grid' when slug == 'videos':
        content = VideoGrid(videos: _videos);
      case 'grid':
        content = CategoryGrid(categories: _categories);
      case 'locations':
        content = LocationsSection(locations: _locations);
      case 'custom' when slug == 'reservas':
        content = ReservationSection(products: _products, locations: _locations, config: _config);
      default:
        content = const SizedBox.shrink();
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle && title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: _primary)),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF888888))),
                    ],
                  ],
                ),
              ),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final footerText = _config['footer_text'] ?? '© 2026 Dietética Centro';
    final instagram = _config['instagram_url'] ?? '';
    final facebook = _config['facebook_url'] ?? '';
    final email = _config['email_contacto'] ?? '';
    final horario = _config['horario_atencion'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      color: _primary.withValues(alpha: 0.05),
      child: Column(
        children: [
          Divider(color: _primary.withValues(alpha: 0.2)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            alignment: WrapAlignment.center,
            children: [
              if (horario.isNotEmpty)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.schedule, size: 16, color: _primary),
                  const SizedBox(width: 6),
                  Text(horario, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
                ]),
              if (email.isNotEmpty)
                Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.email, size: 16, color: _primary),
                  const SizedBox(width: 6),
                  Text(email, style: const TextStyle(fontSize: 13, color: Color(0xFF555555))),
                ]),
              if (instagram.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.camera_alt, color: _primary, size: 20),
                  onPressed: () => launchUrl(Uri.parse(instagram)),
                  tooltip: 'Instagram',
                ),
              if (facebook.isNotEmpty)
                IconButton(
                  icon: Icon(Icons.facebook, color: _primary, size: 20),
                  onPressed: () => launchUrl(Uri.parse(facebook)),
                  tooltip: 'Facebook',
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(footerText, style: const TextStyle(fontSize: 12, color: Color(0xFF888888))),
          const SizedBox(height: 8),
          const Text(
            'Desarrollado por Programación JJ',
            style: TextStyle(fontSize: 11, color: Color(0xFFAAAAAA)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
