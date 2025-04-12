
class JeeDatum {
  String? subjectNumber;
  String? subject;
  String? subjectid;
  String? stream;
  String? board;
  String? chapter;
  String? chapterid;
  String? chapterNumber;
  String? contentcode;
  String? question;
  String? option1;
  String? option2;
  String? option3;
  String? option4;
  String? option5;
  String? answer;
  String? ansExplaination;
  String? descriptionImageId;
  String? explainationVideoId;
  String? complexity;
  String? medium;

  JeeDatum({
    this.subjectNumber,
    this.subject,
    this.subjectid,
    this.stream,
    this.board,
    this.chapter,
    this.chapterid,
    this.chapterNumber,
    this.contentcode,
    this.question,
    this.option1,
    this.option2,
    this.option3,
    this.option4,
    this.option5,
    this.answer,
    this.ansExplaination,
    this.descriptionImageId,
    this.explainationVideoId,
    this.complexity,
    this.medium,
  });

  factory JeeDatum.fromJson(Map<String, dynamic> json) => JeeDatum(
    subjectNumber: json['subject_number'],
    subject: json['subject'],
    subjectid: json['subjectid'],
    stream: json['stream'],
    board: json['board'],
    chapter: json['chapter'],
    chapterid: json['chapterid'],
    chapterNumber: json['chapter_number'],
    contentcode: json['contentcode'],
    question: json['question'],
    option1: json['option_1'],
    option2: json['option_2'],
    option3: json['option_3'],
    option4: json['option_4'],
    option5: json['option_5'],
    answer: json['answer'],
    ansExplaination: json['ans_explaination'],
    descriptionImageId: json['description_image_id'],
    explainationVideoId: json['explaination_video_id'],
    complexity: json['complexity'],
    medium: json['medium'],
  );

  Map<String, dynamic> toJson() => {
    'subject_number': subjectNumber,
    'subject': subject,
    'subjectid': subjectid,
    'stream': stream,
    'board': board,
    'chapter': chapter,
    'chapterid': chapterid,
    'chapter_number': chapterNumber,
    'contentcode': contentcode,
    'question': question,
    'option_1': option1,
    'option_2': option2,
    'option_3': option3,
    'option_4': option4,
    'option_5': option5,
    'answer': answer,
    'ans_explaination': ansExplaination,
    'description_image_id': descriptionImageId,
    'explaination_video_id': explainationVideoId,
    'complexity': complexity,
    'medium': medium,
  };
}
