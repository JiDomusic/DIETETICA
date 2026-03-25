import 'package:flutter/material.dart';

class ManualTab extends StatelessWidget {
  const ManualTab({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFFF0A830);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primary, primary.withValues(alpha: 0.8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.menu_book_rounded, size: 48, color: Colors.white),
                    SizedBox(height: 12),
                    Text(
                      'Bienvenida al Panel de Admin',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Esta guía te explica paso a paso cómo configurar tu tienda.\n'
                      'No te preocupes, es muy fácil y no podés romper nada.',
                      style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // AVISO IMPORTANTE: datos demo
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_rounded, color: primary, size: 24),
                        const SizedBox(width: 10),
                        Text('Lo primero que tenés que saber',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Tu tienda viene con DATOS DE EJEMPLO (productos, fotos, precios, sucursales). '
                      'Estos datos son inventados para que veas cómo queda la web con contenido.\n\n'
                      'Tenés dos opciones:\n'
                      '1. Ir reemplazando los datos de ejemplo por los tuyos reales (editando cada producto, sucursal, etc.)\n'
                      '2. Borrar TODO de una vez desde Config > "Datos de Ejemplo" y empezar de cero\n\n'
                      'Recomendamos la opción 1: andá editando de a poco así no te queda la web vacía.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Paso a paso
              const Text('Paso a paso: configurá tu tienda',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E))),
              const SizedBox(height: 4),
              const Text('Seguí estos pasos en orden y en 15 minutos tenés tu web lista.',
                style: TextStyle(fontSize: 14, color: Color(0xFF777777))),
              const SizedBox(height: 20),

              _StepCard(
                step: 1,
                color: primary,
                icon: Icons.settings_rounded,
                title: 'Config: poné el nombre de tu tienda',
                items: const [
                  'Andá a la pestaña "Config" (el engranaje).',
                  'En "Nombre del sitio" escribí el nombre real de tu dietética.',
                  'Completá tu WhatsApp (con código de país, ej: 5493411234567).',
                  'Poné tus redes sociales (Instagram, Facebook).',
                  'Si recibís pagos por transferencia, completá CBU y Alias.',
                  'Tocá "Guardar Cambios" al final.',
                ],
              ),

              _StepCard(
                step: 2,
                color: const Color(0xFF9C27B0),
                icon: Icons.palette_rounded,
                title: 'Config: elegí los colores de tu marca',
                items: const [
                  'En la misma pestaña Config, bajá hasta "Colores de tu Marca".',
                  'Tocá cada círculo de color para abrir la rueda de colores.',
                  'Elegí los colores que te representen (se aplican en toda la web).',
                  'Abajo ves una vista previa de cómo quedan los botones.',
                  'No te olvides de guardar.',
                ],
              ),

              _StepCard(
                step: 3,
                color: const Color(0xFF4CAF50),
                icon: Icons.inventory_2_rounded,
                title: 'Productos: reemplazá los de ejemplo',
                items: const [
                  'Andá a la pestaña "Productos".',
                  'Vas a ver productos de ejemplo (Almendras, Granola, etc.). Son inventados.',
                  'Tocá el lápiz (editar) en cualquier producto para cambiarle nombre, precio, foto y descripción.',
                  'Para subir una foto, tocá "Elegir imagen" y seleccioná una foto de tu compu (JPG o PNG).',
                  'Para agregar un producto nuevo, tocá "+ Nuevo Producto" arriba a la derecha.',
                  'Para borrar un producto, tocá el tacho rojo.',
                  'Podés marcar productos como "Nuevo", "Promo" o "Destacado" con los switches.',
                ],
              ),

              _StepCard(
                step: 4,
                color: const Color(0xFF2196F3),
                icon: Icons.warehouse_rounded,
                title: 'Stock: poné las cantidades reales',
                items: const [
                  'Andá a la pestaña "Stock".',
                  'Acá ves cuántas unidades tenés de cada producto en cada sucursal.',
                  'Usá los botones + y - para ajustar cantidades rápido.',
                  'O tocá el lápiz para poner un número exacto.',
                  'Si un producto llega a 0, en la web aparece "Sin Stock" automáticamente.',
                  'Los clientes no pueden reservar productos sin stock.',
                ],
              ),

              _StepCard(
                step: 5,
                color: const Color(0xFFE91E63),
                icon: Icons.local_offer_rounded,
                title: 'Promos: creá ofertas',
                items: const [
                  'Andá a la pestaña "Promos".',
                  'Tocá "+ Nueva Promo" para crear una oferta.',
                  'Elegí el producto, poné el % de descuento o un precio especial.',
                  'Agregá un texto como "Llevá 2x1" o "Solo esta semana".',
                  'Las promos aparecen en un carrusel especial en la web.',
                  'Podés desactivar una promo sin borrarla (con el switch).',
                ],
              ),

