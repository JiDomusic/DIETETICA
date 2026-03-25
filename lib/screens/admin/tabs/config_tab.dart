import 'package:flutter/material.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import '../../../services/supabase_service.dart';
import '../../../widgets/admin_helpers.dart';

class ConfigTab extends StatefulWidget {
  const ConfigTab({super.key});

  @override
  State<ConfigTab> createState() => _ConfigTabState();
}

class _ConfigTabState extends State<ConfigTab> {
  final _svc = SupabaseService.instance;
  Map<String, String> _config = {};
  List<Map<String, dynamic>> _admins = [];
  bool _loading = true;
  bool _saving = false;
  bool _lastSaveSuccess = false;

  // Controllers para campos de texto
  final _controllers = <String, TextEditingController>{};

  // Colores editables
  late Color _primaryColor;
  late Color _secondaryColor;
  late Color _accentColor;

  // Campos de texto (sin los colores, que ahora son pickers)
  static const _textFields = [
    ('site_name', 'Nombre del sitio', 'Ej: Dietética Centro', Icons.store),
    ('whatsapp_default', 'WhatsApp principal (con cód. país)', '549341...', Icons.chat),
    ('cbu_info', 'CBU para pagos', 'Número CBU completo', Icons.account_balance),
    ('alias_cbu', 'Alias CBU', 'mi.alias.cbu', Icons.tag),
    ('footer_text', 'Texto del footer', '© 2026 Mi Tienda', Icons.text_fields),
    ('meta_description', 'Meta descripción (SEO)', 'Descripción para buscadores', Icons.search),
    ('instagram_url', 'URL Instagram', 'https://instagram.com/...', Icons.camera_alt),
    ('facebook_url', 'URL Facebook', 'https://facebook.com/...', Icons.facebook),
    ('email_contacto', 'Email de contacto', 'correo@tienda.com', Icons.email),
    ('horario_atencion', 'Horario de atención', 'Lunes a Sábado 9:00 - 20:00', Icons.schedule),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Convierte hex (#2E7D32) a Color
  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  /// Convierte Color a hex (#2E7D32)
  String _colorToHex(Color c) {
    final rgb = c.value & 0xFFFFFF;
    return '#${rgb.toRadixString(16).padLeft(6, '0').toUpperCase()}';
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      _svc.getSiteConfig(),
      _svc.getAdminRoles(),
    ]);
    _config = results[0] as Map<String, String>;
    _admins = results[1] as List<Map<String, dynamic>>;

    // Inicializar controllers de texto
    for (final field in _textFields) {
      _controllers[field.$1] = TextEditingController(text: _config[field.$1] ?? '');
    }

    // Inicializar colores desde config
    _primaryColor = _hexToColor(_config['color_primary'] ?? _config['primary_color'] ?? '#2E7D32');
    _secondaryColor = _hexToColor(_config['color_secondary'] ?? _config['secondary_color'] ?? '#FF8F00');
    _accentColor = _hexToColor(_config['color_accent'] ?? _config['accent_color'] ?? '#1B5E20');

    setState(() => _loading = false);
  }

