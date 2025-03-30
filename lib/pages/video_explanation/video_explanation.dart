import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';

class VideoExplanation extends StatefulWidget {
  dynamic videoPath; // Can be String or List
  String basePath;
  VideoExplanation({required this.videoPath, required this.basePath, super.key});

  @override
  State<VideoExplanation> createState() => _VideoExplanationState();
}

class _VideoExplanationState extends State<VideoExplanation> {

  List<File> videoFiles = [];

  @override
  void initState() {
    super.initState();
    loadVideo();
  }

  loadVideo() async {
    String basePath = await SdCardUtility.getBasePath();
    print("Basepath $basePath --- ${widget.basePath},, ${widget.videoPath}");

    // Ensure imagePath is a List
    List<dynamic> imagePaths = widget.videoPath is String
        ? widget.videoPath.split(",").map((e) => e.trim()).toList() // Trim spaces
        : List<String>.from(widget.videoPath.map((e) => e.trim())); // Convert List<dynamic> to List<String>

    List<File> loadedFiles = [];

    for (String fileName in imagePaths) {
      for (String ext in [".mp4"]) {
        print("Pathhs ${basePath}${widget.basePath}$fileName$ext}");
        File file = File("${basePath}${widget.basePath}$fileName$ext");
        if (file.existsSync()) {
          loadedFiles.add(file);
          break; // Stop checking if file is found
        }
      }
    }

    setState(() {
      videoFiles = loadedFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Images from Memory Card")),
      body: videoFiles.isEmpty
          ? Center(child: Text("No images found"))
          : ListView.builder(
        itemCount: videoFiles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.file(videoFiles[index],
                width: double.infinity, fit: BoxFit.cover),
          );
        },
      ),
    );
  }
}
