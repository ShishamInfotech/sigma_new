import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

@JsonSerializable(explicitToJson: true)
class Config {
  @JsonKey(name: 'timestamp')
  String? timestamp;

  @JsonKey(name: 'BuildVersion')
  String? buildVersion;

  @JsonKey(name: 'DeviceID')
  String? deviceID;

  @JsonKey(name: 'ExpiryDate')
  String? expiryDate;

  @JsonKey(name: 'StartDate')
  String? startDate;

  @JsonKey(name: 'Type')
  String? type;

  @JsonKey(name: 'navigation')
  List<String>? navigation;

  @JsonKey(name: 'navigation_logo')
  List<String>? navigationLogo;

  @JsonKey(name: 'navigation_pdf')
  List<String>? navigationPdf;

  @JsonKey(name: 'class')
  List<String>? class_;

  @JsonKey(name: 'copyright')
  String? copyright;

  Config({
    this.timestamp,
    this.buildVersion,
    this.deviceID,
    this.expiryDate,
    this.startDate,
    this.type,
    this.navigation,
    this.navigationLogo,
    this.navigationPdf,
    this.class_,
    this.copyright,
  });

  // JSON serialization and deserialization
  factory Config.fromJson(Map<String, dynamic> json) => _$ConfigFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigToJson(this);
}
