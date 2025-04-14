import 'package:flutter/material.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/ui_helper/constant.dart';

class EasyQuestions extends StatefulWidget {
  final dynamic easyQuestion;
  const EasyQuestions({required this.easyQuestion, super.key});

  @override
  State<EasyQuestions> createState() => _EasyQuestionsState();
}

class _EasyQuestionsState extends State<EasyQuestions> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: /*Text(
            widget.easyQuestion["question"] ?? "Question not available",
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w300,
              color: primaryColor,
            ),
          ),*/
          MathText(expression: widget.easyQuestion["question"], height: estimateHeight(widget.easyQuestion["question"]),)
        ),
        if (widget.easyQuestion["options"] != null)
          ...List.generate(widget.easyQuestion["options"].length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(
                "${String.fromCharCode(65 + i)}. ${widget.easyQuestion["options"][i]}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: blackColor,
                ),
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
    final lines = (text.length / 30).ceil(); // assume 30 chars per line
    return lines * 40.0; // assume each line is about 40 pixels tall
  }
}