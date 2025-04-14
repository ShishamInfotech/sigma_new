import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathText extends StatelessWidget {
  final String expression;
  final double height;

  const MathText({super.key, required this.expression, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      child: AndroidView(
        viewType: 'mathview-native',
        layoutDirection: TextDirection.ltr,
        creationParams: {'expression': expression},
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}