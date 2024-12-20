class Menu {
  int color = 0;
  String title = '0';
  String imagePath = '0';
  Function()? navigation; // Change type to Function

  Menu({
    required this.color,
    required this.title,
    required this.imagePath,
    this.navigation,
  });

  Menu.fromJson(Map<String, dynamic> json) {
    color = json['color'];
    title = json['title'];
    imagePath = json['image_path'];
    // Navigation cannot be directly serialized, so skip for now
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['color'] = color;
    data['title'] = title;
    data['image_path'] = imagePath;
    // Skipping navigation serialization
    return data;
  }
}
