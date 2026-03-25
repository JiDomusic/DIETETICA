import 'package:flutter/material.dart';

/// Singleton que mantiene los colores dinámicos de la tienda.
/// Se carga desde site_config en el splash y se usa en todo el home público.
class ThemeConfig {
  static final ThemeConfig instance = ThemeConfig._();
  ThemeConfig._();

  Color primary = const Color(0xFFF0A830);   // Naranja cúrcuma
  Color secondary = const Color(0xFF2D2D2D); // Gris oscuro/carbón
  Color accent = const Color(0xFFF5C563);    // Dorado claro

  /// Callback para reconstruir el MaterialApp cuando cambian colores
  VoidCallback? onColorsChanged;

  void loadFromConfig(Map<String, String> config) {
    primary = _pickColor(config, ['color_primary', 'primary_color'], primary);
    secondary = _pickColor(config, ['color_secondary', 'secondary_color'], secondary);
    accent = _pickColor(config, ['color_accent', 'accent_color'], accent);
    onColorsChanged?.call();
  }

  Color _pickColor(Map<String, String> config, List<String> keys, Color fallback) {
    for (final key in keys) {
      final value = config[key];
      if (value != null && value.isNotEmpty) {
        try {
          return _hexToColor(value);
        } catch (_) {
          // Si el valor viene inválido, seguimos buscando o usamos el fallback.
        }
      }
    }
    return fallback;
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
