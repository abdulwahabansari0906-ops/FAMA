import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class Loader extends StatelessWidget {
  final Color color;
  final double size;
  final double strokeWidth;

  const Loader({super.key, this.color = Colors.yellow, this.size = 50.0,
    this.strokeWidth=2});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SpinKitFadingCircle(
        color: color,
        size: size,
      ),
    );
  }
}