import 'dart:math';
import 'package:flutter/material.dart';

class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double deltaX;
  final Curve curve;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.deltaX = 14,
    this.curve = Curves.easeInOut,
  });

  @override
  ShakeWidgetState createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void shake() {
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        // 4 tam salınım yapan sönümlü sinüs dalgası
        final offset = sin(progress * pi * 8) * widget.deltaX * (1.0 - progress);
        return Transform.translate(
          offset: Offset(offset, 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
