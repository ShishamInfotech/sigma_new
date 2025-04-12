import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathText extends StatelessWidget {
  final String expression;

  const MathText({super.key, required this.expression});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: AndroidView(
        viewType: 'mathview-native',
        layoutDirection: TextDirection.ltr,
        creationParams: {'expression': expression},
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}