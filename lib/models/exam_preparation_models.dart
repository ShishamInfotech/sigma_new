class ExamPreparationModels {
  int color = 0;
  String title = '0';
  String imagePath = '0';
  String? navigation;

  ExamPreparationModels(
      {required this.color,
      required this.title,
      required this.imagePath,
      this.navigation});

  ExamPreparationModels.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    title = json['title'];
    imagePath = json['image_path'];
    navigation = json['navigation'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    data['title'] = title;
    data['image_path'] = imagePath;
    data['navigation'] = navigation;
    return data;
  }
}
