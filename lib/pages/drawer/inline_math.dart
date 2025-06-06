import 'package:flutter/material.dart';

import '../../math_view/math_text.dart';

class InlineMathText extends StatelessWidget {
  final String expression;

  const InlineMathText({super.key, required this.expression});

  @override
  Widget build(BuildContext context) {
    // Estimate height based on screen size or keep fixed height
    final estimatedHeight = 30.0;

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: estimatedHeight,
      ),
      child: MathText(
        expression: expression,
        height: estimatedHeight,
      ),
    );
  }
}