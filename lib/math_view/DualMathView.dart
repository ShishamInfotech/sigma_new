import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';

class DualMathView extends StatefulWidget {
  final String expression;
  final double textSize;
  final bool scrollable;

  const DualMathView({
    super.key,
    required this.expression,
    this.textSize = 24.0,
    this.scrollable = true,
  });

  @override
  State<DualMathView> createState() => _DualMathViewState();
}

class _DualMathViewState extends State<DualMathView> {
  late List<_ExpressionFragment> fragments;

  @override
  void initState() {
    super.initState();
    fragments = _splitIntoParts(widget.expression);
  }

  @override
  void didUpdateWidget(covariant DualMathView oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.expression != widget.expression) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        setState(() {
          fragments = _splitIntoParts(widget.expression);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = fragments.map((part) {
      if (part.isLatex) {
        try {
          final sanitized = _sanitizeLatex(part.content);
          return Math.tex(
            sanitized,
            textStyle: TextStyle(fontSize: widget.textSize),
          );
        } catch (_) {
          return const Text("⚠ Invalid LaTeX");
        }
      } else {
        return Text(
          part.content.trim(),
          style: TextStyle(fontSize: widget.textSize - 4),
        );
      }
    }).toList();

    final column = Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );

    return widget.scrollable
        ? SingleChildScrollView(child: column)
        : column;
  }

  String _sanitizeLatex(String input) {
    return input
        .replaceAll(r'\(', '')
        .replaceAll(r'\)', '')
        .replaceAll(r'\[', '')
        .replaceAll(r'\]', '')
        .replaceAll('\$', '')
        .trim();
  }

  List<_ExpressionFragment> _splitIntoParts(String input) {
    final regex = RegExp(r'\\\(.+?\\\)|\\\[.+?\\\]|\$.*?\$');
    final matches = regex.allMatches(input);

    final List<_ExpressionFragment> fragments = [];
    int currentIndex = 0;

    for (final match in matches) {
      if (match.start > currentIndex) {
        fragments.add(_ExpressionFragment(
          content: input.substring(currentIndex, match.start),
          isLatex: false,
        ));
      }
      fragments.add(_ExpressionFragment(
        content: match.group(0) ?? '',
        isLatex: true,
      ));
      currentIndex = match.end;
    }

    if (currentIndex < input.length) {
      fragments.add(_ExpressionFragment(
        content: input.substring(currentIndex),
        isLatex: false,
      ));
    }

    return fragments;
  }
}

class _ExpressionFragment {
  final String content;
  final bool isLatex;

  _ExpressionFragment({required this.content, required this.isLatex});
}