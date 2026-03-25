import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../services/supabase_service.dart';
import '../../widgets/animated_section.dart';

class CategoryProductsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;

  const CategoryProductsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryProductsScreen> createState() => _CategoryProductsScreenState();
}

class _CategoryProductsScreenState extends State<CategoryProductsScreen> {
  final _svc = SupabaseService.instance;
  List<Map<String, dynamic>> _productos = [];
  Map<String, int> _stockTotal = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final productos = await _svc.getProducts(categoryId: widget.categoryId);
      final stockMap = <String, int>{};
      for (final p in productos) {
        final pid = p['id'] as String;
        final stockList = await _svc.getStock(productId: pid);
        int total = 0;
        for (final s in stockList) {
          total += (s['qty'] as int? ?? 0);
        }
        stockMap[pid] = total;
      }

      if (!mounted) return;
      setState(() {
        _productos = productos;
        _stockTotal = stockMap;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 768;
  Color get _primary => ThemeConfig.instance.primary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.arrow_back, color: _primary, size: 20),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.categoryName,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              '${_productos.length} productos',
              style: TextStyle(fontSize: 12, color: Colors.grey[400], fontWeight: FontWeight.w500),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFF0F0F0),
          ),
        ),
      ),
      body: _loading
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: _primary, strokeWidth: 3),
                  const SizedBox(height: 12),
                  Text('Cargando...', style: TextStyle(color: Colors.grey[400])),
                ],
              ),
            )
          : _productos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos en esta categoría',
                        style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                )
              : _isMobile ? _buildMobileList() : _buildDesktopGrid(),
    );
  }

  Widget _buildMobileList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _productos.length,
      itemBuilder: (context, i) => AnimatedSection(
        delayMs: i * 80,
        child: _buildProductTile(_productos[i]),
      ),
    );
  }

  Widget _buildDesktopGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 2.8,
      ),
      itemCount: _productos.length,
      itemBuilder: (context, i) => AnimatedSection(
        delayMs: i * 80,
        child: _buildProductTile(_productos[i]),
      ),
    );
  }

  Widget _buildProductTile(Map<String, dynamic> product) {
    final id = product['id'] as String;
    final name = product['name'] as String? ?? '';
    final desc = product['description'] as String? ?? '';
    final price = product['price'] as num? ?? 0;
    final imgPath = product['image_path'] as String? ?? '';
    final isPromo = product['is_promo'] == true;
    final isNew = product['is_new'] == true;
    final stock = _stockTotal[id] ?? 0;
    final sinStock = stock <= 0;

    return HoverScaleCard(
      scale: 1.02,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: sinStock
                ? Colors.red.withValues(alpha: 0.2)
                : const Color(0xFFF0F0F0),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
              child: SizedBox(
                width: _isMobile ? 120 : 160,
                height: _isMobile ? 140 : 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    imgPath.isNotEmpty
                        ? Image.network(
                            _svc.getPublicImageUrl(imgPath),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _placeholderImg(),
                          )
                        : _placeholderImg(),
                    // Badges
                    Positioned(
                      top: 8, left: 8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isPromo)
                            _badge('PROMO', ThemeConfig.instance.secondary),
                          if (isNew)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: _badge('NUEVO', _primary),
                            ),
                        ],
                      ),
                    ),
                    if (sinStock)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.7),
                          borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                            ),
                            child: const Text('SIN STOCK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.red)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: sinStock ? Colors.grey : const Color(0xFF1A1A2E),
                      ),
                      maxLines: 2, overflow: TextOverflow.ellipsis,
                    ),
                    if (desc.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 13,
                          color: sinStock ? Colors.grey[400] : const Color(0xFF9CA3AF),
                          height: 1.4,
                        ),
                        maxLines: 3, overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Precio - estilo minimalista
                    Text(
                      '\$ ${price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: sinStock ? Colors.grey : const Color(0xFF333333),
                        decoration: isPromo ? TextDecoration.lineThrough : null,
                        decorationColor: const Color(0xFFBBBBBB),
                      ),
                    ),
                    if (isPromo)
                      Text(
                        'En oferta',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: ThemeConfig.instance.secondary,
                        ),
                      ),
                    const SizedBox(height: 8),
                    // Stock
                    Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: sinStock
                                ? Colors.red
                                : stock <= 5
                                    ? const Color(0xFFFF8F00)
                                    : const Color(0xFF4CAF50),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          sinStock
                              ? 'Sin stock'
                              : stock <= 5
                                  ? 'Últimas $stock unidades'
                                  : 'Disponible',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: sinStock
                                ? Colors.red
                                : stock <= 5
                                    ? const Color(0xFFFF8F00)
                                    : const Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderImg() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_primary.withValues(alpha: 0.12), _primary.withValues(alpha: 0.04)],
        ),
      ),
      child: Center(child: Icon(Icons.eco, size: 36, color: _primary.withValues(alpha: 0.3))),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6)],
      ),
      child: Text(text, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white, letterSpacing: 0.5)),
    );
  }
}
