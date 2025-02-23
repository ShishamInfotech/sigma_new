class TargetDatesModel {
  String? subjectName;
  String? targetDates;
  int? presentStatus;
  int? daysRemaining;

  TargetDatesModel(
      {this.subjectName,
      this.targetDates,
      this.presentStatus,
      this.daysRemaining});

  TargetDatesModel.fromJson(Map<String, dynamic> json) {
    subjectName = json['subject_name'];
    targetDates = json['target_dates'];
    presentStatus = json['present_status'];
    daysRemaining = json['days_remaining'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['subject_name'] = subjectName;
    data['target_dates'] = targetDates;
    data['present_status'] = presentStatus;
    data['days_remaining'] = daysRemaining;
    return data;
  }
}
