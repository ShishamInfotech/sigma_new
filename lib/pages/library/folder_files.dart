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
