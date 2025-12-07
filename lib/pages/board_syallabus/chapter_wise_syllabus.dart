import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/board_syallabus/topic_wise_syallabus.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

// add drawer import
import 'package:sigma_new/pages/drawer/drawer.dart';

class ChapterWiseSyllabus extends StatefulWidget {
  String? path;
  String? title;

  ChapterWiseSyllabus({this.path, this.title, super.key});

  @override
  _ChapterWiseSyllabusState createState() => _ChapterWiseSyllabusState();
}

class _ChapterWiseSyllabusState extends State<ChapterWiseSyllabus> {
  @override
  void initState() {
    super.initState();
    subjectWiseTest();
  }

  List<String> subjects = [];
  Map<String, List<Map<String, dynamic>>> groupedData = {};
  Map<String, List<Map<String, dynamic>>> groupedSubchapterQuestions = {};

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
    try {
      var newPath;
      var board;
      final prefs = await SharedPreferences.getInstance();
      String? boardPref = prefs.getString('board');
      board = (boardPref != null && boardPref == "Maharashtra")
          ? "MH/"
          : "${boardPref ?? ""}/";

      if (widget.path!.contains("10")) {
        newPath = "10/";
      } else if (widget.path!.contains("12")) {
        newPath = "12/";
      }

      var inputFile = await SdCardUtility.getSubjectEncJsonData(
          '${newPath}${board}${widget.path}.json');

      if (inputFile == null) {
        // handle missing file gracefully
        setState(() {});
        return;
      }

      Map<String, dynamic> parsedJson = jsonDecode(inputFile);

      List<Map<String, dynamic>> sigmaData =
      List<Map<String, dynamic>>.from(parsedJson["sigma_data"] ?? []);

      subjects = sigmaData.map((data) => data["subject"].toString()).toList();

      if (sigmaData.isNotEmpty) {
        // clear previous maps
        groupedData.clear();
        groupedSubchapterQuestions.clear();

        for (var item in sigmaData) {
          // group by subchapter_number for topic-wise questions
          final subchapterNumber = item["subchapter_number"]?.toString()?.trim()?.toLowerCase() ?? '';
          if (subchapterNumber.isNotEmpty) {
            groupedSubchapterQuestions.putIfAbsent(subchapterNumber, () => []);
            groupedSubchapterQuestions[subchapterNumber]!.add(Map<String, dynamic>.from(item));
          }

          // group by chapter_number for the chapter listing (avoid duplicates by subchapter)
          final chapterNumber = item["chapter_number"]?.toString()?.trim() ?? '';
          if (chapterNumber.isNotEmpty) {
            groupedData.putIfAbsent(chapterNumber, () => []);
            final exists = groupedData[chapterNumber]!.any((existingItem) =>
            (existingItem["subchapter_number"]?.toString()?.trim()?.toLowerCase() ?? '') ==
                (item["subchapter_number"]?.toString()?.trim()?.toLowerCase() ?? ''));
            if (!exists) {
              groupedData[chapterNumber]!.add(Map<String, dynamic>.from(item));
            }
          }
        }
      }

      setState(() {});
    } catch (e, st) {
      debugPrint('Error in subjectWiseTest: $e\n$st');
      setState(() {}); // still rebuild to show empty state
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      // attach your real drawer
      drawer: const DrawerWidget(),
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.chevron_right, size: 24),
            const SizedBox(width: 8),
            Text(
              "${widget.title}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.02, screenWidth * 0.05, screenHeight * 0.02),
          child: groupedData.isEmpty
              ? Center(
            child: subjects.isEmpty
                ? const CircularProgressIndicator()
                : const Text('No chapters found.'),
          )
              : ListView(
            children: groupedData.entries.map((entry) {
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
          ),
        ),
      ),
    );
  }

  void onSublistItemClick(Map<String, dynamic> item) {
    final String subchapterNumber =
        item["subchapter_number"]?.toString()?.trim()?.toLowerCase() ?? '';

    final questions = groupedSubchapterQuestions[subchapterNumber];

    if (questions != null && questions.isNotEmpty) {
      Get.to(() => TopicWiseSyllabus(pathQuestionList: questions, subjectId: item["subjectid"]));
    } else {
      // fallback: open topic page with just the single item
      Get.to(() => TopicWiseSyllabus(pathQuestionList: [item], subjectId: item["subjectid"]));
    }
  }
}
