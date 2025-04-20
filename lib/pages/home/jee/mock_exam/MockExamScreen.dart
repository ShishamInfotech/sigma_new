import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sigma_new/math_view/math_text.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/models/sub_cahp_datum.dart';

class MockExamScreen extends StatefulWidget {
  final String subjectId;
  final String title;
  final String path;

  const MockExamScreen({
    super.key,
    required this.subjectId,
    required this.title,
    required this.path,
  });

  @override
  State<MockExamScreen> createState() => _MockExamScreenState();
}

class _MockExamScreenState extends State<MockExamScreen> {
  late SharedPreferences prefs;

  int currentIndex = 0;
  List<SubCahpDatum> questions = [];
  List<String> selectedAnswers = [];

  final int SUB1_Q_COUNT = 98;
  final int SUB2_Q_COUNT = 52;
  final int SUB3_Q_COUNT = 50;

  final String MAT_FILE_PREFIX = "jeemcqmathch";
  final String PHY_FILE_PREFIX = "jeemcqphych";
  final String CHE_FILE_PREFIX = "jeemcqchech";
  final String BIO_FILE_PREFIX = "jeemcqbioch";

  int totalQueCount = 0;

  int correct = 0;
  int wrong = 0;

  Timer? countdownTimer;
  Duration duration = const Duration(minutes: 120);

  String? selectedOption;
  WebViewController? _questionWebController;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {

    prefs = await SharedPreferences.getInstance();
    await _loadQuestions();
    _startTimer();
  }


  Future<void> _loadQuestions() async {
    totalQueCount = SUB1_Q_COUNT + SUB2_Q_COUNT + SUB3_Q_COUNT;


    List<Uri> mathsFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", MAT_FILE_PREFIX) ?? [];
    List<Uri> phyFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", PHY_FILE_PREFIX) ?? [];
    List<Uri> cheFiles = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", CHE_FILE_PREFIX) ?? [];

    final mathUri = FileUri(
      files: mathsFiles,
      perChapterCount: mathsFiles.isNotEmpty ? SUB1_Q_COUNT ~/ mathsFiles.length : 0,
      remainCount: mathsFiles.isNotEmpty ? SUB1_Q_COUNT % mathsFiles.length : 0,
    );

    final phyUri = FileUri(
      files: phyFiles,
      perChapterCount: phyFiles.isNotEmpty ? SUB2_Q_COUNT ~/ phyFiles.length : 0,
      remainCount: phyFiles.isNotEmpty ? SUB2_Q_COUNT % phyFiles.length : 0,
    );

    final cheUri = FileUri(
      files: cheFiles,
      perChapterCount: cheFiles.isNotEmpty ? SUB3_Q_COUNT ~/ cheFiles.length : 0,
      remainCount: cheFiles.isNotEmpty ? SUB3_Q_COUNT % cheFiles.length : 0,
    );

    final List<SubCahpDatum> selectedQuestions = [];

    for (var uriGroup in [mathUri, phyUri, cheUri]) {
      for (int i = 0; i < uriGroup.files.length; i++) {
        final file = uriGroup.files[i];
        final jsonStr = await SdCardUtility.getSubjectEncJsonDataForMock(file.path);
        if (jsonStr == null) continue;

        final decoded = jsonDecode(jsonStr);

        if (decoded == null || decoded['sigma_data'] == null) {
          continue; // Skip if no questions in this file
        }
        final sigmaList = decoded['sigma_data'] as List<dynamic>;

        final questionList = sigmaList.map((e) => SubCahpDatum.fromJson(e)).toList();
        questionList.shuffle(); // Randomize

        int takeCount = uriGroup.perChapterCount + (i < uriGroup.remainCount ? 1 : 0);
        selectedQuestions.addAll(questionList.take(takeCount));
      }
    }

    selectedQuestions.shuffle(); // Mix all subjects together

    setState(() {
      questions = selectedQuestions;
      _loadMathJax(questions.first.question ?? '');
    });

    print("Total questions loaded: ${questions.length}");
  }

