import 'package:flutter/material.dart';

/// Widget reutilizable que anima su contenido al aparecer
/// Efecto: fade-in + slide-up con delay configurable
class AnimatedSection extends StatefulWidget {
  final Widget child;
  final int delayMs;
  final double slideOffset;

  const AnimatedSection({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.slideOffset = 40,
  });

  @override
  State<AnimatedSection> createState() => _AnimatedSectionState();
}

class _AnimatedSectionState extends State<AnimatedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: Offset(0, widget.slideOffset),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: _slide.value,
          child: child,
        ),
      ),
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

/// Card con efecto hover (scale + shadow) para web
class HoverScaleCard extends StatefulWidget {
  final Widget child;
  final double scale;
  final BorderRadius? borderRadius;
  final VoidCallback? onTap;

  const HoverScaleCard({
    super.key,
    required this.child,
    this.scale = 1.04,
    this.borderRadius,
    this.onTap,
  });

  @override
  State<HoverScaleCard> createState() => _HoverScaleCardState();
}

class _HoverScaleCardState extends State<HoverScaleCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(_hovering ? widget.scale : 1.0),
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _hovering ? 0.14 : 0.06),
                blurRadius: _hovering ? 24 : 8,
                offset: Offset(0, _hovering ? 12 : 2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
