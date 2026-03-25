import 'package:flutter/material.dart';
import '../../config/theme_config.dart';
import '../../services/supabase_service.dart';

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
  Map<String, int> _stockTotal = {}; // productId -> total qty
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final productos = await _svc.getProducts(categoryId: widget.categoryId);
      // Cargar stock para cada producto
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.categoryName,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _primary,
          ),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: _primary))
          : _productos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'No hay productos en esta categoría',
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _productos.length,
                  itemBuilder: (context, i) => _buildProductTile(_productos[i]),
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

    // Buscar si tiene promo con precio especial
    // (usamos is_promo flag del producto)

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: sinStock
              ? Colors.red.withValues(alpha: 0.3)
              : isPromo
                  ? _primary.withValues(alpha: 0.4)
                  : const Color(0xFFE8E8E8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: SizedBox(
              width: _isMobile ? 110 : 150,
              height: _isMobile ? 130 : 150,
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
                    top: 6,
                    left: 6,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isPromo)
                          _badge('PROMO', _primary),
                        if (isNew)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: _badge('NUEVO', const Color(0xFFFF8F00)),
                          ),
                      ],
                    ),
                  ),
                  // Sin stock overlay
                  if (sinStock)
                    Container(
                      color: Colors.white.withValues(alpha: 0.6),
                      child: const Center(
                        child: Text(
                          'SIN STOCK',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.red,
                          ),
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
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: sinStock ? Colors.grey : const Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (desc.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      desc,
                      style: TextStyle(
                        fontSize: 13,
                        color: sinStock ? Colors.grey[400] : const Color(0xFF666666),
                        height: 1.4,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 10),
                  // Precio
                  Row(
                    children: [
                      Text(
                        '\$ ${price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: sinStock ? Colors.grey : _primary,
                          decoration: isPromo ? TextDecoration.lineThrough : null,
                          decorationColor: Colors.grey,
                        ),
                      ),
                      if (isPromo) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'EN OFERTA',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: _primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Stock indicator
                  Row(
                    children: [
                      Icon(
                        sinStock
                            ? Icons.cancel
                            : stock <= 5
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle,
                        size: 16,
                        color: sinStock
                            ? Colors.red
                            : stock <= 5
                                ? const Color(0xFFFF8F00)
                                : const Color(0xFF4CAF50),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        sinStock
                            ? 'Sin stock'
                            : stock <= 5
                                ? 'Últimas unidades'
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
    );
  }

  Widget _placeholderImg() {
    return Container(
      color: _primary.withValues(alpha: 0.08),
      child: Center(child: Icon(Icons.eco, size: 36, color: _primary.withValues(alpha: 0.4))),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
