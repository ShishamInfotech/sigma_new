import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathTextSplit extends StatelessWidget {
  final String expression;
  final double textSize;
  final String delimiter; // Default: <br>

  const MathTextSplit({
    super.key,
    required this.expression,
    this.textSize = 24.0,
    this.delimiter = '<br>',
  });

  String sanitize(String input) {
    return input
        .replaceAll(r'\\begin', r'\begin')
        .replaceAll(r'\\end', r'\end')
        .replaceAll(r'\\\\', r'\\')
        .replaceAll(r'$', r'')
        .replaceAll(r'\left[\begin', r'\(\left[\begin')
        .replaceAll(r'\right]', r'\right]\)')
        .replaceAll(r'z-[1', r'z_{1');
  }

  double estimateHeight(BuildContext context, String subExpr, double textSize) {
    //final withNewlines = subExpr.replaceAll(RegExp(r'<br\s*/?>', caseSensitive: true), '\n');

    final tp = TextPainter(
      text: TextSpan(
        text: subExpr,
        style: TextStyle(fontSize: textSize),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    final maxWidth = MediaQuery.of(context).size.width;
    tp.layout(maxWidth: maxWidth);

    final baseHeight = tp.height + 16.0; // padding for glyphs like subscripts/superscripts

    // Bonus: add weights for LaTeX commands
    final symbolBonus = {
      r'\frac': 12,
      r'\sum': 10,
      r'\int': 10,
      r'\\': 2,
      r'</': -4,
    };

    double extra = symbolBonus.entries.fold(0.0, (acc, entry) {
      return acc + RegExp(entry.key).allMatches(subExpr).length * entry.value;
    });

    return baseHeight + extra;
  }

  @override
  Widget build(BuildContext context) {
    final segments = expression.split(delimiter).where((e) => e.trim().isNotEmpty).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: segments.map((segment) {
        final subExpr = sanitize(segment);
        final height = estimateHeight(context, subExpr, textSize)
            .clamp(60.0, MediaQuery.of(context).size.height * 0.8);


        return Padding(
          padding: const EdgeInsets.only(bottom: 0.0),
          child: SizedBox(
            height: height,
            child: AndroidView(
              viewType: 'mathview-native',
              layoutDirection: TextDirection.ltr,
              creationParams: {
                'expression': subExpr,
                'textSize': textSize,
              },
              creationParamsCodec: const StandardMessageCodec(),
            ),
          ),
        );
      }).toList(),
    );
  }
}