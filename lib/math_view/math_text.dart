import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'dart:developer' as ld;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

class MathText extends StatefulWidget {
  final String expression;
  final double? height;
  final double textSize;
  final bool scrollable;
  final int? maxLines;
  String? basePath;


  MathText({
    super.key,
    required this.expression,
    this.height,
    this.textSize = 24.0,
    this.scrollable = true,
    this.maxLines,
    this.basePath,
  });

  @override
  State<MathText> createState() => _MathTextState();
}

class _MathTextState extends State<MathText> with AutomaticKeepAliveClientMixin{
  late String _sanitized;
  double? _measuredHeight;

  @override
  bool get wantKeepAlive => true;

  double? _imageHeightSum;

  @override
  void initState() {
    super.initState();
    _sanitized = sanitizeMathExpression(widget.expression);
    loadImageHeights(_sanitized);
  }

  Future<void> loadImageHeights(String input) async {
    double sum = await _getSumOfImageHeights(input);
    setState(() {
      _imageHeightSum = sum;
    });
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resanitizeAndMeasure();
  }

  @override
  void didUpdateWidget(covariant MathText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expression != widget.expression || oldWidget.textSize != widget.textSize || widget.expression != '0') {
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

    //debugPrint("Matrix Test================   $input");
    input = input.trim();

    if(input.contains("img src")){
      print("getBasepath ${widget.basePath}");
      input = input.replaceAll("/sigma", widget.basePath!).replaceAll("style= width : 100px/", "style=\"width: 450px; height: auto;\"");
      print("After Image $input");
    }



    if (input.contains("matrix") || input.contains("vmatrix")) {
      print("Matrix Test================   $input");
      input= input
          .replaceAll(r'\\begin', r'\begin')
          .replaceAll(r'\\end', r'\end')
          .replaceAll(r'\\\\', r'\\')
          .replaceAll(r'$', r'')
      .replaceAll(r'\left[\begin', r'\(\left[\begin')
       .replaceAll(r'\right]', r'\right]\)')
          .replaceAll(r'z-[1', r'z_{1');
    }

    input = input.replaceAll(',br>', '<br>').replaceAllMapped(RegExp(r'<br\s*/?>'), (_) => '\n');

    return input;
  }


  Future<double> _getSumOfImageHeights(String input) async {
    double totalHeight = 0;

    try {
      dom.Document document = html_parser.parse(input);
      var imgElements = document.getElementsByTagName('img');

      for (var img in imgElements) {
        String? style = img.attributes['style'];
        String? src = img.attributes['src'];

        if (src != null) {
          Size intrinsicSize = await getImageSizeFromFile(src);

          double renderedWidth = 100; // default fallback width
          if (style != null) {
            var widthMatch = RegExp(r'width\s*:\s*([0-9]+)px').firstMatch(style);
            if (widthMatch != null) {
              renderedWidth = double.tryParse(widthMatch.group(1)!) ?? renderedWidth;
            }
          }

          if (intrinsicSize != Size.zero && intrinsicSize.width > 0) {
            // Scale height to match rendered width while keeping aspect ratio
            double scaledHeight = intrinsicSize.height * (renderedWidth / intrinsicSize.width);
            totalHeight += scaledHeight;
          } else {
            totalHeight += 100; // fallback
          }
        } else {
          totalHeight += 100; // fallback
        }
      }
    } catch (e) {
      print("Error parsing images for height: $e");
    }
    return totalHeight;
  }


  Future<Size> getImageSizeFromFile(String fileUri) async {
    try {
      String filePath = Uri.parse(fileUri).toFilePath();

      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final completer = Completer<ui.Image>();
      ui.decodeImageFromList(bytes, (ui.Image img) {
        completer.complete(img);
      });

      ui.Image image = await completer.future;
      return Size(image.width.toDouble(), image.height.toDouble());
    } catch (e) {
      print('Error loading local image: $e');
      return Size.zero;
    }
  }


  double _calculateHeight() {

    if (_sanitized.isEmpty || widget.textSize <= 0) {
      return 100.0; // Default safe height
    }


    var baseHeight = (_measuredHeight ?? widget.textSize * 1.2) + 20;

    final patterns = {
      // Existing
      r'\frac{': 38,
      r'\\sum': 8,
      r'\\int': 8,
      r'\$\$': 35,
      r'</': -4,
      r'<sub>': 10,
      r'<i>': 10,
      r'<p>':20,
      r'\\': 2,
      r'<table': 10,
      r'<tr>':5,
      r'&nbsp;':25,
      r'\(': 6,
      // From Excel content
      r'\\propto': 10,
      r'n_1': 8,
      r'n_2': 8,
      r'T_n': 10,
      r'<br>': 15,
      //r'<img': 85,

      // LaTeX text-size affecting commands
      r'\\Huge': 25,
      r'\\huge': 20,
      r'\\LARGE': 18,
      r'\\Large': 15,
      r'\\large': 12,
      r'\\small': 5,
      r'\\tiny': 2,
      r'\omega':-5
    };

    if(_sanitized.length > 60 && patterns.containsKey(r'\(')){
      baseHeight = baseHeight+10 ;
    }
    if(_sanitized.length > 40) {
      baseHeight = baseHeight + 10;
    }
    double extra = patterns.entries.fold(0, (acc, entry) {
      final count = RegExp(entry.key).allMatches(_sanitized).length;
      return acc + (count * entry.value);
    });

    // Add height from images parsed from sanitized string
    //double imageHeightSum = _getSumOfImageHeights(_sanitized);




    final screenHeight = MediaQuery.of(context).size.height;
    return min(baseHeight + extra, screenHeight * 5); // Cap at 4x screen height
  }

  bool _shouldScroll(double height, BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.75;
    return height > maxHeight;
  }

  Widget _buildMathView(double height) {
    print("Data Contex ===============$_sanitized");
    final isMatrix = _sanitized.contains(r'\begin{matrix}') ||
        _sanitized.contains(r'\begin{pmatrix}') ||
        _sanitized.contains(r'\begin{vmatrix}') ||
        _sanitized.contains(r'\begin{bmatrix}');

    //final topPadding = isMatrix ? .0 : 6.0; // add extra space for matrix top line
    height = isMatrix ? height + 37.0 : height;
    print("Data Contex Height ===============$height");
    return SizedBox(
      height: height,
      child: Padding(
        padding: EdgeInsets.only(top: 6), // You can adjust this value as needed
        child: RepaintBoundary(
          child: AndroidView(
            viewType: 'mathview-native',
            layoutDirection: TextDirection.ltr,
            creationParams: {
              'expression': _sanitized.isNotEmpty ? _sanitized : '1+1',
              'textSize': widget.textSize,
            },
            creationParamsCodec: const StandardMessageCodec(),
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //print("Data ==============="+ widget.expression);

    if (widget.expression.isEmpty) {
      return const SizedBox(
        height: 10,
        child: Center(
          child: Text(
            " ",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final height = _calculateHeight() + ((_imageHeightSum ?? 0));

    final needsScroll = widget.scrollable || _shouldScroll(height, context);
    // ✅ Avoid building AndroidView until height is known
    if (_measuredHeight == null || height == 0) {
      return const SizedBox(height: 40); // Placeholder
    }

    return needsScroll
        ? SingleChildScrollView(child: _buildMathView(height))
        : _buildMathView(height.clamp(0.0, MediaQuery.of(context).size.height * 0.9));
  }
}
