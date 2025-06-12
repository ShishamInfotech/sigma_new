import 'dart:io';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sigma_new/pages/pdf/pdf_viewer.dart';

import '../pages/library/folder_files.dart' show FolderFiles;
import '../utility/sd_card_utility.dart';



class AboutUs extends StatefulWidget {
  const AboutUs({super.key});

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  List<FileSystemEntity> items = [];

  @override
  void initState() {
    super.initState();
    requestPermissionAndLoad();
  }

  Future<void> requestPermissionAndLoad() async {
    if (await Permission.storage.request().isGranted) {
      final sigmaPath = await SdCardUtility.getBasePath();
      final baseDir = Directory("${sigmaPath}/about_us");
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
          SnackBar(content: Text("About us not found.")),
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
      appBar: AppBar(title: Text('About Us')),
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




