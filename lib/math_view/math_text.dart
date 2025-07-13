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
    this.scrollable = false,
    this.maxLines,
  });

  @override
  State<MathText> createState() => _MathTextState();
}

class _MathTextState extends State<MathText> {
  late String _sanitized;
  double? _measuredHeight;
  double? _lastWidth;

  @override
  void initState() {
    super.initState();
    //_sanitized = _sanitizeExpression(widget.expression);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resanitizeAndMeasure();
  }

  @override
  void didUpdateWidget(covariant MathText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expression != widget.expression ||
        oldWidget.textSize != widget.textSize) {
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

      // assume we’ll use the full width of the parent:
      final maxWidth = MediaQuery.of(context).size.width;  // fallback if height is null
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
    final baseHeight = (_measuredHeight ?? widget.textSize * 1.2) + 15;

    // Count special characters for height adjustment
    final cmdCount = RegExp(r'\\').allMatches(_sanitized).length;
    final subCount = RegExp(r'<sub>').allMatches(_sanitized).length * 10;
    final iCount = RegExp(r'<i>').allMatches(_sanitized).length * 10;
    final dollarCount = RegExp(r'\$\$').allMatches(_sanitized).length * 22;
    final closingTagCount = RegExp(r'</').allMatches(_sanitized).length * 3;

    double extra = cmdCount * 2.0;
    if (_sanitized.contains('Delta')) extra -= 10;

    final calculatedHeight = baseHeight + extra + subCount + iCount + dollarCount - closingTagCount;

    // Get screen height in logical pixels
    final maxScreenHeight = ui.window.physicalSize.height / ui.window.devicePixelRatio;

    // Apply reasonable limits
    return min(calculatedHeight.clamp(widget.textSize, double.infinity), min(maxScreenHeight, 15000.0));
    //return calculatedHeight;
  }

  Widget _buildMathView(double height) {
    return SizedBox(
      height: height,
      child: AndroidView(
        viewType: 'mathview-native',
        layoutDirection: TextDirection.ltr,
        creationParams: {
          'expression': _sanitized,
          'textSize': widget.textSize,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final height = _calculateHeight();

    if (widget.scrollable) {
      return SingleChildScrollView(
        child: _buildMathView(height),
      );
    }

    return _buildMathView(height);
  }
}