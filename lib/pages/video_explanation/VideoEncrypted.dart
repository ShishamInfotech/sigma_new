import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:flutter/material.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';

class EncryptedVideoPlayer extends StatefulWidget {
  final dynamic filePath;
  final String basePath;
  final String title;

  const EncryptedVideoPlayer({Key? key, required this.filePath, required this.basePath, required this.title}) : super(key: key);

  @override
  _EncryptedVideoPlayerState createState() => _EncryptedVideoPlayerState();
}

class _EncryptedVideoPlayerState extends State<EncryptedVideoPlayer> {
  VideoPlayerController? _controller; // Make nullable
  bool _isLoading = true;
  String? _tempFilePath;
  bool _initializationFailed = false;

  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    _initVideoPlayer();
  }








  Future<void> _initVideoPlayer() async {
    try {

      print("filePath ${widget.filePath}");
      final basePath = await SdCardUtility.getBasePath();
      debugPrint("BasePath from SdCardUtility: $basePath");

      String classes = '';
      String state = '';

      if (widget.basePath.contains("10")) classes = "10";
      if (widget.basePath.contains("12")) classes = "12";
      if (widget.basePath.toLowerCase().contains('mh')) state = "MH";

      final cleaned = widget.basePath
          .replaceAll(classes, "")
          .replaceAll(state.toLowerCase(), "");

      final List<dynamic> videoPaths = widget.filePath is String
          ? widget.filePath.split(",").map((e) => e.trim()).toList()
          : List<String>.from(widget.filePath.map((e) => e.trim()));

      for (String fileName in videoPaths) {
        final path = "$basePath/$classes/$state/$cleaned$fileName.mp4";
        final file = File(path);

        if (!await file.exists()) {

          debugPrint("❌ File does not exist: $path");

          _initializationFailed = true;
          return;
        }else{
          final isEncrypted = await _isEncrypted(path, "sigmapassword");

          if (isEncrypted) {
            // Create a decrypted temporary file
            _tempFilePath = await _decryptToTempFile(path);
            if (_tempFilePath == null) {
              _showError("Failed to decrypt video");
              _initializationFailed = true;
              return;
            }

            flickManager = FlickManager(videoPlayerController: VideoPlayerController.file(File(_tempFilePath!)));
          //  _controller = VideoPlayerController.file(File(_tempFilePath!));
          } else {

            flickManager = FlickManager(videoPlayerController: VideoPlayerController.file(File(path)));
           // _controller = VideoPlayerController.file(File(path));
          }

        }
      }

      // Check if file exists
      /*final path = "$basePath/$classes/$state$cleaned$fileName.mp4";
      final file = File(path);
      if (!await file.exists()) {
        _showError("File does not exist");
        _initializationFailed = true;
        return;
      }*/

      // Check if file is encrypted


    //  await _controller!.initialize();
   //   await _controller!.setLooping(true);
    //  await _controller!.play();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      _initializationFailed = true;
      _showError("Error playing video: ${e.toString()}");
    }
  }

  Future<bool> _isEncrypted(String filePath, String key) async {
    try {
      final file = File(filePath);
      final encrypted = await file.open();
      final b = Uint8List(13);
      await encrypted.setPosition(0);
      await encrypted.readInto(b);
      await encrypted.close();

      return utf8.decode(b) == key;
    } catch (e) {
      debugPrint("Encryption check error: $e");
      return false;
    }
  }

  Future<String?> _decryptToTempFile(String filePath) async {
    try {
      final directory = await getTemporaryDirectory();
      final tempFile = File('${directory.path}/decrypted_temp_video.mp4');

      if (await tempFile.exists()) {
        await tempFile.delete();
      }

      final input = await File(filePath).open();
      final output = await tempFile.open(mode: FileMode.write);

      // Skip the 13-byte encryption header
      await input.setPosition(13);

      // Copy the rest of the file
      const bufferSize = 1024 * 8;
      final buffer = Uint8List(bufferSize);

      while (true) {
        final bytesRead = await input.readInto(buffer);
        if (bytesRead == 0) break;
        await output.writeFrom(buffer.sublist(0, bytesRead));
      }

      await input.close();
      await output.close();

      return tempFile.path;
    } catch (e) {
      debugPrint("Decryption error: $e");
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: Duration(seconds: 3))
    );
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  void dispose() {
    flickManager.dispose(); // Safe call with null check
    // Clean up temporary file if it exists
    if (_tempFilePath != null) {
      File(_tempFilePath!).delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initializationFailed) {
      return Scaffold(
        appBar: AppBar(title: Text("Video Player")),
        body: Center(child: Text("Failed to initialize video player")),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: AspectRatio(
          aspectRatio: flickManager.flickVideoManager?.videoPlayerController!.value.aspectRatio ?? 16 / 9,
         child: FlickVideoPlayer(flickManager: flickManager),
         // child: VideoPlayer(_controller!),
        ),
      ),

    );
  }
}