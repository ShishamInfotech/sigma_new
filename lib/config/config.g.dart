// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Config _$ConfigFromJson(Map<String, dynamic> json) => Config(
      timestamp: json['timestamp'] as String?,
      buildVersion: json['BuildVersion'] as String?,
      deviceID: json['DeviceID'] as String?,
      expiryDate: json['ExpiryDate'] as String?,
      startDate: json['StartDate'] as String?,
      type: json['Type'] as String?,
      navigation: (json['navigation'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      navigationLogo: (json['navigation_logo'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      navigationPdf: (json['navigation_pdf'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      class_:
          (json['class'] as List<dynamic>?)?.map((e) => e as String).toList(),
      copyright: json['copyright'] as String?,
    );

Map<String, dynamic> _$ConfigToJson(Config instance) => <String, dynamic>{
      'timestamp': instance.timestamp,
      'BuildVersion': instance.buildVersion,
      'DeviceID': instance.deviceID,
      'ExpiryDate': instance.expiryDate,
      'StartDate': instance.startDate,
      'Type': instance.type,
      'navigation': instance.navigation,
      'navigation_logo': instance.navigationLogo,
      'navigation_pdf': instance.navigationPdf,
      'class': instance.class_,
      'copyright': instance.copyright,
    };
