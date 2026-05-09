import 'package:flutter/material.dart';

class PulseBox extends StatefulWidget {
  final double? width;
  final double height;
  final double borderRadius;
  final Color color;

  const PulseBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius = 8,
    this.color = const Color(0xFFE6E5E2),
  });

  @override
  State<PulseBox> createState() => _PulseBoxState();
}

class _PulseBoxState extends State<PulseBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
      ),
    );
  }
}

class PulseRow extends StatelessWidget {
  final List<({double? width, double height, double radius, bool expand})> items;
  final double spacing;

  const PulseRow({super.key, required this.items, this.spacing = 8});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      final box = PulseBox(
        width: it.expand ? null : it.width,
        height: it.height,
        borderRadius: it.radius,
      );
      children.add(it.expand ? Expanded(child: box) : box);
      if (i < items.length - 1) children.add(SizedBox(width: spacing));
    }
    return Row(children: children);
  }
}
