/// Uses fade animation to 'pulse'/'flicker' a widget.
/// [child] - Widget to apply pulse to
/// [duration] - Duration of pulse from low to bright and back to low (default: [Duration(milliseconds 1500)])
/// [tween] - Tween<double> of (0.0 to 1.0) for the pulse alpha (default: [Tween(begin: 0.25, end: 1.0)])
import 'package:flutter/material.dart';

typedef GWStringCallback(String value);

class GlowWidget extends StatefulWidget {
  final Tween<double>? tween;
  final Widget child;
  final Duration? duration;

  const GlowWidget({
    required this.child,
    this.duration,
    this.tween,
  });
  _GlowWidget createState() => _GlowWidget();
}

class _GlowWidget extends State<GlowWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation? _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 600));
    _animationController?.repeat(reverse: true);
    _animation = Tween(begin: 0.0, end: 4.0).animate(_animationController!)
      ..addListener(() {
        setState(() {});
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      child: widget.child,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.fromARGB(0, 27, 28, 30),
          boxShadow: [
            BoxShadow(
                color: Color.fromARGB(50, 0, 50, 200),
                blurRadius: _animation!.value,
                spreadRadius: _animation!.value)
          ]),
    );
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }
}
