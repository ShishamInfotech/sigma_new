import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sigma_new/models/sub_cahp_datum.dart';

import 'chapter_model.dart';


Future<ChapterModel> loadSubjectQuestions(String path) async {
  try {
    String content;
    if (path.startsWith('assets/')) {
      content = await rootBundle.loadString(path);
    } else {
      final file = File(path);
      content = await file.readAsString();
    }
    return ChapterModel.fromJson(jsonDecode(content));
  } catch (e) {
    print("Error loading questions: $e");
    return ChapterModel();
  }
}

List<SubCahpDatum> filterQuestionsByComplexity(List<SubCahpDatum> list, String level) {
  switch (level) {
    case 'm':
      return list.where((q) => q.complexity == 'Medium').toList();
    case 'c':
      return list.where((q) => q.complexity == 'Complex').toList();
    default:
      return list.where((q) => q.complexity == 'Simple').toList();
  }
}