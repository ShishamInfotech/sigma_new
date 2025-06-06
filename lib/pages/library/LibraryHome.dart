/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sigma_new/pages/pdf/pdf_viewer.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'folder_files.dart';

class LibraryHome extends StatefulWidget {
  const LibraryHome({super.key});

  @override
  State<LibraryHome> createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome> {
  List<FileSystemEntity> items = [];

  @override
  void initState() {
    super.initState();
    requestPermissionAndLoad();
  }

  Future<void> requestPermissionAndLoad() async {
    if (await Permission.storage.request().isGranted) {
      final sigmaPath = await SdCardUtility.getBasePath();
      final baseDir = Directory("${sigmaPath}/library");
      if (await baseDir.exists()) {
        final allItems = baseDir.listSync()
            .where((e) => (e is Directory) || (e is File && e.path.endsWith('.pdf')))
            .toList();

        // Sort: folders first, then files
        allItems.sort((a, b) {
          if (a is Directory && b is! Directory) return -1;
          if (a is! Directory && b is Directory) return 1;
          return a.path.compareTo(b.path);
        });

        setState(() {
          items = allItems;
        });

      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Library folder not found.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Storage permission is required.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Library')),
      body: items.isEmpty
          ? Center(child: Text("No folders or PDFs found"))
          : GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          FileSystemEntity item = items[index];
          bool isFolder = item is Directory;
          String name = item.path.split('/').last;
          IconData icon = isFolder ? Icons.folder : Icons.library_books;
          Color color = isFolder ? Colors.amber : Colors.deepOrangeAccent;

          return GestureDetector(
            onTap: () {
              if (isFolder) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => FolderFiles(folder: item as Directory),
                ));
              } else {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PDFViewerPage(filePath: item.path, title: name,),
                ));
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 48, color: color),
                SizedBox(height: 8),
                Text(
                  name,
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
*/

import 'package:flutter/material.dart ';
import 'package:flutter_svg/svg.dart';

import '../../models/menu_models.dart';
import '../../ui_helper/constant.dart';

class LibraryHome extends StatefulWidget {
  const LibraryHome({super.key});

  @override
  State<LibraryHome> createState() => _LibraryHomeState();
}

class _LibraryHomeState extends State<LibraryHome> {
  @override
  Widget build(BuildContext context) {
    List<Menu> studyMenu = [
      Menu(
          color: 0xFFF2C6DF,
          imagePath: 'assets/svg/exam_prep.svg',
          navigation: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("UI not defined in WireFrame"),
                duration: Duration(seconds: 2),
              ),
            );
          },
          title: 'Academics'),
      Menu(
          color: 0xFFC5DEF2,
          imagePath: 'assets/svg/exam_prep.svg',
          navigation: () {
            /*Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Motivation Stories', folderName: 'motivationstories',)));
*/          },
          title: 'Management'),
      Menu(
          color: 0xFFC9E4DF,
          imagePath: 'assets/svg/logbook.svg',
          navigation: () {
           /* Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Log Book', folderName: 'logbook',)));
 */         },
          title: 'Sports'),
      Menu(
          color: 0xFFF8D9C4,
          imagePath: 'assets/svg/exam_prep.svg',
          navigation: () {
            /*Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Quick Guide', folderName: 'quickguide',)));*/
          },
          title: 'CBSE'),
      Menu(
          color: 0xFFDBCDF0,
          imagePath: 'assets/svg/exam_prep.svg',
          navigation: () {
            /*Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                const PdfFolderListPage(title: 'Course Outline', folderName: 'courseoutline',)));*/
          },
          title: 'Science'),

    ];
    return Scaffold(
      appBar: AppBar(title: Text('Library')),
      body: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width * 0.9,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.6,
            ),
            itemCount: studyMenu.length,
            itemBuilder: (BuildContext context, int index) {
              return Column(
                children: [
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      if (studyMenu[index].navigation != null) {
                        studyMenu[index].navigation!();
                      } else {
                        print('No navigation route defined for this menu item');
                      }
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.13,
                      width: MediaQuery.of(context).size.width * 0.3,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(studyMenu[index].color),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: SvgPicture.asset(
                          studyMenu[index].imagePath, // Correct interpolation
                          height: 30,
                          width: 30,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    textAlign: TextAlign.center,
                    studyMenu[index].title,
                    style: black14w400MediumTextStyle,
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
