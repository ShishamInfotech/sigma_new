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
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      child: AndroidView(
        viewType: 'mathview-native',
        layoutDirection: TextDirection.ltr,
        creationParams: {'expression': widget.expression},
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}