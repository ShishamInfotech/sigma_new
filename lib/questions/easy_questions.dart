import 'package:flutter/material.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class EasyQuestions extends StatefulWidget {
  final Map<String, dynamic> easyQuestion;
  final int? indexValue;

  const EasyQuestions({
    required this.easyQuestion,
    this.indexValue,
    super.key,
  });

  @override
  State<EasyQuestions> createState() => _EasyQuestionsState();
}

class _EasyQuestionsState extends State<EasyQuestions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "${widget.indexValue}. ",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Expanded(
                child: MathText(
                  key: ValueKey("q_${widget.indexValue}"),
                  expression: widget.easyQuestion["question"] ?? '',
                  height:  estimateHeight(widget.easyQuestion["question"]),
                ),
              ),
            ],
          ),
        ),

        // Options
        if (widget.easyQuestion["options"] != null)
          ...List.generate(widget.easyQuestion["options"].length, (i) {
            final opt = widget.easyQuestion["options"][i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${String.fromCharCode(65 + i)}. ",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: blackColor,
                    ),
                  ),
                  Expanded(
                    child: MathText(
                      key: ValueKey("opt_${widget.indexValue}_$i"),
                      expression: opt,
                      height: estimateOptionsHeight(opt),
                    ),
                  ),
                ],
              ),
            );
          }),

        const Divider(
          color: primaryColor,
          thickness: 1.5,
          indent: 5.0,
          endIndent: 5.0,
        ),
      ],
    );
  }

  double estimateHeight(String text) {
    if (text.isEmpty) return 0;

    // Count lines considering:
    // 1. Actual newlines
    // 2. Long lines that will wrap
    // 3. Math expressions that take more vertical space
    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    print("Lines="+ lines.toString() + "LongLines=" + longLines.toString());
    // Base height calculation
    double height = (lines + longLines) * 40.0;
    height = height * 3;
    // Add extra space for complex math expressions
    if (hasComplexMath) {
      height += 30.0;
    }

    // Minimum and maximum height constraints
    return height.clamp(50.0, 300.0); // Adjust max height as needed
  }

  double estimateOptionsHeight(String text) {
    if (text.isEmpty) return 0;

    // Count lines considering:
    // 1. Actual newlines
    // 2. Long lines that will wrap
    // 3. Math expressions that take more vertical space
    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt');

    print("Lines="+ lines.toString() + "LongLines=" + longLines.toString());
    // Base height calculation
    double height = (lines + longLines) * 10.0;
    //height = height * 2.5;
    // Add extra space for complex math expressions
    if (hasComplexMath) {
      height += 30.0;
    }

    // Minimum and maximum height constraints
    return height.clamp(50.0, 300.0); // Adjust max height as needed
  }
}