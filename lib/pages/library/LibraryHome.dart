/*

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    if (await Permission.manageExternalStorage.request().isGranted) {
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
                SvgPicture.asset(
                  isFolder ? 'assets/svg/folder_icon.svg' : 'assets/svg/pdf.svg',
                  fit: BoxFit.contain,
                ),
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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sigma_new/pages/pdf/pdf_viewer.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'folder_files.dart';
import 'video_player_screen.dart'; // NEW

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
    if (await Permission.manageExternalStorage.request().isGranted) {
      final sigmaPath = await SdCardUtility.getBasePath();

      final baseDir = Directory("$sigmaPath/library");
      if (await baseDir.exists()) {
        final allItems = baseDir.listSync().where((e) {
          if (e is Directory) return true;
          if (e is File) {
            return e.path.endsWith('.pdf') || e.path.endsWith('.mp4');
          }
          return false;
        }).toList();

        // Sort folders first
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
          ? Center(child: Text("No folders or PDFs/videos found"))
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
          String extension = name.contains('.') ? name.split('.').last.toLowerCase() : '';

          // Choose appropriate SVG asset
          String svgAsset;
          if (isFolder) {
            svgAsset = 'assets/svg/folder_icon.svg';
          } else if (extension == 'pdf') {
            svgAsset = 'assets/svg/pdf.svg';
          } else if (extension == 'mp4') {
            svgAsset = 'assets/svg/video.svg';
          } else {
            svgAsset = 'assets/svg/file.svg';
          }

          return GestureDetector(
            onTap: () {
              if (isFolder) {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => FolderFiles(folder: item as Directory),
                ));
              } else if (extension == 'pdf') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => PDFViewerPage(filePath: item.path, title: name),
                ));
              } else if (extension == 'mp4') {
                Navigator.push(context, MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(videoPath: item.path),
                ));
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SvgPicture.asset(
                    svgAsset,
                    fit: BoxFit.contain,
                  ),
                ),
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
