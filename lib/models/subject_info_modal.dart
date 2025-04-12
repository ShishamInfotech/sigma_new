
class SubjectInfoModal {
  String? subjectNumber;
  String? subjectid;
  String? subject;
  String? stream;
  String? board;
  Map<String, String>? chapter;
  Map<String, String>? subchapter;

  SubjectInfoModal({
    this.subjectNumber,
    this.subjectid,
    this.subject,
    this.stream,
    this.board,
    this.chapter,
    this.subchapter,
  });

  factory SubjectInfoModal.fromJson(Map<String, dynamic> json) => SubjectInfoModal(
    subjectNumber: json['subject_number'],
    subjectid: json['subjectid'],
    subject: json['subject'],
    stream: json['stream'],
    board: json['board'],
    chapter: Map<String, String>.from(json['chapter'] ?? {}),
    subchapter: Map<String, String>.from(json['subchapter'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'subject_number': subjectNumber,
    'subjectid': subjectid,
    'subject': subject,
    'stream': stream,
    'board': board,
    'chapter': chapter,
    'subchapter': subchapter,
  };
}
