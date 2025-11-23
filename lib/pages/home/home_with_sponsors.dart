// Sponsors with live video preview + increased height
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

// Models (keep or reuse your existing definitions)
enum SponsorMediaType { image, gif, video, pdf, unknown }

class SponsorItem {
  final String id;
  final String title;
  final String url; // file:// or http(s)...
  final SponsorMediaType type;
  SponsorItem({required this.id, required this.title, required this.url, required this.type});
}

// -------------------- SponsorsSection --------------------
class SponsorsSection extends StatelessWidget {
  final String sectionTitle;
  final List<SponsorItem> sponsors;

  const SponsorsSection({Key? key, this.sectionTitle = 'Sponsors', required this.sponsors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (sponsors.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(sectionTitle, style: Theme.of(context).textTheme.titleLarge),
              TextButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SponsorsGalleryPage(sponsors: sponsors))),
                child: Text('See all'),
              )
            ],
          ),
        ),

        // Increased height to give video preview more space
        SizedBox(
          height: 240, // increased height
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: sponsors.length,
            separatorBuilder: (_, __) => SizedBox(width: 12),
            itemBuilder: (context, idx) => SponsorCard(item: sponsors[idx]),
          ),
        ),
      ],
    );
  }
}

// -------------------- SponsorCard (Stateful) --------------------
class SponsorCard extends StatefulWidget {
  final SponsorItem item;
  const SponsorCard({Key? key, required this.item}) : super(key: key);

  @override
  State<SponsorCard> createState() => _SponsorCardState();
}

class _SponsorCardState extends State<SponsorCard> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.item.type == SponsorMediaType.video) {
      _initVideoPreview();
    }
  }

  @override
  void didUpdateWidget(covariant SponsorCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.url != widget.item.url || oldWidget.item.type != widget.item.type) {
      _disposeControllers();
      if (widget.item.type == SponsorMediaType.video) _initVideoPreview();
    }
  }

  Future<void> _initVideoPreview() async {
    try {
      final url = widget.item.url;
      if (url.startsWith('file://')) {
        _videoController = VideoPlayerController.file(File(url.replaceFirst('file://', '')));
      } else {
        _videoController = VideoPlayerController.network(url);
      }

      await _videoController!.initialize();
      _videoController!..setLooping(true)..setVolume(0.0)..play();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: true,
        allowFullScreen: false,
        showControls: false,
      );

      setState(() => _isVideoReady = true);
    } catch (e) {
      print('Video preview init failed: $e');
      _disposeControllers();
    }
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    try {
      _chewieController?.dispose();
    } catch (_) {}
    try {
      _videoController?.pause();
      _videoController?.dispose();
    } catch (_) {}
    _chewieController = null;
    _videoController = null;
    _isVideoReady = false;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    return GestureDetector(
        onTap: () => _openViewer(context, item),
        child: Container(
          width: 260, // adjust as needed to fit layout
          height: 240, // <-- FULL HEIGHT (no title area)
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
          ),

          // Entire card is just the preview now
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _buildPreview(item),
          ),
        ),
    );
  }

  Widget _buildPreview(SponsorItem item) {
    switch (item.type) {
      case SponsorMediaType.image:
      case SponsorMediaType.gif:
        if (item.url.startsWith('file://')) {
          return Image.file(File(item.url.replaceFirst('file://', '')), fit: BoxFit.cover);
        }
        return CachedNetworkImage(
          imageUrl: item.url,
          fit: BoxFit.cover,
          placeholder: (_, __) => Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => Icon(Icons.broken_image),
        );

      case SponsorMediaType.video:
        if (_isVideoReady && _chewieController != null) {
          return Chewie(controller: _chewieController!);
        }
        return Container(color: Colors.black12, child: Center(child: Icon(Icons.play_circle_fill, size: 56)));

      case SponsorMediaType.pdf:
        return Container(
          color: Colors.grey.shade100,
          child: Center(child: Icon(Icons.picture_as_pdf, size: 48)),
        );

      default:
        return Container(color: Colors.grey.shade200, child: Center(child: Icon(Icons.insert_drive_file)));
    }
  }

  Future<void> _openViewer(BuildContext context, SponsorItem item) async {
    // If it's video, open full viewer (you may have app-specific viewer)
    if (item.type == SponsorMediaType.video) {
      final isLocal = item.url.startsWith('file://');
      final localPath = isLocal ? item.url.replaceFirst('file://', '') : null;

      // Try to open app-specific video viewers if you have, otherwise open fallback full-screen player
      // Example fallback:
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => VideoViewerFullScreen(url: item.url, title: item.title)));
      return;
    }

    if (item.type == SponsorMediaType.image || item.type == SponsorMediaType.gif) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => ImageViewerPage(url: item.url, title: item.title)));
      return;
    }

    if (item.type == SponsorMediaType.pdf) {
      final isLocal = item.url.startsWith('file://');
      final localPath = isLocal ? item.url.replaceFirst('file://', '') : null;
      if (localPath != null) {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PdfViewerLocalFallback(filePath: localPath)));
      } else {
        final uri = Uri.parse(item.url);
        if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }

    // default
    final uri = Uri.parse(item.url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

// -------------------- Full-screen video viewer (fallback) --------------------
class VideoViewerFullScreen extends StatefulWidget {
  final String url;
  final String title;
  const VideoViewerFullScreen({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  State<VideoViewerFullScreen> createState() => _VideoViewerFullScreenState();
}

class _VideoViewerFullScreenState extends State<VideoViewerFullScreen> {
  VideoPlayerController? _controller;
  ChewieController? _chewie;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final isLocal = widget.url.startsWith('file://');
      if (isLocal) {
        final path = widget.url.replaceFirst('file://', '');
        _controller = VideoPlayerController.file(File(path));
      } else {
        _controller = VideoPlayerController.network(widget.url);
      }
      await _controller!.initialize();
      _chewie = ChewieController(
        videoPlayerController: _controller!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        showControls: true,
      );
      setState(() {});
    } catch (e) {
      print('Full video init error: $e');
    }
  }

  @override
  void dispose() {
    _chewie?.dispose();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Center(child: _chewie != null ? Chewie(controller: _chewie!) : CircularProgressIndicator()),
    );
  }
}

