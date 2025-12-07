
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:sigma_new/pages/text_answer/text_answer.dart';
import 'package:sigma_new/ui_helper/constant.dart';

import '../../../../utility/sd_card_utility.dart';
import '../../../notepad/noteswrite.dart';

class SimpleQuestions extends StatefulWidget {
  final List<dynamic> easyQuestion;

  SimpleQuestions({required this.easyQuestion, super.key});

  @override
  State<SimpleQuestions> createState() => _SimpleQuestionsState();
}


class _SimpleQuestionsState extends State<SimpleQuestions> with AutomaticKeepAliveClientMixin {
  Map<int, String?> selectedAnswers = {}; // Store selected answers per question
  Map<int, bool?> answerResults = {}; // Store correct/wrong status per question

  String? baseImagePath; // make nullable and guard until set

  final int _pageSize = 20;
  int _loadedCount = 0;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // initialize loaded count based on initial list (may be zero, we'll update later)
    _loadedCount = widget.easyQuestion.length > _pageSize ? _pageSize : widget.easyQuestion.length;
    _scrollController = ScrollController()..addListener(_onScroll);
    getBasetree();
  }

  // This is the important bit: when parent updates the questions (e.g., after async load),
  // update the loaded count so the list shows items.
  @override
  void didUpdateWidget(covariant SimpleQuestions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.easyQuestion != widget.easyQuestion) {
      final newLen = widget.easyQuestion.length;
      final newLoaded = newLen > _pageSize ? _pageSize : newLen;
      // If previously 0 and now we have items, update _loadedCount and refresh UI
      if (newLoaded != _loadedCount) {
        setState(() {
          _loadedCount = newLoaded;
        });
      }
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore() {
    if (_loadedCount >= widget.easyQuestion.length) return;
    final remaining = widget.easyQuestion.length - _loadedCount;
    final add = remaining > _pageSize ? _pageSize : remaining;
    setState(() {
      _loadedCount += add;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _precacheImages(List<String> urls) {
    if (baseImagePath == null || baseImagePath!.isEmpty) return;
    for (final url in urls) {
      precacheImage(FileImage(File('${baseImagePath!}/$url')), context);
    }
  }

  getBasetree() async {
    print("Get Base Tress");
    baseImagePath = await SdCardUtility.getBasePath();
    print("PAtyh $baseImagePath");
    setState(() {}); // Trigger rebuild once base path is set
  }

  @override
  bool get wantKeepAlive => false;

  @override
  Widget build(BuildContext context) {
    super.build(context); // IMPORTANT when using AutomaticKeepAliveClientMixin

    // If base path not ready yet, show loading
    if (baseImagePath == null || baseImagePath!.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // If there are no questions at all, show a friendly empty state
    if (widget.easyQuestion.isEmpty) {
      return const Center(child: Text('No questions available'));
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      cacheExtent: 400, // reduce if still heavy, default can be large on some devices
      addAutomaticKeepAlives: false, // avoid keeping all items alive
      addRepaintBoundaries: true,
      itemCount: _loadedCount,
      itemBuilder: (context, index) {
        final questionData = widget.easyQuestion[index];
        return QuestionItem(
          key: ValueKey(questionData['contentcode'] ?? index),
          index: index,
          questionData: questionData,
          baseImagePath: baseImagePath ?? '',
          onBookmarkToggled: (id) => toggleBookmark(id),
        );
      },
    );

  }

  Future<bool> isBookmarked(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarked = prefs.getStringList('bookmarks') ?? [];
    return bookmarked.contains(id);
  }

  Future<void> toggleBookmark(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarked = prefs.getStringList('bookmarks') ?? [];
    if (bookmarked.contains(id)) {
      bookmarked.remove(id);
    } else {
      bookmarked.add(id);
    }
    await prefs.setStringList('bookmarks', bookmarked);
    setState(() {});
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey.shade200,
        foregroundColor: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      icon: Icon(icon, size: 18, color: blackColor),
      label: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
      onPressed: onPressed,
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 1),
    ));
  }

  double _estimateHeight(String text) {
    if (text.isEmpty) return 0;

    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');

    double height = (lines + longLines) * 30.0;
    height = height * 4.0;

    if (hasComplexMath) {
      height += 30.0;
    }

    return height.clamp(50.0, 300.0);
  }

  double _estimateOptionsHeight(String text) {
    if (text.isEmpty) return 0;

    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((line) => line.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt');

    double height = (lines + longLines) * 40.0;

    if (hasComplexMath) {
      height += 40.0;
    }

    return height.clamp(50.0, 300.0);
  }
}

class QuestionItem extends StatefulWidget {
  final int index;
  final Map<String, dynamic> questionData;
  final String baseImagePath;
  final void Function(String id) onBookmarkToggled;

  const QuestionItem({
    Key? key,
    required this.index,
    required this.questionData,
    required this.baseImagePath,
    required this.onBookmarkToggled,
  }) : super(key: key);

  @override
  State<QuestionItem> createState() => _QuestionItemState();
}

class _QuestionItemState extends State<QuestionItem> {
  String? _selected;
  bool _submitted = false;
  bool _bookmarked = false;

  @override
  void initState() {
    super.initState();
    // We don't await isBookmarked here (no access to parent prefs function). Optional: async check
  }

  void _submit(String correctAnswer) {
    setState(() => _submitted = true);
    final isCorrect = _selected == correctAnswer;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isCorrect ? "✅ Correct!" : "❌ Wrong! Correct Answer: $correctAnswer"),
        backgroundColor: isCorrect ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questionData;
    final question = q['question'] ?? '';
    final correct = q['answer'] ?? '';

    // Build options list
    final options = <String>[];
    for (int i = 1; i <= 5; i++) {
      final key = 'option_$i';
      if (q[key] != null && q[key] != 'NA') options.add(q[key] as String);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row with question number + math view
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('${widget.index + 1}.', style: primaryColor16w500TextStyleInter),
              ),
              Expanded(
                child: RepaintBoundary(
                  // Avoid repainting whole list when something outside changes
                  child: MathText(
                    expression: question,
                    height: _estimateHeightStatic(question),
                    basePath: widget.baseImagePath,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Options
          Column(
            children: options.map((option) {
              final isCorrect = option == correct;
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black),
                  color: _submitted
                      ? (isCorrect
                      ? Colors.green.withOpacity(0.15)
                      : (_selected == option ? Colors.red.withOpacity(0.15) : Colors.transparent))
                      : Colors.transparent,
                ),
                child: RadioListTile<String>(
                  title: MathText(expression: option, height: _estimateOptionsHeightStatic(option), basePath: widget.baseImagePath),
                  value: option,
                  groupValue: _selected,
                  onChanged: _submitted ? null : (v) => setState(() => _selected = v),
                ),
              );
            }).toList(),
          ),

          if (_selected != null && !_submitted)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
                onPressed: () => _submit(correct),
                child: const Text('Submit'),
              ),
            ),

          if (_submitted)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: primaryColor),
                  onPressed: () {
                    Get.to(TextAnswer(imagePath: q['ans_explaination'], title: 'MCQ', stream: q['stream'], basePath: 'nr'));
                  },
                  icon: const Icon(Icons.article, size: 18),
                  label: const Text('Text Answer'),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: primaryColor),
                  onPressed: () => Get.to(() => NotepadPage(subjectId: q['contentcode'].toString(), chapter: q['chapter'] ?? 'chapter')),
                  icon: const Icon(Icons.note_add, size: 18),
                  label: const Text('Notepad'),
                ),
                TextButton(onPressed: () {
                  final id = q['contentcode'].toString();
                  widget.onBookmarkToggled(id);
                  setState(() => _bookmarked = !_bookmarked);
                }, child: Text(_bookmarked ? 'Unbookmark' : 'Bookmark')),
              ],
            ),

          const Divider(color: primaryColor, thickness: 1.5, indent: 5, endIndent: 5),
        ],
      ),
    );
  }

  // Local static estimators to avoid closure capture of parent methods
  double _estimateHeightStatic(String text) {
    if (text.isEmpty) return 50;
    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((l) => l.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt') || text.contains(r'\(');
    double h = (lines + longLines) * 30.0;
    h = h * 2.2;
    if (hasComplexMath) h += 30.0;
    return h.clamp(50.0, 300.0);
  }

  double _estimateOptionsHeightStatic(String text) {
    if (text.isEmpty) return 50;
    final lines = text.split('\n').length;
    final longLines = text.split('\n').where((l) => l.length > 50).length;
    final hasComplexMath = text.contains(r'\frac') || text.contains(r'\sqrt');
    double h = (lines + longLines) * 30.0;
    if (hasComplexMath) h += 40.0;
    return h.clamp(50.0, 200.0);
  }
}
