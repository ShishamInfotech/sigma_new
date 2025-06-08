
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
    this.useCoursePrefix = false,
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
    //widget.useCoursePrefix ? loadCourses() : loadFlatFolder(widget.folderName);
    searchCoursesForPdfs();
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

  Future<void> searchCoursesForPdfs() async {
    final baseDir = Directory(await SdCardUtility.getBasePath());
    if (!baseDir.existsSync()) return;

    final courseDirs = baseDir.listSync().whereType<Directory>();
    for (final courseDir in courseDirs) {
      final targetDir = Directory("${courseDir.path}/${widget.folderName}");
      if (targetDir.existsSync()) {
        final pdfs = targetDir
            .listSync(recursive: true, followLinks: false)
            .where((file) => file.path.toLowerCase().endsWith(".pdf") && FileSystemEntity.isFileSync(file.path))
            .toList();
        if (pdfs.length == 1) {
          final singleFile = pdfs.first;
          Future.microtask(() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => PDFViewerPage(title: '', filePath: singleFile.path,),
              ),
            );
          });
          return;
        } else if (pdfs.length > 1) {
          pdfFiles = pdfs;
          break; // Stop after finding the first folder with multiple PDFs
        }
      }
    }
    setState(() {});
  }


  Future<void> loadFlatFolder(String folder) async {
    final sigmaPath = await SdCardUtility.getBasePath();
    //final pdfDir = Directory("${sigmaPath}/${folder}");
    final baseDir = Directory(sigmaPath);
    final courseDirs = baseDir.listSync().whereType<Directory>();
    for (final courseDir in courseDirs) {
      final pdfDir = Directory("${courseDir.path}/${folder}");
      print("PDF Directory:=" + pdfDir.toString());
      if (await pdfDir.exists()) {
        print("Inside:-");
        final files = pdfDir
            .listSync()
            .where((f) => f.path.toLowerCase().endsWith(".pdf"))
            .toList();
        print("Inside:-"+ files.toString());

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
    print("Outside:-"+ pdfFiles.toString());

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
    if (pdfFiles.length == 1) {
      final file = pdfFiles.first;
      Future.microtask(() {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewerPage(title: file.path.split(Platform.pathSeparator).last,
            filePath: file.path,),
          ),
        );
      });
      return const Scaffold(body: SizedBox());
    }

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title, style: TextStyle(color: Colors.white)),
          backgroundColor: primaryColor,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: pdfFiles.isEmpty
            ? const Center(child: Text("No PDF files found."))
            : ListView.builder(
          itemCount: pdfFiles.length,
          itemBuilder: (context, index) {
            final file = pdfFiles[index];
            return ListTile(
              title: Text(file.path.split(Platform.pathSeparator).last),
              leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerPage(title: file.path.split(Platform.pathSeparator).last,
                        filePath: file.path),
                  ),
                );
              },
            );
          },
        ));
  }
}