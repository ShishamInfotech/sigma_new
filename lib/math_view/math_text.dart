import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathText extends StatefulWidget {
  final String expression;
  final double height;

  const MathText({super.key, required this.expression, required this.height});

  @override
  State<MathText> createState() => _MathTextState();
}

class _MathTextState extends State<MathText> {
  String sanitizeMathExpression(String input) {

    return input
        .replaceAll(r'\\begin', r'\begin')
        .replaceAll(r'\\end', r'\end')
        .replaceAll(r'\\\\', r'\\')
        .replaceAll(r'$', r'')
        .replaceAll(r'\left[\begin', r'\(\left[\begin')
        .replaceAll(r'\right]', r'\right]\)')
        .replaceAll(r'z-[1', r'z_{1');
  }

  @override
  Widget build(BuildContext context) {
    final sanitizedExpression = sanitizeMathExpression(widget.expression);
    return Container(
      height: widget.height,
      child: AndroidView(
        viewType: 'mathview-native',
        layoutDirection: TextDirection.ltr,
        creationParams: {
          'expression': sanitizedExpression,
          'textSize': 24.0,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
