import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

import 'dart:io';
import 'package:flutter/material.dart';

class TextAnswer extends StatefulWidget {
  dynamic imagePath; // Can be String or List
  String basePath;

  TextAnswer({required this.imagePath, required this.basePath, super.key});

  @override
  State<TextAnswer> createState() => _TextAnswerState();
}

class _TextAnswerState extends State<TextAnswer> {
  List<File> imageFiles = [];

  @override
  void initState() {
    super.initState();
    loadImage();
  }

  loadImage() async {
    String basePath = await SdCardUtility.getBasePath();
    print("Basepath $basePath --- ${widget.basePath},, ${widget.imagePath}");

    // Ensure imagePath is a List
    List<dynamic> imagePaths = widget.imagePath is String
        ? widget.imagePath.split(",").map((e) => e.trim()).toList() // Trim spaces
        : List<String>.from(widget.imagePath.map((e) => e.trim())); // Convert List<dynamic> to List<String>

    List<File> loadedFiles = [];

    for (String fileName in imagePaths) {
      for (String ext in [".jpg"]) {
        print("Pathhs ${basePath}${widget.basePath}$fileName$ext}");
        File file = File("${basePath}${widget.basePath}$fileName$ext");
        if (file.existsSync()) {
          loadedFiles.add(file);
          break; // Stop checking if file is found
        }
      }
    }

    setState(() {
      imageFiles = loadedFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Images from Memory Card")),
      body: imageFiles.isEmpty
          ? Center(child: Text("No images found"))
          : ListView.builder(
        itemCount: imageFiles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(imageFiles[index],
                 width: double.infinity, fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}
