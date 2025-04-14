import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/pages/last_minute_revision/screen_details_screen.dart';
 // Import the SubjectDetailsScreen

class LastMinuteRevision extends StatefulWidget {
  const LastMinuteRevision({super.key});

  @override
  State<LastMinuteRevision> createState() => _LastMinuteRevisionState();
}

class _LastMinuteRevisionState extends State<LastMinuteRevision> {
  final List<Color> cardColors = [
    Color(0xFFDBCDF0),
    Color(0xFFC9E4DF),
    Color(0xFFF2C6DF),
    Color(0xFFC5DEF2),
    Color(0xFFFAEDCB),
  ];

  Map<String, List<Map<String, dynamic>>> groupedData = {};

  @override
  void initState() {
    super.initState();
    getBookMark();
  }

  Future<void> getBookMark() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('bookmarkedQuestions');

    if (jsonString != null && jsonString.isNotEmpty) {
      final Map<String, dynamic> decodedMap = json.decode(jsonString);

      Map<String, List<Map<String, dynamic>>> subjectGroups = {};

      for (var entry in decodedMap.entries) {
        var item = entry.value;
        if (item is Map<String, dynamic>) {
          String subject = item['subject'] ?? 'Unknown';
          subjectGroups.putIfAbsent(subject, () => []);
          subjectGroups[subject]!.add(item);
        }
      }

      setState(() {
        groupedData = subjectGroups;
      });
    }
  }

  Widget buildBulletCircle(int number) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: Colors.white,
      child: Text(
        '$number',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget buildRevisionCard(int index, Color bgColor, String subject, int count, Map<String, dynamic> subjectData) {
    return InkWell(
      onTap: () {
        // Navigate to the SubjectDetailsScreen and pass the list of subject data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubjectDetailsScreen(
              subject: subject,
              subjectDataList: groupedData[subject]!, // Pass the list of bookmarks for that subject
            ),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 80,
            margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 6,
                        offset: Offset(2, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/svg/open_folder.png',
                        width:45,
                        height: 40,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -15,
                  left: 20,
                  child: buildBulletCircle(count),
                ),
              ],
            ),
          ),
          Container(
            width: 100,
            child: Text(
              subject,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final subjects = groupedData.keys.toList();
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: Icon(Icons.arrow_back),
        title: Text("Last Minutes Revisions"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.topCenter,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFFE7FE),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(12),
            child: groupedData.isEmpty
                ? Center(child: Text("No bookmarked data found"))
                : Wrap(
              spacing: 10,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: List.generate(subjects.length, (index) {
                final subject = subjects[index];
                final count = groupedData[subject]?.length ?? 0;
                final subjectData = groupedData[subject]!.first; // Take the first data for the subject
                return buildRevisionCard(
                  index,
                  cardColors[index % cardColors.length],
                  subject,
                  count,
                  subjectData,
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
