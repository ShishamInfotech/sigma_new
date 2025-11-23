// lib/pages/common/info_folder_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sigma_new/pages/home/home_with_sponsors.dart' show SponsorItem, VideoViewerFullScreen, SponsorMediaType, ImageViewerPage, PdfViewerLocalFallback;

import '../utility/sd_card_utility.dart'; // optional reuse
// Import your PdfFolderListPage if you reuse it, otherwise the page lists files itself:
// import 'package:sigma_new/pages/home/pdf/PdfFolderListPage.dart';

class InfoFolderPage extends StatefulWidget {
  final String title;
  final String folderName; // folder under Sigma/library or any path you choose
  final IconData? icon;
  final String? description;

  const InfoFolderPage({
    Key? key,
    required this.title,
    required this.folderName,
    this.icon,
    this.description,
  }) : super(key: key);

  @override
  _InfoFolderPageState createState() => _InfoFolderPageState();
}

class _InfoFolderPageState extends State<InfoFolderPage> {
  List<File> _files = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFiles();
  }

  Future<void> _loadFiles() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Example: Use SdCardUtility.getBasePath() if you store files on SD
      // final base = await SdCardUtility.getBasePath();
      // final dir = Directory("$base/library/${widget.folderName}");

      // If you prefer an app-internal path or assets, change the directory logic accordingly.
      // For now we'll attempt SdCardUtility, but fall back to app directory if not present.
      final base = await _safeGetSigmaBasePath();
      if (base == null) {
        setState(() {
          _files = [];
          _loading = false;
          _error = 'Storage path not found.';
        });
        return;
      }

      final dir = Directory(p.join(base, 'info', widget.folderName));
      if (!await dir.exists()) {
        setState(() {
          _files = [];
          _loading = false;
          _error = 'Folder not found: ${dir.path}';
        });
        return;
      }

      final entries = await dir.list().toList();
      final files = entries.whereType<File>().toList();
      files.sort((a, b) => p.basename(a.path).compareTo(p.basename(b.path)));

      setState(() {
        _files = files;
        _loading = false;
      });
    } catch (e, st) {
      setState(() {
        _files = [];
        _loading = false;
        _error = 'Failed to load files: $e';
      });
      print('InfoFolderPage._loadFiles error: $e\n$st');
    }
  }

  /// Wrap SdCardUtility call so the page doesn't crash if the util is missing.
  Future<String?> _safeGetSigmaBasePath() async {
    try {
      // If you have SdCardUtility.getBasePath() in your project:
      final sigmaPath = await SdCardUtility.getBasePath();
      // if sdk returns null or empty, return null
      if (sigmaPath == null || sigmaPath.toString().isEmpty) return null;
      return sigmaPath.toString();
    } catch (e) {
      print('SdCardUtility not available or failed: $e');
      // fallback (optional): use app directory (getApplicationDocumentsDirectory)
      // return (await getApplicationDocumentsDirectory()).path;
      return null;
    }
  }

  /// Detect media type by extension
  SponsorMediaType _mediaTypeForPath(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp4') || lower.endsWith('.webm') || lower.endsWith('.mov')) return SponsorMediaType.video;
    if (lower.endsWith('.gif')) return SponsorMediaType.gif;
    if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return SponsorMediaType.image;
    if (lower.endsWith('.pdf')) return SponsorMediaType.pdf;
    return SponsorMediaType.unknown;
  }

  void _openFile(File file) {
    final ext = p.extension(file.path).toLowerCase();
    final title = p.basenameWithoutExtension(file.path);
    final fileUrl = 'file://${file
        .path}'; // pass this to viewers that expect url

    final type = _mediaTypeForPath(file.path);

    switch (type) {
      case SponsorMediaType.image:
      case SponsorMediaType.gif:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => ImageViewerPage(url: fileUrl, title: title),
        ));
        break;

      case SponsorMediaType.video:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => VideoViewerFullScreen(url: fileUrl, title: title),
        ));
        break;

      case SponsorMediaType.pdf:
      // PdfViewerLocalFallback expects a local file path (not file://)
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => PdfViewerLocalFallback(filePath: file.path),
        ));
        break;

      default:
      // fallback: show a simple preview or message
        showDialog(
          context: context,
          builder: (_) =>
              AlertDialog(
                title: Text(title),
                content: Text(
                    'Cannot preview this file type. Path:\n${file.path}'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context),
                      child: Text('OK'))
                ],
              ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: BackButton(),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: TextStyle(color: Colors.red)))
          : Column(
        children: [
          // ============================
          // DESCRIPTION AREA
          // ============================
          if (widget.icon != null || (widget.description?.isNotEmpty ?? false))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.icon != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 12.0),
                      child: Icon(widget.icon, size: 28),
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.description != null && widget.description!.isNotEmpty)
                          Text(widget.description!, style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ======================================================
          // NEW LOGIC: IF ONLY 1 FILE → SHOW THE VIEWER DIRECTLY
          // ======================================================
          if (_files.length == 1)
            Expanded(child: _buildSingleFileViewer(_files.first))
          else
          // ======================================================
          // MULTIPLE FILES → SHOW LIST
          // ======================================================
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadFiles,
                child: ListView.separated(
                  padding: EdgeInsets.all(12),
                  itemCount: _files.length,
                  separatorBuilder: (c, i) => Divider(height: 1),
                  itemBuilder: (context, index) {
                    final f = _files[index];
                    final name = p.basenameWithoutExtension(f.path);
                    final ext = p.extension(f.path).toLowerCase();
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                      leading: _leadingForExt(ext),
                      title: Text(name),
                      subtitle: Text(p.basename(f.path)),
                      trailing: Icon(Icons.chevron_right),
                      onTap: () => _openFile(f), // uses your viewer
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _leadingForExt(String ext) {
    switch (ext) {
      case '.pdf':
        return Icon(Icons.picture_as_pdf, color: Colors.red);
      case '.mp4':
      case '.webm':
        return Icon(Icons.play_arrow, color: Colors.blue);
      case '.png':
      case '.jpg':
      case '.jpeg':
        return Icon(Icons.image, color: Colors.green);
      default:
        return Icon(Icons.insert_drive_file);
    }
  }

  Widget _buildSingleFileViewer(File file) {
    final ext = p.extension(file.path).toLowerCase();
    final fileUrl = 'file://${file.path}';
    final title = p.basenameWithoutExtension(file.path);

    switch (_mediaTypeForPath(file.path)) {
      case SponsorMediaType.image:
      case SponsorMediaType.gif:
        return ImageViewerPage(url: fileUrl, title: title);

      case SponsorMediaType.video:
        return VideoViewerFullScreen(url: fileUrl, title: title);

      case SponsorMediaType.pdf:
        return PdfViewerLocalFallback(filePath: file.path);

      default:
        return Center(
          child: Text("Cannot preview this file type.\n${file.path}",
              textAlign: TextAlign.center),
        );
    }
  }
}

/// Simple placeholders — replace these with your real viewers.
/// Pdf placeholder
class _PdfPlaceholder extends StatelessWidget {
  final String filePath;
  const _PdfPlaceholder({Key? key, required this.filePath}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(p.basename(filePath))), body: Center(child: Text('Open PDF viewer for\n$filePath')));
  }
}

/// Video placeholder
class _VideoPlaceholder extends StatelessWidget {
  final String filePath;
  const _VideoPlaceholder({Key? key, required this.filePath}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: Text(p.basename(filePath))), body: Center(child: Text('Open Video viewer for\n$filePath')));
  }
}

/// Generic file viewer for images/others
class _GenericFileViewer extends StatelessWidget {
  final File file;
  const _GenericFileViewer({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ext = p.extension(file.path).toLowerCase();
    if (ext == '.png' || ext == '.jpg' || ext == '.jpeg') {
      return Scaffold(appBar: AppBar(title: Text(p.basename(file.path))), body: Center(child: Image.file(file)));
    }
    return Scaffold(appBar: AppBar(title: Text(p.basename(file.path))), body: Center(child: Text('Cannot preview this file type.')));
  }




}
