import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme_config.dart';
import '../../services/supabase_service.dart';
import '../../widgets/animated_section.dart';
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

      ThemeConfig.instance.loadFromConfig(_config);
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  bool get _isTablet => MediaQuery.of(context).size.width >= 768 && MediaQuery.of(context).size.width < 1200;

  Color get _primary => ThemeConfig.instance.primary;
  Color get _accent => ThemeConfig.instance.accent;
  Color get _secondary => ThemeConfig.instance.secondary;

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: CircularProgressIndicator(
                  color: _primary,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              Text('Cargando...', style: TextStyle(color: _primary.withValues(alpha: 0.6), fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    final siteName = _config['site_name'] ?? 'Cúrcuma';
    final whatsapp = _config['whatsapp_default'] ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ========== NAVBAR MODERNA ==========
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: _isMobile ? 62 : 74,
            backgroundColor: Colors.white.withValues(alpha: 0.96),
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            titleSpacing: 0,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_primary.withValues(alpha: 0.0), _primary.withValues(alpha: 0.15), _primary.withValues(alpha: 0.0)],
                  ),
                ),
              ),
            ),
            title: Padding(
              padding: EdgeInsets.symmetric(horizontal: _isMobile ? 12 : 24),
              child: Row(
                children: [
                  // Logo + nombre
                  _buildLogo(_config['logo_path'] ?? ''),
                  const SizedBox(width: 10),
                  if (!_isMobile)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(siteName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: _primary)),
                        Text('Alimentos naturales', style: TextStyle(fontSize: 11, color: _primary.withValues(alpha: 0.5), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  if (_isMobile)
                    Flexible(
                      child: Text(siteName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: _primary), overflow: TextOverflow.ellipsis),
                    ),
                  const Spacer(),
                  // Nav links desktop
                  if (!_isMobile && !_isTablet) ..._buildNavLinks(),
                  // Search
                  SizedBox(
                    width: _isMobile ? 110 : 220,
                    height: 38,
                    child: TextField(
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: _isMobile ? 'Buscar...' : 'Buscar productos...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                        prefixIcon: Icon(Icons.search, size: 18, color: _primary.withValues(alpha: 0.5)),
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                      ),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 6),
                  IconButton(
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: _primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.admin_panel_settings, size: 18, color: _primary),
                    ),
                    tooltip: 'Admin',
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminLoginScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ========== CONTENIDO ==========
          if (_searchQuery.isNotEmpty)
            _buildSearchResults()
          else ...[
            for (int i = 0; i < _sections.length; i++)
              _buildSection(_sections[i], i),
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
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: _primary,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
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
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildLogo(String path) {
    if (path.isEmpty) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primary, _accent],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.eco, color: Colors.white, size: 22),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        _svc.getPublicImageUrl(path),
        height: 38, width: 38, fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 38, height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [_primary, _accent]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.eco, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final filtered = _products.where((p) {
      final name = (p['name'] as String? ?? '').toLowerCase();
      final desc = (p['description'] as String? ?? '').toLowerCase();
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || desc.contains(q);
    }).toList();

    return SliverPadding(
      padding: const EdgeInsets.all(24),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Row(
            children: [
              Icon(Icons.search, color: _primary, size: 22),
              const SizedBox(width: 10),
              Text(
                '${filtered.length} resultados para "$_searchQuery"',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (filtered.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(60),
                child: Column(
                  children: [
                    Icon(Icons.search_off, size: 56, color: Colors.grey[300]),
                    const SizedBox(height: 12),
                    const Text('No encontramos eso', style: TextStyle(color: Color(0xFF888888), fontSize: 16)),
                    const SizedBox(height: 4),
                    const Text('Probá con otro término', style: TextStyle(color: Color(0xFFBBBBBB), fontSize: 13)),
                  ],
                ),
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
    final isNew = product['is_new'] == true;

    return HoverScaleCard(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: _isMobile ? MediaQuery.of(context).size.width - 48 : 230,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen limpia
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                color: const Color(0xFFF5F5F5),
                child: imgPath.isNotEmpty
                    ? Image.network(
                        _svc.getPublicImageUrl(imgPath),
                        height: 200, width: double.infinity, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 200,
                          color: const Color(0xFFF5F5F5),
                          child: Icon(Icons.eco, size: 36, color: Colors.grey[300]),
                        ),
                      )
                    : Container(
                        height: 200,
                        color: const Color(0xFFF5F5F5),
                        child: Center(child: Icon(Icons.eco, size: 36, color: Colors.grey[300])),
                      ),
              ),
            ),
            const SizedBox(height: 10),
            // Info minimalista
            Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF1A1A1A)),
              maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(
              '\$ ${(price as num?)?.toStringAsFixed(0) ?? '0'}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: Color(0xFF333333)),
            ),
            if (desc.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 12, color: Color(0xFF999999)), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection(Map<String, dynamic> section, int index) {
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

    // Fondo alternado para secciones
    final isHero = layout == 'banner';
    final isEven = index % 2 == 0;
    final bgColor = isHero
        ? Colors.transparent
        : isEven
            ? Colors.transparent
            : _primary.withValues(alpha: 0.02);

    // Icon para cada tipo de sección
    IconData? sectionIcon;
    switch (slug) {
      case 'promos': sectionIcon = Icons.local_fire_department;
      case 'nuevos': sectionIcon = Icons.fiber_new;
      case 'categorias': sectionIcon = Icons.grid_view_rounded;
      case 'destacados': sectionIcon = Icons.star_rounded;
      case 'sucursales': sectionIcon = Icons.store;
      case 'galeria': sectionIcon = Icons.photo_library;
      case 'videos': sectionIcon = Icons.play_circle_filled;
      case 'reservas': sectionIcon = Icons.shopping_bag;
    }

    return SliverToBoxAdapter(
      child: Container(
        color: bgColor,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: isHero ? 12 : 28,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showTitle && title.isNotEmpty && !isHero)
                AnimatedSection(
                  delayMs: 100,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Row(
                      children: [
                        if (sectionIcon != null) ...[
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(sectionIcon, size: 20, color: _primary),
                          ),
                          const SizedBox(width: 12),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1A1A2E),
                                letterSpacing: -0.3,
                                height: 1.1,
                                shadows: [Shadow(blurRadius: 0, color: _primary.withValues(alpha: 0.0))],
                              )),
                              if (subtitle.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(subtitle, style: const TextStyle(fontSize: 14, color: Color(0xFF333333), fontWeight: FontWeight.w400)),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              content,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    final footerText = _config['footer_text'] ?? '© 2026 Cúrcuma';
    final instagram = _config['instagram_url'] ?? '';
    final facebook = _config['facebook_url'] ?? '';
    final email = _config['email_contacto'] ?? '';
    final horario = _config['horario_atencion'] ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          // Logo en footer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [_primary, _accent]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.eco, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 16),
          Text(
            _config['site_name'] ?? 'Cúrcuma',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              if (horario.isNotEmpty)
                _footerItem(Icons.schedule, horario),
              if (email.isNotEmpty)
                _footerItem(Icons.email_outlined, email),
            ],
          ),
          const SizedBox(height: 20),
          // Social icons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (instagram.isNotEmpty)
                _socialButton(Icons.camera_alt, instagram),
              if (facebook.isNotEmpty)
                _socialButton(Icons.facebook, facebook),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.white.withValues(alpha: 0.15), Colors.transparent],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(footerText, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
          const SizedBox(height: 6),
          Text(
            'Desarrollado por Programación JJ',
            style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.25)),
          ),
        ],
      ),
    );
  }

  Widget _footerItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withValues(alpha: 0.5)),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
      ],
    );
  }

  Widget _socialButton(IconData icon, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => launchUrl(Uri.parse(url)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 22),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
