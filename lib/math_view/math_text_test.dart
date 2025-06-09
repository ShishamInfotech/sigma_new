import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class MathTextTest extends StatefulWidget {
  final String expression;
  final double initialHeight;
  final void Function(double height)? onHeightChanged;

  const MathTextTest({
    super.key,
    required this.expression,
    this.initialHeight = 10,
    this.onHeightChanged,
  });

  @override
  State<MathTextTest> createState() => _MathTextTestState();
}

class _MathTextTestState extends State<MathTextTest> {
  late double _height;

  static const _channel = MethodChannel("mathview/height");

  @override
  void initState() {
    super.initState();
    _height = widget.initialHeight;

    _channel.setMethodCallHandler((call) async {
      if (call.method == "onHeightCalculated") {
        final newHeight = (call.arguments as int).toDouble().clamp(50.0, 1000.0);
        if (newHeight != _height) {
          setState(() => _height = newHeight);
          widget.onHeightChanged?.call(newHeight);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: AndroidView(
        viewType: 'mathview-native',
        creationParams: {'expression': widget.expression},
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