// -------------------- Image / PDF viewers re-used from earlier --------------------
class ImageViewerPage extends StatelessWidget {
  final String url;
  final String title;
  const ImageViewerPage({Key? key, required this.url, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLocal = url.startsWith('file://');
    final provider = isLocal ? FileImage(File(url.replaceFirst('file://', ''))) : CachedNetworkImageProvider(url) as ImageProvider;
    return Scaffold(appBar: AppBar(title: Text(title)), body: PhotoView(imageProvider: provider));
  }
}

class PdfViewerLocalFallback extends StatelessWidget {
  final String filePath;
  const PdfViewerLocalFallback({Key? key, required this.filePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(p.basename(filePath))), body: PDFView(filePath: filePath, enableSwipe: true, swipeHorizontal: false, autoSpacing: true));
  }
}

// -------------------- Sponsors gallery --------------------
class SponsorsGalleryPage extends StatelessWidget {
  final List<SponsorItem> sponsors;
  const SponsorsGalleryPage({Key? key, required this.sponsors}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('All Sponsors')),
      body: GridView.builder(
        padding: EdgeInsets.all(12),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1.1, crossAxisSpacing: 12, mainAxisSpacing: 12),
        itemCount: sponsors.length,
        itemBuilder: (context, i) => SponsorCard(item: sponsors[i]),
      ),
    );
  }
}

// -------------------- Helper --------------------
SponsorMediaType guessTypeFromUrl(String url) {
  final lower = url.toLowerCase();
  if (lower.endsWith('.mp4') || lower.endsWith('.webm') || lower.endsWith('.mov')) return SponsorMediaType.video;
  if (lower.endsWith('.gif')) return SponsorMediaType.gif;
  if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return SponsorMediaType.image;
  if (lower.endsWith('.pdf')) return SponsorMediaType.pdf;
  return SponsorMediaType.unknown;
}
