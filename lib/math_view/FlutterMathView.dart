import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class FlutterMathView extends StatelessWidget {
  final String expression;
  final double textSize;
  final bool scrollable;

  const FlutterMathView({
    super.key,
    required this.expression,
    this.textSize = 24.0,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    final sanitized = _sanitizeExpression(expression);

    Widget mathWidget;
    try {
      mathWidget = Math.tex(
        sanitized,
        textStyle: TextStyle(fontSize: textSize),
      );
    } catch (e) {
      debugPrint("Math rendering failed: $e");
      mathWidget = const Text("⚠ Unable to render math expression");
    }

    final padded = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      child: mathWidget,
    );

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: padded,
      );
    } else {
      return padded;
    }
  }

  String _sanitizeExpression(String input) {
    input = input.trim();

    // Clean up common wrapping issues
    input = input
        .replaceAll(r'\\begin', r'\begin')
        .replaceAll(r'\\end', r'\end')
        .replaceAll(r'\\\\', r'\\')
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'\[', '')
        .replaceAll(r'\]', '')
        .replaceAll('\$', '')
        .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n');

    // Optional fix for known formatting glitches
    input = input.replaceAllMapped(RegExp(r'\s{3,}'), (_) => ' ');

    return input;
  }
}