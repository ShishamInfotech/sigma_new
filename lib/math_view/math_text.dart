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
        .replaceAll(r'\left[\begin{matrix}', r'$$ \begin{bmatrix}')
        .replaceAll(r'\end{matrix}\right]', r'\end{bmatrix} $$')
        .replaceAll(r'\end{matrix} \right]', r'\end{bmatrix} $$')
        .replaceAll(r'\end{matrix}  \right]', r'\end{bmatrix} $$')
        .replaceAll(r'\end{matrix} \begin{matrix}', r'\end{matrix}, \quad \begin{matrix}')
        .replaceAll(r'\(', r'$')                      // Replace \( with $
        .replaceAll(r'\)', r'$')
        .replaceAll(r'}$,', r'},')      // Replace \) with $
        .replaceAll(r' $\ ', r' \quad ')
        .replaceAll(r'=$\begin{bmatrix}', r'= \begin{bmatrix}')
        .replaceAll(r'$A', r'$$ A')
        .replaceAll(r'$B', r'$$ B')
        .replaceAll(r'\\\', r'\\');
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
