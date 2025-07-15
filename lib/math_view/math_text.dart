import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathText extends StatefulWidget {
  final String expression;
  final double? height;
  final double textSize;
  final bool scrollable;
  final int? maxLines;

  const MathText({
    super.key,
    required this.expression,
    this.height,
    this.textSize = 24.0,
    this.scrollable = true,
    this.maxLines,
  });

  @override
  State<MathText> createState() => _MathTextState();
}

class _MathTextState extends State<MathText> {
  late String _sanitized;
  double? _measuredHeight;

  @override
  void initState() {
    super.initState();
    _sanitized = sanitizeMathExpression(widget.expression);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resanitizeAndMeasure();
  }

  @override
  void didUpdateWidget(covariant MathText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expression != widget.expression || oldWidget.textSize != widget.textSize) {
      _resanitizeAndMeasure();
    }
  }

  void _resanitizeAndMeasure() {
    final withNewlines = widget.expression
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: true), '\n');

    _sanitized = sanitizeMathExpression(widget.expression);

    final tp = TextPainter(
      text: TextSpan(
        text: withNewlines,
        style: TextStyle(fontSize: widget.textSize),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    final maxWidth = MediaQuery.of(context).size.width;
    tp.layout(maxWidth: maxWidth);

    setState(() {
      _measuredHeight = tp.height;
    });
  }

  String sanitizeMathExpression(String input) {
    if (input.contains("matrix") || input.contains("vmatrix")) {
      return input
          .replaceAll(r'\\begin', r'\begin')
          .replaceAll(r'\\end', r'\end')
          .replaceAll(r'\\\\', r'\\')
          .replaceAll(r'$', r'')
          .replaceAll(r'\left[\begin', r'\(\left[\begin')
          .replaceAll(r'\right]', r'\right]\)')
          .replaceAll(r'z-[1', r'z_{1');
    }
    return input;
  }

  double _calculateHeight() {
    final baseHeight = (_measuredHeight ?? widget.textSize * 1.2) + 20;

    final patterns = {
      r'\\frac{': 38,
      r'\\sum': 8,
      r'\\int': 8,
      r'\$\$': 35,
      r'</': -4,
      r'<sub>': 10,
      r'<i>': 10,
      r'\\': 2,
    };

    double extra = patterns.entries.fold(0, (acc, entry) {
      final count = RegExp(entry.key).allMatches(_sanitized).length;
      return acc + (count * entry.value);
    });

    final screenHeight = MediaQuery.of(context).size.height;
    return min(baseHeight + extra, screenHeight * 4); // Cap at 4x screen height
  }

  bool _shouldScroll(double height, BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return height > maxHeight;
  }

  Widget _buildMathView(double height) {
    return SizedBox(
      height: height,
      child: Padding(
        padding: const EdgeInsets.only(top: 6.0), // You can adjust this value as needed
        child: AndroidView(
          viewType: 'mathview-native',
          layoutDirection: TextDirection.ltr,
          creationParams: {
            'expression': _sanitized,
            'textSize': widget.textSize,
          },
          creationParamsCodec: const StandardMessageCodec(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = _calculateHeight();
    final needsScroll = widget.scrollable || _shouldScroll(height, context);

    return needsScroll
        ? SingleChildScrollView(child: _buildMathView(height))
        : _buildMathView(height.clamp(0.0, MediaQuery.of(context).size.height * 0.9));
  }
}
