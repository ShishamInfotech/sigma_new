import 'package:flutter/material.dart';

import 'constant.dart';

Widget infoCard({
  required String title,
  required String number,
  required Color color,
  required BuildContext context,
}) {
  double height = MediaQuery.of(context).size.height;
  return Card(
    elevation: 8,
    shadowColor: color,
    color: color,
    child: Padding(
      padding: EdgeInsets.symmetric(
        vertical: height * 0.02,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: black12MediumTextStyle,
          ),
          Text(
            number,
            style: black44MediumTextStyle,
          ),
        ],
      ),
    ),
  );
}

Widget mockExamCard(
    {required String subjectName,
    required String level,
    required String topScore,
    required Color color,
    required BuildContext context}) {
  double height = MediaQuery.of(context).size.height;
  return Card(
    elevation: 5,
    color: color,
    shadowColor: color,
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "Subject name",
                  style: black12MediumTextStyle,
                ),
                Text(
                  subjectName,
                  style: primaryColor12MediumTextStyle,
                ),
              ],
            ),
          ),
          Container(
            height: height * 0.05,
            child: VerticalDivider(
              color: primaryColor,
              thickness: 1,
              width: 20,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Level",
                  style: black12MediumTextStyle,
                ),
                Text(
                  level,
                  style: primaryColor12MediumTextStyle,
                ),
              ],
            ),
          ),
          Container(
            height: height * 0.05,
            child: VerticalDivider(
              color: primaryColor,
              thickness: 1,
              width: 20,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Top score",
                  style: black12MediumTextStyle,
                ),
                Text(
                  topScore,
                  style: primaryColor12MediumTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget evaluationCard(
    {required String subject,
    required String level,
    required String score,
    required int color,
    required BuildContext context}) {
  double height = MediaQuery.of(context).size.height;
  return Card(
    elevation: 5,
    color: Color(color),
    shadowColor: Color(color),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Column(
              children: [
                Text(
                  "Subject name",
                  style: black12MediumTextStyle,
                ),
                Text(
                  subject,
                  style: primaryColor12MediumTextStyle,
                ),
              ],
            ),
          ),
          Container(
            height: height * 0.05,
            child: VerticalDivider(
              color: primaryColor,
              thickness: 1,
              width: 20,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Level",
                  style: black12MediumTextStyle,
                ),
                Text(
                  level,
                  style: primaryColor12MediumTextStyle,
                ),
              ],
            ),
          ),
          Container(
            height: height * 0.05,
            child: VerticalDivider(
              color: primaryColor,
              thickness: 1,
              width: 20,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  "Top score",
                  style: black12MediumTextStyle,
                ),
                Text(
                  score,
                  style: primaryColor12MediumTextStyle,
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
