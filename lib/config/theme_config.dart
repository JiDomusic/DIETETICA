import 'package:flutter/material.dart';

/// Singleton que mantiene los colores dinámicos de la tienda.
/// Se carga desde site_config en el splash y se usa en todo el home público.
class ThemeConfig {
  static final ThemeConfig instance = ThemeConfig._();
  ThemeConfig._();

  Color primary = const Color(0xFF2E7D32);
  Color secondary = const Color(0xFFFF8F00);
  Color accent = const Color(0xFF66BB6A);

  /// Callback para reconstruir el MaterialApp cuando cambian colores
  VoidCallback? onColorsChanged;

  void loadFromConfig(Map<String, String> config) {
    if (config['color_primary'] != null && config['color_primary']!.isNotEmpty) {
      primary = _hexToColor(config['color_primary']!);
    }
    if (config['color_secondary'] != null && config['color_secondary']!.isNotEmpty) {
      secondary = _hexToColor(config['color_secondary']!);
    }
    if (config['color_accent'] != null && config['color_accent']!.isNotEmpty) {
      accent = _hexToColor(config['color_accent']!);
    }
    onColorsChanged?.call();
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }
}
