import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/board_syallabus/topic_wise_syallabus.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/ui_helper/constant.dart';

// <-- add this import to use your existing drawer implementation
import 'package:sigma_new/pages/drawer/drawer.dart';

class LastMinuteRevision extends StatefulWidget {
  final String? path;
  const LastMinuteRevision({super.key, this.path});

  @override
  State<LastMinuteRevision> createState() => _LastMinuteRevisionState();
}

class _LastMinuteRevisionState extends State<LastMinuteRevision> {
  final List<Color> cardColors = [
    const Color(0xFFDBCDF0),
    const Color(0xFFF2C6DF),
    const Color(0xFFC9E4DF),
    const Color(0xFFF8D9C4),
  ];

  Map<String, Map<String, Map<String, List<Map<String, dynamic>>>>> structuredData = {};
  List<bool> isExpanded = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _totalBookmarkedQuestions = 0;

  // Scaffold key to open the drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    loadStructuredBookmarks();
  }

  Future<void> loadStructuredBookmarks() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
        _totalBookmarkedQuestions = 0;
        structuredData = {};
      });

      final prefs = await SharedPreferences.getInstance();
      final List<String>? bookmarkedIds = prefs.getStringList('bookmarks');

      print('Bookmarked IDs from storage: ${bookmarkedIds}');

      if (bookmarkedIds == null || bookmarkedIds.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No bookmarks found. Please bookmark some questions first.';
        });
        return;
      }

      print("Last Minute ${widget.path}");
      print("Last Minute Board${prefs.getString('board')}");
      String? boardPref = prefs.getString('board');

      String board = (widget.path?.contains("10") == true || widget.path?.contains("12") == true)
          ? (boardPref == "Maharashtra" ? "MH/" : "${boardPref ?? ""}/")
          : "";
      String newPath = widget.path?.contains("10") == true
          ? "10/"
          : widget.path?.contains("12") == true
          ? "12/"
          : "JEE/THEORY/";
      String sigmaDataPath = '${newPath}${board}sigma_data.json';

      // Step 1: Load sigma_data.json to get subject mappings
      final sigmaDataFile = await SdCardUtility.getSubjectEncJsonData(sigmaDataPath);
      if (sigmaDataFile == null) throw Exception('Failed to load sigma_data.json');

      Map<String, dynamic> parsedSigmaData = jsonDecode(sigmaDataFile);
      List<dynamic> allSubjectsData = parsedSigmaData["sigma_data"];

      final Map<String, List<Map<String, dynamic>>> bookmarkedQuestionsBySubject = {};
      // Create a map of question_serial_number to subjectid
      final Map<String, String> questionToSubjectMap = {};
      for (var subjectData in allSubjectsData) {
        String subjectId = subjectData["subjectid"]?.toString() ?? '';

        if (subjectId != null) {
          // Load the subject file (e.g., 12mhmat.json)
          String subjectFilePath = '${newPath}${board}${subjectId}.json';
          final subjectFile = await SdCardUtility.getSubjectEncJsonData(subjectFilePath);

          if (subjectFile != null) {
            Map<String, dynamic> parsedSubjectData = jsonDecode(subjectFile);
            List<dynamic> subjectQuestions = parsedSubjectData["sigma_data"] ?? [];

            // Find the specific bookmarked question
            for (var question in subjectQuestions) {
              if (bookmarkedIds.contains(question["question_serial_number"]?.toString() ?? '')) {
                bookmarkedQuestionsBySubject.putIfAbsent(subjectId, () => []);
                bookmarkedQuestionsBySubject[subjectId]!.add(Map<String, dynamic>.from(question));
                _totalBookmarkedQuestions++;
              }
            }
          }
        }
      }

      print('Total bookmarked questions found: $_totalBookmarkedQuestions');

      if (_totalBookmarkedQuestions == 0) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No matching bookmarks found in the current syllabus.';
        });
        return;
      }

      // Step 3: Structure the data by subject → chapter → subchapter
      final result = <String, Map<String, Map<String, List<Map<String, dynamic>>>>>{};

      for (var subjectEntry in bookmarkedQuestionsBySubject.entries) {
        String subjectId = subjectEntry.key;
        List<Map<String, dynamic>> questions = subjectEntry.value;

        // Get subject name from first question (all should be same subject)
        String subjectName = questions.first["subject"]?.toString() ?? 'Unknown Subject';

        for (var question in questions) {
          final chapter = question["chapter_number"]?.toString() ?? '0';
          final subchapter = question["subchapter_number"]?.toString() ?? '0.0';

          result.putIfAbsent(subjectName, () => {});
          result[subjectName]!.putIfAbsent(chapter, () => {});
          result[subjectName]![chapter]!.putIfAbsent(subchapter, () => []);
          result[subjectName]![chapter]![subchapter]!.add(Map<String, dynamic>.from(question));
        }
      }

      setState(() {
        structuredData = result;
        isExpanded = List.filled(result.length, false);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load bookmarks. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    print("Path ${widget.path}");
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.chevron_right, size: 24),
            const SizedBox(width: 8),
            Text(
              "Last Minute Revision (${_totalBookmarkedQuestions})",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28),
          onPressed: () {
            // open the actual drawer
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),

      // attach your real drawer here (Option A)
      drawer: const DrawerWidget(),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenHeight * 0.04, screenWidth * 0.05, screenHeight * 0.03),
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage, textAlign: TextAlign.center))
              : structuredData.isEmpty
              ? const Center(child: Text('No bookmarked questions found.'))
              : SingleChildScrollView(
            child: Column(
              children: structuredData.entries.map((subjectEntry) {
                final subjectIndex = structuredData.keys.toList().indexOf(subjectEntry.key);
                final subjectQuestions = _countQuestionsInSubject(subjectEntry.value);

                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isExpanded[subjectIndex] = !isExpanded[subjectIndex];
                        });
                      },
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: screenHeight * 0.02,
                          horizontal: screenWidth * 0.04,
                        ),
                        margin: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
                        decoration: BoxDecoration(
                          color: cardColors[subjectIndex % cardColors.length],
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              spreadRadius: 1,
                              offset: const Offset(4, 0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(_getIconForSubject(subjectEntry.key), size: 18),
                                SizedBox(width: screenWidth * 0.02),
                                Container(
                                  width: screenWidth * 0.55,
                                  child: Text(
                                    '${subjectEntry.key} ($subjectQuestions)',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            Icon(
                              isExpanded[subjectIndex] ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                              size: 24,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (isExpanded[subjectIndex])
                      ...subjectEntry.value.entries.map((chapterEntry) {
                        final chapterQuestions = _countQuestionsInChapter(chapterEntry.value);
                        return Padding(
                          padding: EdgeInsets.only(left: screenWidth * 0.05),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Chapter ${chapterEntry.key} ($chapterQuestions)",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                              ...chapterEntry.value.entries.map((subchapterEntry) {
                                final first = subchapterEntry.value.first;
                                return GestureDetector(
                                  onTap: () {
                                    Get.to(() => TopicWiseSyllabus(
                                      pathQuestionList: subchapterEntry.value,
                                      subjectId: first["subjectid"],
                                    ));
                                  },
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.015,
                                      horizontal: screenWidth * 0.04,
                                    ),
                                    margin: EdgeInsets.symmetric(vertical: screenHeight * 0.005),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "${subchapterEntry.key}: ${first["subchapter"]} (${subchapterEntry.value.length})",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                              SizedBox(height: screenHeight * 0.01),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  int _countQuestionsInSubject(Map<String, Map<String, List<Map<String, dynamic>>>> subjectData) {
    int count = 0;
    subjectData.forEach((chapter, subchapters) {
      subchapters.forEach((subchapter, questions) {
        count += questions.length;
      });
    });
    return count;
  }

  int _countQuestionsInChapter(Map<String, List<Map<String, dynamic>>> chapterData) {
    int count = 0;
    chapterData.forEach((subchapter, questions) {
      count += questions.length;
    });
    return count;
  }

  IconData _getIconForSubject(String subject) {
    if (subject.toLowerCase().contains("math")) return Icons.calculate;
    if (subject.toLowerCase().contains("science")) return Icons.science;
    if (subject.toLowerCase().contains("physics")) return Icons.bolt;
    if (subject.toLowerCase().contains("chemistry")) return Icons.science;
    if (subject.toLowerCase().contains("biology")) return Icons.eco;
    return Icons.book;
  }
}
