import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';


class TextAnswer extends StatefulWidget {
  dynamic imagePath; // Can be String or List
  String? basePath;

  TextAnswer({required this.imagePath, this.basePath, super.key});

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
        ? widget.imagePath
            .split(",")
            .map((e) => e.trim())
            .toList() // Trim spaces
        : List<String>.from(widget.imagePath
            .map((e) => e.trim())); // Convert List<dynamic> to List<String>

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
      appBar: AppBar(title: const Text("Images from Memory Card")),
      body: widget.basePath == "nr"
          ? SingleChildScrollView(
            child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  
                    color: blackColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: Text(
                  widget.imagePath,
                  style: black16MediumTextStyle,
                ),
              ),
          )
          : imageFiles.isEmpty
              ? const Center(child: Text("No images found"))
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
