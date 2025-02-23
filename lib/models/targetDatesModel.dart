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
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['subject_name'] = this.subjectName;
    data['target_dates'] = this.targetDates;
    data['present_status'] = this.presentStatus;
    data['days_remaining'] = this.daysRemaining;
    return data;
  }
}
