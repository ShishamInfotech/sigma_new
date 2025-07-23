import 'package:sigma_new/models/sub_cahp_datum.dart';

class ChapterModel {
  List<SubCahpDatum>? subCahpData;

  ChapterModel({this.subCahpData});

  factory ChapterModel.fromJson(Map<String, dynamic> json) => ChapterModel(
    subCahpData: (json['sub_cahp_data'] as List?)
        ?.map((e) => SubCahpDatum.fromJson(e))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'sub_cahp_data': subCahpData?.map((e) => e.toJson()).toList(),
  };
}