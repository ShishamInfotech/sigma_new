import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:path/path.dart' as p; // 🔄 ADDED

class VideoExplanation extends StatefulWidget {
  final dynamic videoPath; // Can be String or List<String>
  final String basePath;

  const VideoExplanation({required this.videoPath, required this.basePath, super.key});

  @override
  State<VideoExplanation> createState() => _VideoExplanationState();
}

class _VideoExplanationState extends State<VideoExplanation> {
  List<VideoPlayerController> _controllers = [];
  List<String> _errors = [];
  HttpServer? _server; // 🔄 ADDED
  String? _baseUrl; // 🔄 ADDED

  @override
  void initState() {
    super.initState();
    _setupServerAndInitializePlayers();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    _server?.close(); // 🔄 CLOSE SERVER
    super.dispose();
  }

  Future<void> _setupServerAndInitializePlayers() async {
    await _requestStoragePermission();

    final basePath = await SdCardUtility.getBasePath();
    debugPrint("BasePath from SdCardUtility: $basePath");

 //  await _startLocalServer("/storage/0000-0000/sigma/12/MH/phy/videos/xirp0001.mp4"); // 🔄 START SERVER
    await _startLocalServer(basePath); // 🔄 START SERVER

    await _initializeVideoPlayers();
  }

  Future<void> _startLocalServer(String rootPath) async {
    final handler = Pipeline().addMiddleware(logRequests()).addHandler((Request request) async {
      final uri = request.requestedUri;
      final queryParams = uri.queryParameters;
      final filePath = queryParams['path'];

      if (filePath == null || !File(filePath).existsSync()) {
        return Response.notFound('File not found');
      }

      final file = File(filePath);
      final contentType = _getContentType(file.path);

      final headers = {
        HttpHeaders.contentTypeHeader: contentType,
        HttpHeaders.acceptRangesHeader: 'bytes',
      };

      final rangeHeader = request.headers[HttpHeaders.rangeHeader];
      if (rangeHeader != null && rangeHeader.startsWith('bytes=')) {
        final range = rangeHeader.substring(6).split('-');
        final start = int.parse(range[0]);
        final end = range[1].isEmpty ? await file.length() - 1 : int.parse(range[1]);

        final length = end - start + 1;
        final stream = file.openRead(start, end + 1);

        return Response(200,body:stream,
          headers: {
            ...headers,
            HttpHeaders.contentLengthHeader: length.toString(),
            HttpHeaders.contentRangeHeader: 'bytes $start-$end/${await file.length()}',
          },
        );
      }

      return Response.ok(file.openRead(), headers: {
        ...headers,
        HttpHeaders.contentLengthHeader: (await file.length()).toString(),
      });
    });

    _server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, 8080);
    _baseUrl = 'http://${_server!.address.address}:${_server!.port}';

    print("Base URR $_baseUrl");
  }

  Future<void> _initializeVideoPlayers() async {
    String classes = '';
    String state = '';

    if (widget.basePath.contains("10")) classes = "10";
    if (widget.basePath.contains("12")) classes = "12";
    if (widget.basePath.toLowerCase().contains('mh')) state = "MH";

    final cleaned = widget.basePath
        .replaceAll(classes, "")
        .replaceAll(state.toLowerCase(), "");

    final List<dynamic> videoPaths = widget.videoPath is String
        ? widget.videoPath.split(",").map((e) => e.trim()).toList()
        : List<String>.from(widget.videoPath.map((e) => e.trim()));

    List<VideoPlayerController> controllers = [];

    for (String fileName in videoPaths) {
      final filePath = "${await SdCardUtility.getBasePath()}/$classes/$state$cleaned$fileName.mp4";
      print("File Path $filePath");

      final file = File(filePath);

      if (file.existsSync()) {
        try {
          final encodedPath = Uri.encodeComponent(filePath);
          final url = '$_baseUrl/?path=$encodedPath'; // 🔄 USING NETWORK STREAM
          final controller = VideoPlayerController.network(url);
          await controller.initialize();
          controllers.add(controller);
          debugPrint("✅ Streamed video via HTTP: $url");
        } catch (e) {
          _errors.add("Error loading $fileName: ${e.toString()}");
          debugPrint("❌ Failed to initialize $filePath: $e");
        }
      } else {
        _errors.add("File not found: $filePath");
        debugPrint("❌ File does not exist: $filePath");
      }
    }

    setState(() {
      _controllers = controllers;
    });
  }

  String _getContentType(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    switch (ext) {
      case '.mp4':
        return 'video/mp4';
      case '.webm':
        return 'video/webm';
      case '.mov':
        return 'video/quicktime';
      default:
        return 'application/octet-stream';
    }
  }

  Future<void> _requestStoragePermission() async {
    var status = await Permission.manageExternalStorage.status;
    if (!status.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Video Explanation")),
      body: _controllers.isEmpty
          ? Center(
        child: _errors.isEmpty
            ? const CircularProgressIndicator()
            : Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              const Text(
                "No playable videos found.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._errors.map((e) => Text("• $e")).toList(),
            ],
          ),
        ),
      )
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
                      icon: Icon(controller.value.isPlaying ? Icons.pause : Icons.play_arrow),
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