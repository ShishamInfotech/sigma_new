/*
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sigma_new/pages/pdf/pdf_viewer.dart';

class FolderFiles extends StatelessWidget {
  final Directory folder;

  const FolderFiles({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    // Get folders + PDFs
    List<FileSystemEntity> items = folder.listSync()
        .where((e) => (e is Directory) || (e is File && e.path.endsWith('.pdf')))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(folder.path.split('/').last)),
      body: GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: items.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sigma_new/pages/pdf/pdf_viewer.dart';
import 'video_player_screen.dart';

class FolderFiles extends StatefulWidget {
  final Directory folder;

  const FolderFiles({super.key, required this.folder});

  @override
  State<FolderFiles> createState() => _FolderFilesState();
}

class _FolderFilesState extends State<FolderFiles> {
  List<FileSystemEntity> files = [];

  @override
  void initState() {
    super.initState();
    loadFiles();
  }

  void loadFiles() {
    final allItems = widget.folder
        .listSync()
        .where((e) {
      if (e is Directory) return true;
      if (e is File) {
        return e.path.endsWith('.pdf') || e.path.endsWith('.mp4');
      }
      return false;
    })
        .toList();

    allItems.sort((a, b) {
      if (a is Directory && b is! Directory) return -1;
      if (a is! Directory && b is Directory) return 1;
      return a.path.compareTo(b.path);
    });

    setState(() {
      files = allItems;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.folder.path.split('/').last),
      ),
      body: files.isEmpty
          ? Center(child: Text("No PDFs or videos found"))
          : GridView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: files.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          FileSystemEntity item = files[index];
          bool isFolder = item is Directory;
          String name = item.path.split('/').last;
          String extension = name.contains('.') ? name.split('.').last.toLowerCase() : '';

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => FolderFiles(folder: item as Directory),
                  ),
                );
              } else if (extension == 'pdf') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PDFViewerPage(filePath: item.path, title: name),
                  ),
                );
              } else if (extension == 'mp4') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(videoPath: item.path),
                  ),
                );
              }
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SvgPicture.asset(svgAsset, fit: BoxFit.contain),
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
