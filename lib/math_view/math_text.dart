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

  double _height = 50.0;

  @override
  void initState() {
    super.initState();
    // Set up a method channel to receive height updates from native
    const MethodChannel('mathview_height_channel').setMethodCallHandler((call) async {
      if (call.method == 'updateHeight' && call.arguments is double) {
        setState(() {
          _height = call.arguments;
        });
      }
      return null;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: _height,
      child: AndroidView(
        viewType: 'mathview-native',
        layoutDirection: TextDirection.ltr,
        creationParams: {'expression': widget.expression},
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}