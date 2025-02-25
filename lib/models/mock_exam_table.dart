class MockExamTable {
  String? boardExam;
  int? examsAttempted;
  String? level;

  MockExamTable({this.boardExam, this.examsAttempted, this.level});

  MockExamTable.fromJson(Map<String, dynamic> json) {
    boardExam = json['board_exam'];
    examsAttempted = json['exams_attempted'];
    level = json['level'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['board_exam'] = boardExam;
    data['exams_attempted'] = examsAttempted;
    data['level'] = level;
    return data;
  }
}
