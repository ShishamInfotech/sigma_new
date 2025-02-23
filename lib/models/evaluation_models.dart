class EvaluationModels {
  int color = 0;
  String subject = '0';
  String level = '0';
  int score = 0;

  EvaluationModels({
    required this.color,
    required this.subject,
    required this.level,
    required this.score,
  });

  EvaluationModels.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    subject = json['subject'];
    level = json['image_path'];
    score = json['score'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    data['subject'] = subject;
    data['level'] = level;
    data['score'] = score;

    return data;
  }
}
