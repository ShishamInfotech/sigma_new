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
  if(input.contains("matrix")) {
    return input
        .replaceAll(r'\\begin', r'\begin')
        .replaceAll(r'\\end', r'\end')
        .replaceAll(r'\\\\', r'\\')
        .replaceAll(r'$', r'')
        .replaceAll(r'\left[\begin', r'\(\left[\begin')
        .replaceAll(r'\right]', r'\right]\)')
        .replaceAll(r'z-[1', r'z_{1');
  }else{
    return input;
  }
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
          'expression': sanitizedExpression,//widget.expression,
          'textSize': 24.0,
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}


/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathText extends StatefulWidget {
  final String expression;
   double? height;

  MathText({super.key, required this.expression,this.height});

  @override
  State<MathText> createState() => _MathTextState();
}

class _MathTextState extends State<MathText> {
  double _height = 10;
  static const _channel = MethodChannel("mathview/height");

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler((call) async {
      if (call.method == "onHeightCalculated") {
        final newHeight = (call.arguments as int).toDouble();
        print("New Height $newHeight");
        setState(() {
          _height = newHeight.clamp(50.0, 1000.0);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: ValueKey(widget.expression),
      margin: const EdgeInsets.all(16), // equivalent to android:layout_margin
      padding: const EdgeInsets.all(10), // equivalent to android:padding
      width: double.infinity, // match_parent

      child: SizedBox(
        height: _height,
        child: AndroidView(
          viewType: 'mathview-native',
          creationParams: {'expression': widget.expression},
          creationParamsCodec: const StandardMessageCodec(),
        ),
      ),
    );
  }
}
*/
