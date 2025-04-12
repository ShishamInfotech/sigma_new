
import 'subject_info_modal.dart';

class DataModal {
  List<SubjectInfoModal>? subjectData;

  DataModal({this.subjectData});

  factory DataModal.fromJson(Map<String, dynamic> json) => DataModal(
    subjectData: (json['subject_data'] as List<dynamic>?)
        ?.map((e) => SubjectInfoModal.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'subject_data': subjectData?.map((e) => e.toJson()).toList(),
  };
}
