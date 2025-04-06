import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
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
  List<VideoPlayerController> _controllers = [];

  @override
  void initState() {
    super.initState();
    loadVideos();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  loadVideos() async {
    String basePath = await SdCardUtility.getBasePath();
    print("Basepath $basePath --- ${widget.basePath}, ${widget.videoPath}");

    var classes = '';
    var state = '';

    if (widget.basePath.contains("10")) classes = "10";
    if (widget.basePath.contains("12")) classes = "12";
    if (widget.basePath.toLowerCase().contains('mh')) state = "MH";

    String cleaned = widget.basePath
        .replaceAll(classes, "")
        .replaceAll(state.toLowerCase(), "");

    // Split video paths
    List<String> videoPaths = widget.videoPath is String
        ? widget.videoPath
        .split(",")
        .map((e) => e.trim())
        .toList()
        : List<String>.from(widget.videoPath.map((e) => e.trim()));

    List<File> loadedFiles = [];
    List<VideoPlayerController> controllers = [];

    for (String fileName in videoPaths) {
      String path = "$basePath/$classes/$state$cleaned$fileName.mp4";
      File file = File(path);
      if (file.existsSync()) {
        loadedFiles.add(file);

        final controller = VideoPlayerController.file(file);
        await controller.initialize();
        controllers.add(controller);
      }
    }

    setState(() {
      videoFiles = loadedFiles;
      _controllers = controllers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Video Explanation")),
      body: videoFiles.isEmpty
          ? Center(child: Text("No videos found"))
          : ListView.builder(
        itemCount: _controllers.length,
        itemBuilder: (context, index) {
          final controller = _controllers[index];
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow),
                      onPressed: () {
                        setState(() {
                          controller.value.isPlaying
                              ? controller.pause()
                              : controller.play();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
