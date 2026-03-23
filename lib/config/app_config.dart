/// Configuración centralizada de la app.
/// Las claves de Supabase se inyectan via --dart-define en build_prod.sh
/// NUNCA se exponen en el código fuente.
class AppConfig {
  // Supabase - inyectadas en tiempo de build
  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );
  static const supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  // Storage bucket
  static const storageBucket = 'images-dietetica';

  // Límites
  static const maxAdmins = 3;
  static const maxImageSizeMB = 5;
  static const allowedImageTypes = ['jpg', 'jpeg', 'png'];

  // Defaults de diseño
  static const defaultPrimaryColor = 0xFF2E7D32;
  static const defaultSecondaryColor = 0xFFFF8F00;
  static const defaultAccentColor = 0xFF1B5E20;
  static const defaultBgColor = 0xFF0A0E14;

  /// Genera la URL pública de una imagen en el bucket
  static String imageUrl(String path) {
    if (path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return '$supabaseUrl/storage/v1/object/public/$storageBucket/$path';
  }
}
