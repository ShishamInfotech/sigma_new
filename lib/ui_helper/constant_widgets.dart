import 'package:flutter/material.dart';
import 'package:sigma_new/models/mock_exam_table.dart';
import 'package:sigma_new/models/targetDatesModel.dart';

import 'constant.dart';

Widget infoCard({
  required String title,
  required String number,
  required Color color,
  required BuildContext context,
}) {
  double height = MediaQuery.of(context).size.height;
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25),
    ),
    height: height * 0.18,
    child: Card(
      elevation: 8,
      shadowColor: color,
      color: color,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: black12MediumTextStyle,
          ),
          Text(
            number,
            style: black24MediumTextStyle,
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
                const Text(
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
          SizedBox(
            height: height * 0.05,
            child: const VerticalDivider(
              color: primaryColor,
              thickness: 1,
              width: 20,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
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
          SizedBox(
            height: height * 0.05,
            child: const VerticalDivider(
              color: primaryColor,
              thickness: 1,
              width: 20,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
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
                const Text(
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
          SizedBox(
            height: height * 0.05,
            child: const VerticalDivider(
              color: primaryColor,
              thickness: 1,
              width: 20,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
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
          SizedBox(
            height: height * 0.05,
            child: const VerticalDivider(
              color: primaryColor,
              thickness: 1,
              width: 20,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                const Text(
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

Widget mockExamTable({
  required BuildContext context,
  required List<MockExamTable> examData, // Updated to accept the model list
}) {
  return Center(
    child: Card(
      elevation: 4,
      color: const Color(0xFFC5DEF2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          border: const TableBorder(
            verticalInside: BorderSide(
              color: primaryColor,
              width: 1,
            ),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(2),
            2: FlexColumnWidth(1.5),
          },
          children: [
            // Header Row
            TableRow(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              children: const [
                Text(
                  "Board Examination",
                  style: black12MediumTextStyle,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Examination Attempted",
                  style: black12MediumTextStyle,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Present Level",
                  style: black12MediumTextStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Data Rows
            ...examData.map(
              (data) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      data.boardExam ?? "",
                      style: primaryColor12MediumTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Text(
                    data.examsAttempted.toString(),
                    style: primaryColor12MediumTextStyle,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    data.level.toString(),
                    style: primaryColor12MediumTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget targetDatesTable({
  required BuildContext context,
  required List<TargetDatesModel> data,
}) {
  return Center(
    child: Card(
      elevation: 4,
      color: const Color(0xFFD9F3EB),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Table(
          border: const TableBorder(
            verticalInside: BorderSide(
              color: primaryColor,
              width: 1,
            ),
          ),
          columnWidths: const {
            0: FlexColumnWidth(2),
            1: FlexColumnWidth(3),
            2: FlexColumnWidth(1.5),
          },
          children: [
            TableRow(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    "Subject name",
                    style: black12MediumTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Text(
                  "Target dates",
                  style: black12MediumTextStyle,
                  textAlign: TextAlign.center,
                ),
                Text(
                  "Present status",
                  style: black12MediumTextStyle,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            // Data Rows
            ...data.map(
              (entry) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      entry.subjectName ?? "",
                      style: primaryColor12MediumTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        entry.targetDates ?? "",
                        style: primaryColor12MediumTextStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        decoration: BoxDecoration(
                          color: Colors.pink[50], // Light pink background
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${entry.daysRemaining.toString()} days remaining",
                          style: red12w400MediumTextStyle,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    entry.presentStatus.toString(),
                    style: primaryColor12MediumTextStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
