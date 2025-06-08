import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/pages/pdf/pdf_viewer.dart';
import '../../ui_helper/constant.dart';


class ExamPreparation extends StatefulWidget {
  const ExamPreparation({super.key});

  @override
  State<ExamPreparation> createState() => _ExamPreparationState();
}

class _ExamPreparationState extends State<ExamPreparation> {
  final GlobalKey<ScaffoldState> _examscaffoldKey = GlobalKey<ScaffoldState>();

  List<String> availableCourses = [];
  List<FileSystemEntity> pdfFiles = [];
  String selectedCourse = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  Future<void> loadCourses() async {
    final sigmaPath = await SdCardUtility.getBasePath();
    final directory = Directory(sigmaPath);
    final courseDirs = directory
        .listSync()
        .where((d) =>
            d is Directory &&
            (d.path.contains("10") ||
                d.path.contains("12") ||
                d.path.toLowerCase().contains("jee")))
        .toList();
    print("CourseDirs:-" + courseDirs.toString());
    setState(() {
      availableCourses = courseDirs.map((e) => e.path.split('/').last).toList();
      loading = false;
    });
  }

  Future<void> loadExamPrepPDFs(String course) async {
    setState(() {
      loading = true;
      selectedCourse = course;
      pdfFiles = [];
    });
    print("Course Selected:-" + course);
    final sigmaPath = await SdCardUtility.getBasePath();
    final examPrepDir = Directory("${sigmaPath}/${course}/examprep");

    print("examPrepDir:-" + examPrepDir.toString());

    if (await examPrepDir.exists()) {
      final files = examPrepDir
          .listSync()
          .where((f) => f.path.toLowerCase().endsWith(".pdf"))
          .toList();

      setState(() {
        pdfFiles = files;
        loading = false;
      });
    } else {
      setState(() {
        pdfFiles = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _examscaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                backgroundColor,
                backgroundColor,
                backgroundColor,
                whiteColor
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title:
            const Text("Exam Preparation", style: black20w400MediumTextStyle),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : selectedCourse.isEmpty
              ? GridView.count(
                  padding: const EdgeInsets.all(16),
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  children: availableCourses.map((course) {
                    return InkWell(
                      onTap: () => loadExamPrepPDFs(course),
                      child: Card(
                        color: Colors.amber[100],
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Center(
                          child: Text(
                            course,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              : pdfFiles.isEmpty
                  ? const Center(
                      child: Text("No PDFs found in selected course."))
                  : ListView.builder(
                      itemCount: pdfFiles.length,
                      itemBuilder: (context, index) {
                        final file = pdfFiles[index];
                        return ListTile(
                          leading: const Icon(Icons.picture_as_pdf),
                          title: Text(file.path.split("/").last),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PDFViewerPage(
                                  title: file.path.split("/").last,
                                  filePath: file.path,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}
