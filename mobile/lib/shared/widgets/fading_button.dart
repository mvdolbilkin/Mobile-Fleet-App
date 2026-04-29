import 'package:flutter/material.dart';

class FadingButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedOpacity;
  final Duration duration;

  const FadingButton({
    super.key,
    required this.child,
    required this.onTap,
    this.pressedOpacity =
        0.4, // Насколько прозрачным становится (0.4 = 40% видимости)
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<FadingButton> createState() => _FadingButtonState();
}

class _FadingButtonState extends State<FadingButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedOpacity(
        duration: widget.duration,
        opacity: _isPressed ? widget.pressedOpacity : 1.0,
        child: widget.child,
      ),
    );
  }
}
