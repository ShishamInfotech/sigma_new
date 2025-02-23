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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['color'] = this.color;
    data['subject'] = this.subject;
    data['level'] = this.level;
    data['score'] = this.score;

    return data;
  }
}
