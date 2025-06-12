
class SubCahpDatum {
  String? subject;
  String? subchapterid;
  String? subchapter;
  String? subchapterNumber;
  String? description;
  String? questionSerialNumber;
  String? questionImageId;
  String? descriptionImageId;
  String? testanswerstring;
  String? explainationVideoId;
  String? complexity;
  String? medium;
  String? subchapterPartNumber;
  String? contentcode;
  String? question;
  String? option1;
  String? option2;
  String? option3;
  String? option4;
  String? option5;
  String? answer;
  String? ansExplaination;

  SubCahpDatum({
    this.subchapterid,
    this.subchapter,
    this.subchapterNumber,
    this.description,
    this.questionSerialNumber,
    this.questionImageId,
    this.descriptionImageId,
    this.testanswerstring,
    this.explainationVideoId,
    this.complexity,
    this.medium,
    this.subchapterPartNumber,
    this.contentcode,
    this.question,
    this.option1,
    this.option2,
    this.option3,
    this.option4,
    this.option5,
    this.answer,
    this.ansExplaination,
    this.subject,
  });

  factory SubCahpDatum.fromJson(Map<String, dynamic> json) => SubCahpDatum(
    subchapterid: json['subchapterid'],
    subchapter: json['subchapter'],
    subchapterNumber: json['subchapter_number'],
    description: json['description'],
    questionSerialNumber: json['question_serial_number'],
    questionImageId: json['question_image_id'],
    descriptionImageId: json['description_image_id'],
    testanswerstring: json['test_answer_string'],
    explainationVideoId: json['explaination_video_id'],
    complexity: json['complexity'],
    medium: json['medium'],
    subchapterPartNumber: json['subchapter_part_number'],
    contentcode: json['contentcode'],
    question: json['question'],
    option1: json['option_1'],
    option2: json['option_2'],
    option3: json['option_3'],
    option4: json['option_4'],
    option5: json['option_5'],
    answer: json['answer'],
    ansExplaination: json['ans_explaination'],
    subject: json["subject"],
  );

  Map<String, dynamic> toJson() => {
    'subchapterid': subchapterid,
    'subchapter': subchapter,
    'subchapter_number': subchapterNumber,
    'description': description,
    'question_serial_number': questionSerialNumber,
    'question_image_id': questionImageId,
    'description_image_id': descriptionImageId,
    'test_answer_string': testanswerstring,
    'explaination_video_id': explainationVideoId,
    'complexity': complexity,
    'medium': medium,
    'subchapter_part_number': subchapterPartNumber,
    'contentcode': contentcode,
    'question': question,
    'option_1': option1,
    'option_2': option2,
    'option_3': option3,
    'option_4': option4,
    'option_5': option5,
    'answer': answer,
    'ans_explaination': ansExplaination,
    "subject": subject,
  };
}
