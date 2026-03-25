import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppFAB extends StatefulWidget {
  final String phoneNumber;

  const WhatsAppFAB({super.key, required this.phoneNumber});

  @override
  State<WhatsAppFAB> createState() => _WhatsAppFABState();
}

class _WhatsAppFABState extends State<WhatsAppFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedBuilder(
        animation: _scale,
        builder: (context, child) => Transform.scale(
          scale: _hovering ? 1.15 : _scale.value,
          child: child,
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25D366).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: const Color(0xFF25D366),
            elevation: 0,
            onPressed: () => launchUrl(Uri.parse('https://wa.me/${widget.phoneNumber}')),
            tooltip: 'WhatsApp',
            child: const Icon(Icons.chat, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}
