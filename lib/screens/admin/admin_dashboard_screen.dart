import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import 'tabs/home_tab.dart';
import 'tabs/products_tab.dart';
import 'tabs/stock_tab.dart';
import 'tabs/promos_tab.dart';
import 'tabs/gallery_tab.dart';
import 'tabs/videos_tab.dart';
import 'tabs/locations_tab.dart';
import 'tabs/reservations_tab.dart';
import 'tabs/analytics_tab.dart';
import 'tabs/config_tab.dart';
import 'tabs/manual_tab.dart';
import '../public/home_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  final _svc = SupabaseService.instance;

  static const _tabs = [
    Tab(icon: Icon(Icons.home), text: 'Home'),
    Tab(icon: Icon(Icons.inventory_2), text: 'Productos'),
    Tab(icon: Icon(Icons.warehouse), text: 'Stock'),
    Tab(icon: Icon(Icons.local_offer), text: 'Promos'),
    Tab(icon: Icon(Icons.photo_library), text: 'Galería'),
    Tab(icon: Icon(Icons.play_circle), text: 'Videos'),
    Tab(icon: Icon(Icons.store), text: 'Sucursales'),
    Tab(icon: Icon(Icons.shopping_bag), text: 'Reservas'),
    Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
    Tab(icon: Icon(Icons.settings), text: 'Config'),
    Tab(icon: Icon(Icons.menu_book), text: 'Manual'),
  ];

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: _tabs.length, vsync: this);
  }

  void _logout() async {
    await _svc.signOut();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 900;

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, color: Color(0xFFF0A830), size: 24),
            SizedBox(width: 8),
            Text('Admin - Cúrcuma'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.visibility, size: 20),
            tooltip: 'Ver tienda',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout, size: 20),
            tooltip: 'Cerrar sesión',
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabCtrl,
          isScrollable: true,
          tabs: _tabs,
          indicatorColor: const Color(0xFFF0A830),
          labelColor: const Color(0xFFF0A830),
          unselectedLabelColor: const Color(0xFF8A9BAE),
          tabAlignment: TabAlignment.start,
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: const [
          HomeTab(),
          ProductsTab(),
          StockTab(),
          PromosTab(),
          GalleryTab(),
          VideosTab(),
          LocationsTab(),
          ReservationsTab(),
          AnalyticsTab(),
          ConfigTab(),
          ManualTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }
}
