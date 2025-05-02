
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/pages/pdf/pdf_viewer.dart';
import '../drawer/drawer.dart';
import '../../ui_helper/constant.dart';

class PdfFolderListPage extends StatefulWidget {
  final String title;
  final String folderName;
  final bool useCoursePrefix;

  const PdfFolderListPage({
    super.key,
    required this.title,
    required this.folderName,
    this.useCoursePrefix = true,
  });

  @override
  State<PdfFolderListPage> createState() => _PdfFolderListPageState();
}

class _PdfFolderListPageState extends State<PdfFolderListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> availableCourses = [];
  List<FileSystemEntity> pdfFiles = [];
  String selectedCourse = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    widget.useCoursePrefix ? loadCourses() : loadFlatFolder(widget.folderName);
  }

  Future<void> loadCourses() async {
    final sigmaPath = await SdCardUtility.getBasePath();
    final directory = Directory(sigmaPath);
    final courseDirs = directory
        .listSync()
        .where((d) =>
            d is Directory &&
            (d.path.contains("10") || d.path.contains("12") || d.path.toLowerCase().contains("jee")))
        .toList();

    setState(() {
      availableCourses = courseDirs.map((e) => e.path.split('/').last).toList();
      loading = false;
    });
  }

  Future<void> loadFlatFolder(String folder) async {
    final sigmaPath = await SdCardUtility.getBasePath();
    final pdfDir = Directory("${sigmaPath}/${folder}");

    if (await pdfDir.exists()) {
      final files = pdfDir
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

  Future<void> loadExamPrepPDFs(String course) async {
    setState(() {
      loading = true;
      selectedCourse = course;
      pdfFiles = [];
    });

    final sigmaPath = await SdCardUtility.getBasePath();
    final pdfDir = Directory("${sigmaPath}/${course}/${widget.folderName}");

    if (await pdfDir.exists()) {
      final files = pdfDir
          .listSync()
          .where((f) => f.path.toLowerCase().endsWith(".pdf"))
          .toList();

      setState(() {
        pdfFiles = files;
        loading = false;
      });
      if (files.length == 1) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => PDFViewerPage(
              title: files[0].path.split("/").last,
              filePath: files[0].path,
            ),
          ),
        );
        return;
      }
    } else {
      setState(() {
        pdfFiles = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: InkWell(
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
          child: const Icon(Icons.menu),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [backgroundColor, backgroundColor, backgroundColor, whiteColor],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        title: Text(widget.title, style: black20w400MediumTextStyle),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : widget.useCoursePrefix && selectedCourse.isEmpty
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        child: Center(
                          child: Text(
                            course,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              : pdfFiles.isEmpty
                  ? const Center(child: Text("No PDFs found in selected folder."))
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
      drawer: DrawerWidget(context),
    );
  }
}