  /*Future<void> _loadQuestions() async {
    totalQueCount = SUB1_Q_COUNT + SUB2_Q_COUNT + SUB3_Q_COUNT;

    List<Uri> mathsFile = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", MAT_FILE_PREFIX) ?? [];
    List<Uri> phyFile = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", PHY_FILE_PREFIX) ?? [];
    List<Uri> cheFile = await SdCardUtility.getFileListBasedOnPref(context, "JEE/MCQ", CHE_FILE_PREFIX) ?? [];

    print("Maths File $mathsFile");
    final jsonStr = await SdCardUtility.getSubjectEncJsonData(widget.path);
    if (jsonStr == null) return;

    final decoded = jsonDecode(jsonStr);
    final sigmaList = decoded['sigma_data'] as List<dynamic>;

    setState(() {
      questions = sigmaList.map((e) => SubCahpDatum.fromJson(e)).toList();
      _loadMathJax(questions.first.question ?? '');
    });

    print("Question List ${questions}");
  }*/

  void _startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration.inSeconds == 0) {
        timer.cancel();
        _showResultPopup();
      } else {
        setState(() {
          duration -= const Duration(seconds: 1);
        });
      }
    });
  }

  void _submitAnswer(String answer) {
    if (questions.isEmpty) return;

    final current = questions[currentIndex];
    selectedAnswers.add(answer);

    if (answer.trim() == current.answer?.trim()) {
      correct++;
    } else {
      wrong++;
    }

    if (currentIndex + 1 < questions.length) {
      setState(() {
        currentIndex++;
        selectedOption = null;
        _loadMathJax(questions[currentIndex].question ?? '');
      });
    } else {
      countdownTimer?.cancel();
      _showResultPopup();
    }
  }

  void _loadMathJax(String latex) {
    final htmlContent = '''
      <html>
        <head>
          <script type="text/x-mathjax-config">
            MathJax.Hub.Config({
              tex2jax: {inlineMath: [['\$','\$'], ['\\(','\\)']]},
              showMathMenu: false
            });
          </script>
          <script src="assets/mathjax/MathJax.js?config=TeX-AMS-MML_HTMLorMML"></script>
        </head>
        <body style="font-size:18px;">\$${latex}\$</body>
      </html>
    ''';

    _questionWebController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = questions[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Time Left: ${duration.inMinutes.toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Question ${currentIndex + 1} of ${questions.length}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _questionWebController != null
                ? WebViewWidget(controller: _questionWebController!)
                : const SizedBox(),
          ),
          ...List.generate(5, (index) {
            final opt = question.toJson()['option_${index + 1}'];
            if (opt == null || opt.toString().trim().isEmpty) return const SizedBox();
            return ListTile(
              title: MathText(expression: opt, height: 20,),
              leading: Radio<String>(
                value: opt,
                groupValue: selectedOption,
                onChanged: (value) {
                  setState(() {
                    selectedOption = value;
                  });
                },
              ),
            );
          }),
          Center(
            child: ElevatedButton(
              onPressed: selectedOption != null ? () => _submitAnswer(selectedOption!) : null,
              child: const Text("Submit Answer"),
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _showResultPopup() async {
    final total = prefs.getInt('test_complete') ?? 0;
    final high = prefs.getInt('test_high_score') ?? 0;
    final totalScore = prefs.getInt('test_total_score') ?? 0;

    prefs.setInt('test_complete', total + 1);
    prefs.setInt('test_total_score', totalScore + correct);
    if (correct > high) prefs.setInt('test_high_score', correct);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Test Completed"),
        content: Text("Correct: $correct\nWrong: $wrong"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    super.dispose();
  }
}


class FileUri {
  final List<Uri> files;
  final int perChapterCount;
  final int remainCount;

  FileUri({
    required this.files,
    required this.perChapterCount,
    required this.remainCount,
  });
}
