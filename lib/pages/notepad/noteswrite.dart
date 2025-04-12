/*
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:path_provider/path_provider.dart';

class NotepadPage extends StatefulWidget {
  @override
  State<NotepadPage> createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage> {
  late QuillController _controller;
  final String _fileName = 'note.json';
  bool _isLoaded = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    try {
      final doc = await _loadDocument();
      _controller = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
      );

      // Add listener to auto-save when content changes
      _controller.addListener(_autoSave);

      setState(() => _isLoaded = true);
    } catch (e) {
      // Fallback to empty document if loading fails
      _controller = QuillController.basic();
      setState(() => _isLoaded = true);
    }
  }

  Future<Document> _loadDocument() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$_fileName');

    if (await file.exists()) {
      final contents = await file.readAsString();
      return Document.fromJson(jsonDecode(contents));
    }
    return Document();
  }

  Future<void> _autoSave() async {
    if (_isSaving) return;

    _isSaving = true;
    await _saveDocument();
    _isSaving = false;
  }

  Future<void> _saveDocument() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/$_fileName');
      final json = jsonEncode(_controller.document.toDelta().toJson());
      await file.writeAsString(json);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Note saved."),
            duration: Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to save: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_autoSave);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notepad"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveDocument,
            tooltip: 'Save',
          ),
        ],
      ),
      body: Column(
        children: [
          QuillSimpleToolbar(controller: _controller),
          const Divider(height: 1),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: QuillEditor(
                controller: _controller,
                scrollController: ScrollController(),
                //scrollable: true,
                //readOnly: false,
                config: QuillEditorConfig(
                  autoFocus: true,
                 scrollable: true,
                  expands: true,
                  padding: EdgeInsets.zero,
                ),
                focusNode: FocusNode(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}*/

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:shared_preferences/shared_preferences.dart';

class NotepadPage extends StatefulWidget {
  final String subjectId;
  final String chapter;

  const NotepadPage({
    super.key,
    required this.subjectId,
    required this.chapter,
  });

  @override
  State<NotepadPage> createState() => _NotepadPageState();
}

class _NotepadPageState extends State<NotepadPage> {
  late quill.QuillController _controller;
  bool _isLoading = true;
  late final String _noteKey;

  @override
  void initState() {
    super.initState();
    _noteKey = 'quill_notes_${widget.subjectId}_${widget.chapter}';
    _loadNote();
  }

  Future<void> _loadNote() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString(_noteKey);

    if (savedJson != null) {
      try {
        final doc = quill.Document.fromJson(jsonDecode(savedJson));
        _controller = quill.QuillController(document: doc, selection: const TextSelection.collapsed(offset: 0));
      } catch (_) {
        _controller = quill.QuillController.basic();
      }
    } else {
      _controller = quill.QuillController.basic();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _saveNote() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonData = jsonEncode(_controller.document.toDelta().toJson());
    await prefs.setString(_noteKey, jsonData);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Note saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes: ${widget.chapter}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          quill.QuillSimpleToolbar(controller: _controller),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              child: quill.QuillEditor.basic(
                controller: _controller,

              //  readOnly: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
