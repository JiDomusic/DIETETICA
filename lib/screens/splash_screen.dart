import 'package:flutter/material.dart';
import '../config/theme_config.dart';
import '../services/supabase_service.dart';
import 'public/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;
  String _statusText = '';
  String _logoPath = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOut)),
    );
    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6, curve: Curves.easeOutBack)),
    );
    _controller.forward();
    _initApp();
  }

  Future<void> _initApp() async {
    setState(() => _statusText = 'Cargando configuración...');

    try {
      final config = await SupabaseService.instance.getSiteConfig();
      // Cargar colores dinámicos desde site_config
      ThemeConfig.instance.loadFromConfig(config);
      _logoPath = config['logo_path'] ?? '';
      setState(() => _statusText = 'Preparando la tienda...');
    } catch (e) {
      setState(() => _statusText = 'Conectando...');
    }

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primary = ThemeConfig.instance.primary;
    final accent = ThemeConfig.instance.accent;
    final hasLogo = _logoPath.isNotEmpty;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, primary.withValues(alpha: 0.05), Colors.white],
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnim.value,
                child: Transform.scale(
                  scale: _scaleAnim.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogoCircle(primary, accent, hasLogo),
                      const SizedBox(height: 32),
                      Text(
                        'Dietética Centro',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A1A1A),
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Alimentos saludables',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: primary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(primary.withValues(alpha: 0.7)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogoCircle(Color primary, Color accent, bool hasLogo) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: [primary, accent]),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: hasLogo
          ? ClipOval(
              child: Image.network(
                SupabaseService.instance.getPublicImageUrl(_logoPath),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.eco, size: 60, color: Colors.white),
              ),
            )
          : const Icon(Icons.eco, size: 60, color: Colors.white),
    );
  }
}
