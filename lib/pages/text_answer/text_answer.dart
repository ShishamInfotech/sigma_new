import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';


class TextAnswer extends StatefulWidget {
  dynamic imagePath; // Can be String or List
  String? basePath;
  String title;
  String? stream;

  TextAnswer({required this.imagePath, this.basePath,required this.title, this.stream, super.key});

  @override
  State<TextAnswer> createState() => _TextAnswerState();
}

class _TextAnswerState extends State<TextAnswer> {
  List<File> imageFiles = [];

  @override
  void initState() {
    super.initState();
    incrementAnswerCount();
    if(widget.basePath?.toLowerCase().toString() != "nr")loadImage();

  }

  void incrementAnswerCount() async {
    final prefs = await SharedPreferences.getInstance();
    int current = prefs.getInt('answer_count') ?? 0;
    await prefs.setInt('answer_count', current + 1);
  }

  loadImage() async {
    String basePath = await SdCardUtility.getBasePath();
    print("Basepath $basePath --- ${widget.basePath},, ${widget.imagePath}, ${widget.stream}");
    var classes;
    var state="";
    var subject;

    if(widget.stream!.contains("10")){
      classes = "10";
    }
    if(widget.stream!.contains("12")){
      classes = "12";
    }

    if(widget.stream!.contains("jee")){
      classes = "JEE/THEORY";
    }

    if(widget.basePath!.contains('mh')  && !widget.stream!.contains("jee")){
      state = "/MH";
    }

    String cleaned="";
    if(widget.stream!.contains("jee")){
      cleaned = widget.basePath!.replaceAll(classes, "").replaceAll(state.toString().toLowerCase(), "");
    }else {
      cleaned = widget.basePath!.replaceAll(classes, "").replaceAll(
          state.toString().toLowerCase(), "/");
    }

    print("Cleaned $cleaned");




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
      for (String ext in [".jpg", ".png"]) {
        print("Pathhs ${basePath}/${classes}${state}${cleaned}$fileName$ext");
        File file = File("${basePath}/${classes}${state}${cleaned}$fileName$ext");
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
    print("VALue ${widget.imagePath}");
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: widget.basePath == "nr"
          ? SingleChildScrollView(
            child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  
                    color: blackColor.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(10))),
                child: MathText(
                   expression: widget.imagePath,
                 height: _estimateHeight(widget.imagePath),
                 // style: black16MediumTextStyle,
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

  double _estimateHeight(String text) {
    if (text.isEmpty) return 0;

    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    double height = (lines + longLines) * 30.0;
    height = height * 5.0;

    if (hasComplexMath) {
      height += 30.0;
    }

    return height.clamp(50.0, 300.0);
  }
}
