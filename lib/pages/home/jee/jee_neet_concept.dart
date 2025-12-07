import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sigma_new/pages/board_syallabus/topic_wise_syallabus.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

// attach your real Drawer implementation
import 'package:sigma_new/pages/drawer/drawer.dart';

class JeeNeetConcept extends StatefulWidget {
  final String subjectId;
  final String? complexity;
  final String? title;

  JeeNeetConcept({required this.subjectId, this.complexity, this.title, super.key});

  @override
  State<JeeNeetConcept> createState() => _JeeNeetConceptState();
}

class _JeeNeetConceptState extends State<JeeNeetConcept> {
  List<String> subjects = [];
  List<String> complexitySubject = [];
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  Map<String, List<Map<String, dynamic>>> groupedSubchapterQuestions = {};

  @override
  void initState() {
    super.initState();
    subjectWiseTest();
  }

  String removeTestSeriesFromSubjectTitle(String title) {
    if (title.toLowerCase().contains("test series")) {
      List<String> parts = title.split("-");
      if (parts.length > 1) {
        return "Board Mock Exam - ${parts[1].trim()}";
      }
    }
    return title;
  }

  Future<void> subjectWiseTest() async {
    final inputFile = await SdCardUtility.getSubjectEncJsonData('JEE/THEORY/${widget.subjectId}.json');

    if (inputFile == null) {
      debugPrint("Error: No data found for ${widget.subjectId}!");
      return;
    }

    Map<String, dynamic> parsedJson = jsonDecode(inputFile);
    List<Map<String, dynamic>> sigmaData = List<Map<String, dynamic>>.from(parsedJson["sigma_data"] ?? []);

    // Filter by complexity if provided
    if (widget.complexity != null) {
      sigmaData = sigmaData.where((item) {
        return item["complexity"]?.toString().toLowerCase() == widget.complexity!.toLowerCase();
      }).toList();
    }

    subjects = sigmaData.map((data) => data["subject"].toString()).toList();

    groupedSubchapterQuestions.clear();
    groupedData.clear();

    for (var item1 in sigmaData) {
      final subchapterNumber = item1["subchapter_number"]?.toString()?.trim()?.toLowerCase() ?? '';
      if (subchapterNumber.isNotEmpty) {
        groupedSubchapterQuestions.putIfAbsent(subchapterNumber, () => []);
        groupedSubchapterQuestions[subchapterNumber]!.add(Map<String, dynamic>.from(item1));
      }
    }

    for (var item in sigmaData) {
      final chapterNumber = item["chapter_number"]?.toString()?.trim() ?? '';
      if (chapterNumber.isNotEmpty) {
        groupedData.putIfAbsent(chapterNumber, () => []);
        final alreadyExists = groupedData[chapterNumber]!.any((existingItem) =>
        (existingItem["subchapter_number"]?.toString()?.trim()?.toLowerCase() ?? '') ==
            (item["subchapter_number"]?.toString()?.trim()?.toLowerCase() ?? ''));
        if (!alreadyExists) {
          groupedData[chapterNumber]!.add(Map<String, dynamic>.from(item));
        }
      }
    }

    setState(() {});
  }

  void onSublistItemClick(Map<String, dynamic> item) {
    final String subchapterNumber = item["subchapter_number"]?.toString()?.trim()?.toLowerCase() ?? '';

    final questions = groupedSubchapterQuestions[subchapterNumber];

    if (questions != null && questions.isNotEmpty) {
      Get.to(() => TopicWiseSyllabus(pathQuestionList: questions, subjectId: item["subjectid"]));
    } else {
      Get.to(() => TopicWiseSyllabus(pathQuestionList: [item], subjectId: item["subjectid"]));
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    debugPrint("title ${widget.title}");

    return Scaffold(
      backgroundColor: Colors.white,
      // attach the real Drawer
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.chevron_right, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "${widget.title ?? ''}",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        leading: Builder(builder: (context) {
          return IconButton(
            icon: const Icon(Icons.menu, size: 28),
            onPressed: () => Scaffold.of(context).openDrawer(),
          );
        }),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.02, screenWidth * 0.05, screenHeight * 0.03),
          child: ListView(
            children: [
              if (widget.complexity != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  // child: Text(
                  //   'Filtering by complexity: ${widget.complexity}',
                  //   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey),
                  // ),
                ),
              if (groupedData.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                ...groupedData.entries.map((entry) {
                  final chapterKey = entry.key;
                  final chapterTitle = entry.value.isNotEmpty ? entry.value[0]["chapter"]?.toString() ?? '' : '';
                  return ExpansionTile(
                    title: Text(
                      "$chapterKey: $chapterTitle",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    children: entry.value.map((item) {
                      final subchapterNumber = item["subchapter_number"]?.toString() ?? '';
                      final subchapterTitle = item["subchapter"]?.toString() ?? 'No Subchapter';
                      return ListTile(
                        title: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            "$subchapterNumber: $subchapterTitle",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.grey),
                        onTap: () => onSublistItemClick(item),
                      );
                    }).toList(),
                  );
                }).toList(),
            ],
          ),
        ),
      ),
    );
  }
}
