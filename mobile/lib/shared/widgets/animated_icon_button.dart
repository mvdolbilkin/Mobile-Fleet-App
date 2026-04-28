import 'package:flutter/material.dart';

class AnimatedIconButton extends StatefulWidget {
  final VoidCallback onTap;
  final Widget icon;
  final Color color;
  final Color? pressedColor;
  final double size;
  final double borderRadius;
  final Duration animationDuration;

  const AnimatedIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.color = const Color(0xFFFFD60A),
    this.pressedColor,
    this.size = 52,
    this.borderRadius = 12,
    this.animationDuration = const Duration(milliseconds: 150),
  });

  @override
  State<AnimatedIconButton> createState() => _AnimatedIconButtonState();
}

class _AnimatedIconButtonState extends State<AnimatedIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final pressedColor =
        widget.pressedColor ??
        Color.lerp(widget.color, Colors.black, 0.2) ??
        widget.color;

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedContainer(
        duration: widget.animationDuration,
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color: _isPressed ? pressedColor : widget.color,
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Center(child: widget.icon),
      ),
    );
  }
}