              _StepCard(
                step: 6,
                color: const Color(0xFF607D8B),
                icon: Icons.store_rounded,
                title: 'Sucursales: poné tus locales',
                items: const [
                  'Andá a la pestaña "Sucursales".',
                  'Editá las sucursales de ejemplo con la dirección real de tu local.',
                  'Completá teléfono, WhatsApp y horario de atención.',
                  'Subí una foto de tu local (se ve en la web).',
                  'Si tenés un solo local, borrá las sucursales de más.',
                ],
              ),

              _StepCard(
                step: 7,
                color: const Color(0xFF9C27B0),
                icon: Icons.photo_library_rounded,
                title: 'Galería: mostrá tu local',
                items: const [
                  'Andá a la pestaña "Galería".',
                  'Subí fotos lindas de tu local, productos, equipo de trabajo.',
                  'Estas fotos se muestran en un carrusel en la web.',
                  'Poneles un título y descripción cortita.',
                ],
              ),

              _StepCard(
                step: 8,
                color: const Color(0xFFFF5722),
                icon: Icons.play_circle_rounded,
                title: 'Videos: opcional pero lindo',
                items: const [
                  'Si tenés videos en YouTube (recetas, tips, etc.), podés agregarlos.',
                  'Pegá el link del video y poné título y descripción.',
                  'Los videos se muestran en la web para que tus clientes los vean.',
                ],
              ),

              _StepCard(
                step: 9,
                color: primary,
                icon: Icons.home_rounded,
                title: 'Home: organizá las secciones',
                items: const [
                  'Andá a la pestaña "Home".',
                  'Acá elegís qué secciones se ven en tu web y en qué orden.',
                  'Podés activar/desactivar secciones (ej: si no querés videos, desactivalo).',
                  'Editá los banners principales con fotos grandes y texto promocional.',
                  'Los banners son las imágenes grandes que se ven al entrar a la web.',
                ],
              ),

              const SizedBox(height: 28),

              // Sección de cosas útiles
              _ManualSection(
                icon: Icons.shopping_bag_rounded,
                color: const Color(0xFF795548),
                title: 'Reservas (se gestionan solas)',
                items: const [
                  'Cuando un cliente reserva un producto desde la web, aparece acá.',
                  'Ves el nombre del producto, cantidad, datos del cliente y fecha.',
                  'Podés marcar la reserva como "Pagada" o "Retirada".',
                  'Si cancelás una reserva, el stock se devuelve automáticamente.',
                  'No tenés que hacer nada especial, solo revisar de vez en cuando.',
                ],
              ),

              _ManualSection(
                icon: Icons.analytics_rounded,
                color: const Color(0xFF00BCD4),
                title: 'Analytics (mirá cómo te va)',
                items: const [
                  'Acá ves estadísticas: productos más vistos, movimientos de stock.',
                  'Te avisa si algún producto tiene stock bajo (se está por acabar).',
                  'Podés filtrar por sucursal y por período (7, 30 o 90 días).',
                  'Usá esta info para saber qué reponer y qué productos gustan más.',
                ],
              ),

              const SizedBox(height: 24),

              // Botón de ver tienda
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FFF0),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.3)),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.visibility_rounded, color: Color(0xFF4CAF50), size: 32),
                    SizedBox(height: 8),
                    Text('Para ver cómo queda tu tienda',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
                    SizedBox(height: 4),
                    Text(
                      'Tocá el ícono del OJO en la barra de arriba (al lado de tu nombre).\n'
                      'Se abre tu web tal como la ven los clientes.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF555555), height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Tips
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: primary.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_rounded, color: primary, size: 22),
                        const SizedBox(width: 8),
                        Text('Consejos', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: primary)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const _TipItem(text: 'Las fotos quedan mejor si son cuadradas (misma altura y ancho).'),
                    const _TipItem(text: 'Usá fotos reales, no de internet. Los clientes confían más.'),
                    const _TipItem(text: 'Actualizá el stock seguido para no decepcionar a nadie.'),
                    const _TipItem(text: 'Si algo no te gusta, editalo. Todo se puede cambiar.'),
                    const _TipItem(text: 'Los cambios se ven al instante en la web (no hace falta esperar).'),
                    const _TipItem(text: 'Si te equivocás, no pasa nada. Editá de nuevo o borrá y creá otro.'),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final int step;
  final Color color;
  final IconData icon;
  final String title;
  final List<String> items;

  const _StepCard({
    required this.step,
    required this.color,
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(child: Text('$step', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
                const SizedBox(width: 12),
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)))),
              ],
            ),
            const SizedBox(height: 14),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.5)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ManualSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final List<String> items;

  const _ManualSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0F0F0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
              ],
            ),
            const SizedBox(height: 14),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      width: 6, height: 6,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.5)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 14, color: Color(0xFF444444), height: 1.5)),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _TipItem extends StatelessWidget {
  final String text;
  const _TipItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.check_circle, size: 16, color: Color(0xFFF0A830)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Color(0xFF555555), height: 1.4))),
        ],
      ),
    );
  }
}
