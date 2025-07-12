import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MathText extends StatefulWidget {
  final String expression;
  final double? height; // Make height optional
  final double textSize; // Add text size parameter

  const MathText({
    super.key,
    required this.expression,
    this.height, // Optional height
    this.textSize = 24.0, // Default text size
  });

  @override
  State<MathText> createState() => _MathTextState();
}

class _MathTextState extends State<MathText> {

  late String _sanitized;
  double? _measuredHeight;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resanitizeAndMeasure();
  }

  @override
  void didUpdateWidget(covariant MathText old) {
    super.didUpdateWidget(old);
    if (old.expression != widget.expression ||
        old.textSize != widget.textSize) {
      _resanitizeAndMeasure();
    }
  }

  void _resanitizeAndMeasure() {
    _sanitized = sanitizeMathExpression(widget.expression);

    // build a TextPainter to measure
    final tp = TextPainter(
      text: TextSpan(
        text: _sanitized,
        style: TextStyle(fontSize: widget.textSize),
      ),
      textDirection: TextDirection.ltr,
      maxLines: null,
    );

    // assume we’ll use the full width of the parent:
    final maxWidth = MediaQuery.of(context).size.width;
    tp.layout(maxWidth: maxWidth);

    setState(() {
      _measuredHeight = tp.height;
    });
  }

  String sanitizeMathExpression(String input) {
    if(input.contains("matrix")||input.contains("vmatrix")) {
      return input
          .replaceAll(r'\\begin', r'\begin')
          .replaceAll(r'\\end', r'\end')
          .replaceAll(r'\\\\', r'\\')
          .replaceAll(r'$', r'')
          .replaceAll(r'\left[\begin', r'\(\left[\begin')
          .replaceAll(r'\right]', r'\right]\)')
          .replaceAll(r'z-[1', r'z_{1');
    } else {
      return input;
    }
  }

  @override
  Widget build(BuildContext context) {
    //final sanitizedExpression = sanitizeMathExpression(widget.expression);
    //final height = widget.height ?? _measuredHeight ?? widget.textSize * 1.2;

    // If you really want it a bit tighter than the raw measurement, subtract e.g. 8px:
    final dynamicHeight = (_measuredHeight ?? widget.textSize * 1.2);

    // choose how much to trim
    final trim = _sanitized.contains('matrix') ? 2.0 : 8.0;
    final extraForMatrix = _sanitized.contains(r'\begin{matrix}') ? 8.0 : 0.0;

// now compute your height
    final height = (dynamicHeight).clamp(widget.textSize, double.infinity);

    print('Using height $height');
// Never use widget.height here, only your measured value:
    //final height = dynamicHeight;//.clamp(widget.textSize, double.infinity);

    print("Using dynamic height $height");

    print("Height ${widget.height}");
    print("Text Size ${widget.textSize}");
    print("Measured Height ${_measuredHeight}");
    print("Calculated Height ${height}");
    return Container(
      padding: const EdgeInsets.only(top: 10.0),
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
