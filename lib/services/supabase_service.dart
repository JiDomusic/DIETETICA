import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static SupabaseService get instance => _instance ??= SupabaseService._();
  SupabaseService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ==================== AUTH ====================

  User? get currentUser => _client.auth.currentUser;
  bool get isLoggedIn => currentUser != null;

  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Future<bool> isAdmin() async {
    if (!isLoggedIn) return false;
    try {
      final res = await _client
          .from('admin_roles')
          .select('role')
          .eq('user_id', currentUser!.id)
          .maybeSingle();
      return res != null && (res['role'] == 'admin' || res['role'] == 'editor');
    } catch (_) {
      return false;
    }
  }

  // ==================== SITE CONFIG ====================

  Future<Map<String, String>> getSiteConfig() async {
    final res = await _client.from('site_config').select();
    final map = <String, String>{};
    for (final row in res) {
      map[row['key'] as String] = (row['value'] ?? '') as String;
    }
    return map;
  }

  Future<void> updateSiteConfig(String key, String value) async {
    await _client.from('site_config').upsert({
      'key': key,
      'value': value,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'key');
  }

  // ==================== SECTIONS ====================

  Future<List<Map<String, dynamic>>> getSections({bool publishedOnly = true}) async {
    var query = _client.from('sections').select();
    if (publishedOnly) {
      query = query.eq('published', true);
    }
    return await query.order('position');
  }

  Future<Map<String, dynamic>> upsertSection(Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    final res = await _client.from('sections').upsert(data).select().single();
    return res;
  }

  Future<void> deleteSection(String id) async {
    await _client.from('sections').delete().eq('id', id);
  }

  // ==================== BANNERS ====================

  Future<List<Map<String, dynamic>>> getBanners({String? sectionId, bool activeOnly = true}) async {
    var query = _client.from('banners').select();
    if (sectionId != null) query = query.eq('section_id', sectionId);
    if (activeOnly) query = query.eq('active', true);
    return await query.order('position');
  }

  Future<Map<String, dynamic>> upsertBanner(Map<String, dynamic> data) async {
    final res = await _client.from('banners').upsert(data).select().single();
    return res;
  }

  Future<void> deleteBanner(String id) async {
    await _client.from('banners').delete().eq('id', id);
  }

  // ==================== CATEGORIES ====================

  Future<List<Map<String, dynamic>>> getCategories({bool activeOnly = true}) async {
    var query = _client.from('categories').select();
    if (activeOnly) query = query.eq('active', true);
    return await query.order('position');
  }

  Future<Map<String, dynamic>> upsertCategory(Map<String, dynamic> data) async {
    final res = await _client.from('categories').upsert(data).select().single();
    return res;
  }

  Future<void> deleteCategory(String id) async {
    await _client.from('categories').delete().eq('id', id);
  }

  // ==================== PRODUCTS ====================

  Future<List<Map<String, dynamic>>> getProducts({
    bool activeOnly = true,
    String? categoryId,
    bool? isPromo,
    bool? isNew,
    bool? isFeatured,
  }) async {
    var query = _client.from('products').select('*, categories(name, slug)');
    if (activeOnly) query = query.eq('is_active', true);
    if (categoryId != null) query = query.eq('category_id', categoryId);
    if (isPromo == true) query = query.eq('is_promo', true);
    if (isNew == true) query = query.eq('is_new', true);
    if (isFeatured == true) query = query.eq('is_featured', true);
    return await query.order('created_at', ascending: false);
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    return await _client
        .from('products')
        .select('*, categories(name, slug)')
        .order('name');
  }

  Future<Map<String, dynamic>> upsertProduct(Map<String, dynamic> data) async {
    data['updated_at'] = DateTime.now().toIso8601String();
    final res = await _client.from('products').upsert(data).select().single();
    return res;
  }

  Future<void> deleteProduct(String id) async {
    await _client.from('products').delete().eq('id', id);
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    final res = await _client
        .from('products')
        .select('*, categories(name)')
        .eq('is_active', true)
        .or('name.ilike.%$query%,description.ilike.%$query%')
        .order('name');
    // Log search
    await _client.from('search_logs').insert({'query': query, 'results_count': res.length});
    return res;
  }

  // ==================== STOCK ====================

  Future<List<Map<String, dynamic>>> getStock({String? locationId, String? productId}) async {
    var query = _client.from('stock').select('*, products(name, sku, image_path), locations(name)');
    if (locationId != null) query = query.eq('location_id', locationId);
    if (productId != null) query = query.eq('product_id', productId);
    return await query;
  }

  Future<int> setStock(String productId, String locationId, int qty) async {
    final res = await _client.rpc('set_stock', params: {
      'p_product_id': productId,
      'p_location_id': locationId,
      'p_qty': qty,
    });
    return res as int;
  }

  Future<int> incrementStock(String productId, String locationId, int qty, {String reason = 'manual_adjust'}) async {
    final res = await _client.rpc('increment_stock', params: {
      'p_product_id': productId,
      'p_location_id': locationId,
      'p_qty': qty,
      'p_reason': reason,
    });
    return res as int;
  }

  Future<int> decrementStock(String productId, String locationId, int qty, {String reason = 'sale'}) async {
    final res = await _client.rpc('decrement_stock', params: {
      'p_product_id': productId,
      'p_location_id': locationId,
      'p_qty': qty,
      'p_reason': reason,
    });
    return res as int;
  }

  Future<List<Map<String, dynamic>>> getStockMovements({String? locationId, int days = 30}) async {
    var query = _client.from('stock_movements')
        .select('*, products(name, sku), locations(name)')
        .gte('created_at', DateTime.now().subtract(Duration(days: days)).toIso8601String());
    if (locationId != null) query = query.eq('location_id', locationId);
    return await query.order('created_at', ascending: false);
  }

  /// Productos con stock bajo (qty <= min_qty)
  Future<List<Map<String, dynamic>>> getLowStock() async {
    final all = await _client.from('stock')
        .select('*, products(name, sku, image_path), locations(name)');
    return all.where((s) => (s['qty'] as int) <= (s['min_qty'] as int? ?? 0)).toList();
  }

  // ==================== LOCATIONS ====================

  Future<List<Map<String, dynamic>>> getLocations({bool activeOnly = true}) async {
    var query = _client.from('locations').select();
    if (activeOnly) query = query.eq('active', true);
    return await query.order('position');
  }

  Future<Map<String, dynamic>> upsertLocation(Map<String, dynamic> data) async {
    final res = await _client.from('locations').upsert(data).select().single();
    return res;
  }

  Future<void> deleteLocation(String id) async {
    await _client.from('locations').delete().eq('id', id);
  }

  // ==================== PROMOS ====================

  Future<List<Map<String, dynamic>>> getPromos({bool activeOnly = true}) async {
    var query = _client.from('promos').select('*, products(name, image_path, price)');
    if (activeOnly) query = query.eq('active', true);
    return await query.order('position');
  }

  Future<Map<String, dynamic>> upsertPromo(Map<String, dynamic> data) async {
    final res = await _client.from('promos').upsert(data).select().single();
    return res;
  }

  Future<void> deletePromo(String id) async {
    await _client.from('promos').delete().eq('id', id);
  }

  // ==================== GALLERY ====================

  Future<List<Map<String, dynamic>>> getGallery({bool activeOnly = true}) async {
    var query = _client.from('gallery').select();
    if (activeOnly) query = query.eq('active', true);
    return await query.order('position');
  }

  Future<Map<String, dynamic>> upsertGalleryItem(Map<String, dynamic> data) async {
    final res = await _client.from('gallery').upsert(data).select().single();
    return res;
  }

  Future<void> deleteGalleryItem(String id) async {
    await _client.from('gallery').delete().eq('id', id);
  }

  // ==================== VIDEOS ====================

  Future<List<Map<String, dynamic>>> getVideos({bool activeOnly = true}) async {
    var query = _client.from('videos').select();
    if (activeOnly) query = query.eq('active', true);
    return await query.order('position');
  }

  Future<Map<String, dynamic>> upsertVideo(Map<String, dynamic> data) async {
    final res = await _client.from('videos').upsert(data).select().single();
    return res;
  }

  Future<void> deleteVideo(String id) async {
    await _client.from('videos').delete().eq('id', id);
  }

  // ==================== RESERVATIONS ====================

  Future<List<Map<String, dynamic>>> getReservations({String? status}) async {
    var query = _client.from('reservations').select('*, products(name, image_path), locations(name)');
    if (status != null) query = query.eq('status', status);
    return await query.order('created_at', ascending: false);
  }

  Future<String> createReservation({
    required String productId,
    required String locationId,
    required int qty,
    required String customerName,
    required String customerPhone,
    String? customerEmail,
    String? paymentRef,
    String? notes,
  }) async {
    final res = await _client.rpc('create_reservation', params: {
      'p_product_id': productId,
      'p_location_id': locationId,
      'p_qty': qty,
      'p_customer_name': customerName,
      'p_customer_phone': customerPhone,
      'p_customer_email': customerEmail,
      'p_payment_ref': paymentRef,
      'p_notes': notes,
    });
    return res as String;
  }

  Future<void> updateReservationStatus(String id, String status) async {
    await _client.from('reservations').update({
      'status': status,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> cancelReservation(String id) async {
    await _client.rpc('cancel_reservation', params: {'p_reservation_id': id});
  }

  // ==================== NAVBAR ITEMS ====================

  Future<List<Map<String, dynamic>>> getNavbarItems({bool activeOnly = true}) async {
    var query = _client.from('navbar_items').select();
    if (activeOnly) query = query.eq('active', true);
    return await query.order('position');
  }

  Future<Map<String, dynamic>> upsertNavbarItem(Map<String, dynamic> data) async {
    final res = await _client.from('navbar_items').upsert(data).select().single();
    return res;
  }

  Future<void> deleteNavbarItem(String id) async {
    await _client.from('navbar_items').delete().eq('id', id);
  }

  // ==================== HOME BANNERS ====================

  Future<List<Map<String, dynamic>>> getHomeBanners({bool activeOnly = true}) async {
    var query = _client.from('home_banners').select();
    if (activeOnly) query = query.eq('active', true);
    return await query.order('position');
  }

  Future<Map<String, dynamic>> upsertHomeBanner(Map<String, dynamic> data) async {
    final res = await _client.from('home_banners').upsert(data).select().single();
    return res;
  }

  Future<void> deleteHomeBanner(String id) async {
    await _client.from('home_banners').delete().eq('id', id);
  }

  // ==================== SECTION PRODUCTS ====================

  Future<List<Map<String, dynamic>>> getSectionProducts(String sectionId) async {
    return await _client
        .from('section_products')
        .select('*, products(*, categories(name))')
        .eq('section_id', sectionId)
        .order('position');
  }

  Future<void> addProductToSection(String sectionId, String productId, int position) async {
    await _client.from('section_products').upsert({
      'section_id': sectionId,
      'product_id': productId,
      'position': position,
    });
  }

  Future<void> removeProductFromSection(String sectionId, String productId) async {
    await _client.from('section_products')
        .delete()
        .eq('section_id', sectionId)
        .eq('product_id', productId);
  }

  // ==================== ADMIN ROLES ====================

  Future<List<Map<String, dynamic>>> getAdminRoles() async {
    return await _client.from('admin_roles').select();
  }

  Future<void> addAdmin(String userId, {String role = 'admin'}) async {
    await _client.rpc('add_admin', params: {'p_user_id': userId, 'p_role': role});
  }

  Future<void> removeAdmin(String userId) async {
    await _client.rpc('remove_admin', params: {'p_user_id': userId});
  }

  // ==================== ONBOARDING ====================

  Future<List<Map<String, dynamic>>> getOnboardingSteps() async {
    return await _client.from('onboarding_config').select().order('step_number');
  }

  Future<Map<String, dynamic>> upsertOnboardingStep(Map<String, dynamic> data) async {
    final res = await _client.from('onboarding_config').upsert(data).select().single();
    return res;
  }

  Future<void> deleteOnboardingStep(String id) async {
    await _client.from('onboarding_config').delete().eq('id', id);
  }

  // ==================== ANALYTICS ====================

  Future<void> logProductView(String productId) async {
    await _client.from('product_views').insert({'product_id': productId});
  }

  Future<List<Map<String, dynamic>>> getTopProducts({int limit = 10}) async {
    final res = await _client.rpc('get_top_products', params: {'p_limit': limit});
    return List<Map<String, dynamic>>.from(res);
  }

  Future<List<Map<String, dynamic>>> getStockMovementsSummary({String? locationId, int days = 30}) async {
    final res = await _client.rpc('get_stock_movements_summary', params: {
      'p_location_id': locationId,
      'p_days': days,
    });
    return List<Map<String, dynamic>>.from(res);
  }

  // ==================== DEMO DATA ====================

  Future<Map<String, dynamic>> cleanDemoData() async {
    final res = await _client.rpc('clean_demo_data');
    return Map<String, dynamic>.from(res as Map);
  }

  // ==================== STORAGE (IMÁGENES) ====================

  Future<String> uploadImage(String folder, String fileName, Uint8List bytes) async {
    final path = '$folder/$fileName';
    await _client.storage.from(AppConfig.storageBucket).uploadBinary(
      path,
      bytes,
      fileOptions: const FileOptions(upsert: true),
    );
    return path;
  }

  Future<void> deleteImage(String path) async {
    await _client.storage.from(AppConfig.storageBucket).remove([path]);
  }

  String getPublicImageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return _client.storage.from(AppConfig.storageBucket).getPublicUrl(path);
  }
}
