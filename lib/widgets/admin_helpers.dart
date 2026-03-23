import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/supabase_service.dart';
import '../config/app_config.dart';

/// Muestra snackbar de éxito o error
void showSuccessSnack(BuildContext context, String msg, {bool isError = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        Icon(isError ? Icons.error : Icons.check_circle, color: isError ? Colors.red : const Color(0xFF66BB6A), size: 20),
        const SizedBox(width: 8),
        Expanded(child: Text(msg)),
      ],
    ),
    backgroundColor: const Color(0xFF1A2230),
    duration: const Duration(seconds: 3),
  ));
}

/// Diálogo de confirmación
Future<bool> showConfirmDialog(BuildContext context, String message) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirmar'),
      content: Text(message),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Eliminar'),
        ),
      ],
    ),
  ) ?? false;
}

/// Widget para seleccionar y subir imagen al bucket
class ImagePickerField extends StatefulWidget {
  final String currentPath;
  final String folder;
  final ValueChanged<String> onChanged;

  const ImagePickerField({
    super.key,
    required this.currentPath,
    required this.folder,
    required this.onChanged,
  });

  @override
  State<ImagePickerField> createState() => _ImagePickerFieldState();
}

class _ImagePickerFieldState extends State<ImagePickerField> {
  bool _uploading = false;
  String _path = '';

  @override
  void initState() {
    super.initState();
    _path = widget.currentPath;
  }

  Future<void> _pickAndUpload() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;

    // Validar tamaño
    if (file.size > AppConfig.maxImageSizeMB * 1024 * 1024) {
      if (mounted) showSuccessSnack(context, 'Imagen muy grande. Máximo ${AppConfig.maxImageSizeMB}MB', isError: true);
      return;
    }

    // Validar tipo
    final ext = file.extension?.toLowerCase() ?? '';
    if (!AppConfig.allowedImageTypes.contains(ext)) {
      if (mounted) showSuccessSnack(context, 'Solo se permiten archivos JPG o PNG', isError: true);
      return;
    }

    setState(() => _uploading = true);

    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
      final uploadedPath = await SupabaseService.instance.uploadImage(widget.folder, fileName, file.bytes!);
      setState(() { _path = uploadedPath; _uploading = false; });
      widget.onChanged(uploadedPath);
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) showSuccessSnack(context, 'Error subiendo: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Imagen (JPG/PNG)', style: TextStyle(fontSize: 12, color: Color(0xFF8A9BAE))),
        const SizedBox(height: 6),
        if (_path.isNotEmpty)
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  SupabaseService.instance.getPublicImageUrl(_path),
                  height: 120, width: double.infinity, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 120, color: const Color(0xFF2A3545),
                    child: const Center(child: Text('Error cargando imagen')),
                  ),
                ),
              ),
              Positioned(
                top: 4, right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.red, size: 20),
                  onPressed: () {
                    setState(() => _path = '');
                    widget.onChanged('');
                  },
                  style: IconButton.styleFrom(backgroundColor: Colors.black54),
                ),
              ),
            ],
          ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _uploading ? null : _pickAndUpload,
            icon: _uploading
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload, size: 18),
            label: Text(_uploading ? 'Subiendo...' : (_path.isEmpty ? 'Subir imagen' : 'Cambiar imagen')),
          ),
        ),
      ],
    );
  }
}