  /// Abre el color picker wheel (igual que Bella Color)
  Future<void> _pickColor(String label, Color current, ValueChanged<Color> onPick) async {
    Color picked = current;
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141A22),
        title: Text(label, style: const TextStyle(color: Color(0xFFF5F5F5))),
        content: SingleChildScrollView(
          child: ColorPicker(
            color: current,
            onColorChanged: (c) => picked = c,
            heading: const Text('Elegí un color',
                style: TextStyle(color: Color(0xFF8A9BAE), fontSize: 14)),
            subheading: const Text('Tono',
                style: TextStyle(color: Color(0xFF8A9BAE), fontSize: 13)),
            wheelSubheading: const Text('Opacidad',
                style: TextStyle(color: Color(0xFF8A9BAE), fontSize: 13)),
            pickersEnabled: const <ColorPickerType, bool>{
              ColorPickerType.wheel: true,
              ColorPickerType.accent: false,
              ColorPickerType.primary: false,
              ColorPickerType.both: false,
              ColorPickerType.bw: false,
              ColorPickerType.custom: false,
              ColorPickerType.customSecondary: false,
            },
            width: 36,
            height: 36,
            borderRadius: 18,
            wheelDiameter: 220,
            wheelWidth: 18,
            showColorCode: true,
            colorCodeHasColor: true,
            colorCodeTextStyle: const TextStyle(fontSize: 14, fontFamily: 'monospace'),
            showColorName: true,
            showRecentColors: true,
            recentColors: const [],
            enableShadesSelection: true,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              onPick(picked);
              Navigator.pop(ctx);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }

  /// Widget de botón de color (círculo + label)
  Widget _colorButton(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.palette, color: Colors.white70, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(_colorToHex(color),
              style: const TextStyle(fontSize: 10, color: Color(0xFF8A9BAE), fontFamily: 'monospace')),
        ],
      ),
    );
  }

  Future<void> _saveAll() async {
    setState(() {
      _saving = true;
      _lastSaveSuccess = false;
    });
    try {
      // Guardar campos de texto
      for (final field in _textFields) {
        final val = _controllers[field.$1]?.text ?? '';
        if (val != (_config[field.$1] ?? '')) {
          await _svc.updateSiteConfig(field.$1, val);
        }
      }
      // Guardar colores
      await _svc.updateSiteConfig('primary_color', _colorToHex(_primaryColor));
      await _svc.updateSiteConfig('secondary_color', _colorToHex(_secondaryColor));
      await _svc.updateSiteConfig('accent_color', _colorToHex(_accentColor));

      if (mounted) {
        showSuccessSnack(context, 'Configuración guardada con éxito');
        setState(() => _lastSaveSuccess = true);
      }
    } catch (e) {
      if (mounted) showSuccessSnack(context, 'Error: $e', isError: true);
    }
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2E7D32).withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.settings, color: Color(0xFF66BB6A)),
                SizedBox(width: 12),
                Expanded(child: Text(
                  'Configuración general del sitio. Todo lo que editás acá se refleja en el home público. '
                  'Cambiá nombre, colores, datos de contacto, CBU para pagos, redes sociales y más.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE)),
                )),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ========== CONFIG FIELDS ==========
          const Text('Datos del Sitio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),

          ...(_textFields.map((field) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextField(
              controller: _controllers[field.$1],
              decoration: InputDecoration(
                labelText: field.$2,
                hintText: field.$3,
                prefixIcon: Icon(field.$4, size: 18),
              ),
            ),
          ))),

          const SizedBox(height: 32),

          // ========== COLORES DE MARCA ==========
          Row(
            children: [
              const Icon(Icons.palette, color: Color(0xFF66BB6A)),
              const SizedBox(width: 8),
              const Text('Colores de tu Marca', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tocá cada círculo para abrir la rueda de colores y elegir el que quieras. '
            'Los colores se aplican en toda la web: botones, bordes, acentos, etc.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE)),
          ),
          const SizedBox(height: 20),

          // Preview de los 3 colores
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2230),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF2A3545)),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _colorButton('Primario', _primaryColor, () {
                      _pickColor('Color Primario', _primaryColor, (c) {
                        setState(() => _primaryColor = c);
                      });
                    }),
                    _colorButton('Secundario', _secondaryColor, () {
                      _pickColor('Color Secundario', _secondaryColor, (c) {
                        setState(() => _secondaryColor = c);
                      });
                    }),
                    _colorButton('Acento', _accentColor, () {
                      _pickColor('Color Acento', _accentColor, (c) {
                        setState(() => _accentColor = c);
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                // Preview en vivo
                const Text('Vista previa', style: TextStyle(fontSize: 13, color: Color(0xFF8A9BAE))),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: _primaryColor),
                        child: const Text('Botón Primario'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: _secondaryColor),
                        child: const Text('Botón Secundario'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: _accentColor, width: 2),
                  ),
                  child: Text('Borde con color acento',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: _accentColor, fontSize: 13)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // ========== GUARDAR ==========
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _saveAll,
              icon: _saving
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Icon(_lastSaveSuccess ? Icons.check_circle : Icons.save),
              label: Text(_saving ? 'Guardando...' : (_lastSaveSuccess ? 'Guardado con éxito' : 'Guardar Configuración')),
            ),
          ),

          const SizedBox(height: 40),

          // ========== DATOS DEMO ==========
          Row(
            children: [
              const Icon(Icons.cleaning_services, color: Color(0xFFFF8F00)),
              const SizedBox(width: 8),
              const Text('Datos de Ejemplo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Si tu sitio tiene datos de ejemplo (demo), podés eliminarlos para empezar '
            'a cargar los productos reales de tu local. Esto borra productos, promos, '
            'stock, sucursales, galería y videos de ejemplo. Las categorías y secciones se mantienen.',
            style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE)),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFF8F00).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFF8F00).withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8F00), size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text(
                      'Esta acción no se puede deshacer. Solo eliminá los datos demo '
                      'cuando estés listo para cargar tus productos reales.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE)),
                    )),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _cleanDemoData,
                    icon: const Icon(Icons.delete_sweep, size: 18),
                    label: const Text('Eliminar Datos de Ejemplo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF8F00),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),

          // ========== ADMINS ==========
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Color(0xFF66BB6A)),
              const SizedBox(width: 8),
              const Text('Administradores', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const Spacer(),
              if (_admins.length < 3)
                TextButton.icon(
                  onPressed: _addAdmin,
                  icon: const Icon(Icons.person_add, size: 16),
                  label: const Text('Agregar Admin'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Máximo 3 admins. Actual: ${_admins.length}/3', style: const TextStyle(fontSize: 12, color: Color(0xFF8A9BAE))),
          const SizedBox(height: 12),

          ..._admins.map((a) {
            final uid = a['user_id'] as String;
            final isCurrentUser = uid == _svc.currentUser?.id;
            return Card(
              color: const Color(0xFF1A2230),
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(Icons.person, color: isCurrentUser ? const Color(0xFF66BB6A) : const Color(0xFF8A9BAE)),
                title: Text(uid, style: const TextStyle(fontSize: 12, fontFamily: 'monospace')),
                subtitle: Text('Rol: ${a['role']} ${isCurrentUser ? '(vos)' : ''}', style: const TextStyle(fontSize: 11, color: Color(0xFF8A9BAE))),
                trailing: isCurrentUser
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.person_remove, size: 18, color: Colors.red),
                        onPressed: () => _removeAdmin(uid),
                        tooltip: 'Quitar admin',
                      ),
              ),
            );
          }),

          const SizedBox(height: 40),

          // ========== LOGO ==========
          const Text('Logo del Sitio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          const Text('Subí tu logo en JPG o PNG. Se muestra en el splash y el navbar.', style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE))),
          const SizedBox(height: 12),
          ImagePickerField(
            currentPath: _config['logo_path'] ?? '',
            folder: 'config',
            onChanged: (path) async {
              await _svc.updateSiteConfig('logo_path', path);
              if (!mounted) return;
              showSuccessSnack(context, 'Logo actualizado');
              _load();
            },
          ),
        ],
      ),
    );
  }

  Future<void> _cleanDemoData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF8F00)),
            SizedBox(width: 8),
            Text('Eliminar datos demo'),
          ],
        ),
        content: const Text(
          '¿Estás seguro?\n\n'
          'Se van a eliminar todos los productos de ejemplo (DEMO-*), '
          'promos, stock, sucursales, galería y videos de ejemplo.\n\n'
          'Las categorías y secciones se mantienen para que cargues '
          'tus datos reales.\n\n'
          'Esta acción NO se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, Eliminar Demo'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final res = await _svc.cleanDemoData();
        final count = res['productos_eliminados'] ?? 0;
        if (mounted) {
          showSuccessSnack(context,
            'Datos demo eliminados ($count productos). '
            '¡Ya podés cargar los datos reales de tu local!',
          );
          _load();
        }
      } catch (e) {
        if (mounted) showSuccessSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _addAdmin() async {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Agregar Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Creá un nuevo usuario admin. Se registra automáticamente en Supabase Auth.',
              style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE))),
            const SizedBox(height: 12),
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email *')),
            const SizedBox(height: 8),
            TextField(controller: passCtrl, decoration: const InputDecoration(labelText: 'Contraseña *'), obscureText: true),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Crear'),
          ),
        ],
      ),
    );

    if (result == true && emailCtrl.text.isNotEmpty && passCtrl.text.isNotEmpty) {
      try {
        if (mounted) {
          showSuccessSnack(context,
            'El nuevo admin debe registrarse en Supabase Auth con: ${emailCtrl.text}. '
            'Luego pegá su UUID acá para agregarlo como admin.',
          );
        }
      } catch (e) {
        if (mounted) showSuccessSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  Future<void> _removeAdmin(String userId) async {
    if (await showConfirmDialog(context, 'Quitar permisos de admin a este usuario?')) {
      try {
        await _svc.removeAdmin(userId);
        if (mounted) showSuccessSnack(context, 'Admin removido');
        _load();
      } catch (e) {
        if (mounted) showSuccessSnack(context, 'Error: $e', isError: true);
      }
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }
}
