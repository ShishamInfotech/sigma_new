// lib/config_loader.dart
import 'dart:convert';
import 'package:sigma_new/config/config.dart';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/utility/crypto_utils.dart';

/// Model for enrollment configuration (from EnrolConfig_standard.json)
class EnrolConfig {
  final String enrollmentTitle;
  final List<String> titleList;
  final List<String> standardList;
  final List<String> boardList;
  final List<String> subjectList;

  EnrolConfig({
    required this.enrollmentTitle,
    required this.titleList,
    required this.standardList,
    required this.boardList,
    required this.subjectList,
  });

  factory EnrolConfig.fromJson(Map<String, dynamic> json) {
    return EnrolConfig(
      enrollmentTitle: json['enrollmentTitle'] as String? ?? 'Register',
      titleList: List<String>.from(json['titleList'] ?? []),
      standardList: List<String>.from(json['standardList'] ?? []),
      boardList: List<String>.from(json['boardList'] ?? []),
      subjectList: List<String>.from(json['subjectList'] ?? []),
    );
  }
}

/// Loader for both global config and enrollment config.
class ConfigLoader {
  static const String keyString = '1234567890123456'; // Adjust to your key

  /// Loads, decrypts, and parses the global configuration file.
  static Future<Config?> getGlobalConfig() async {
    //String content = await SdCardUtility.loadFile('config.json');
    final inputFile = await SdCardUtility.loadFileAsFile('config.json');
    if (inputFile!= null) {
      print("Global config not found");
      return null;
    }

    String decrypted;
    try {
      // Provide your fixed IV here if applicable.
      //decrypted = decryptEncryptedContent(content, keyString: '1234567890123456', fixedIV: 'abcdefghijklmnop');
      decrypted = await CryptoUtils.decryptStream('1234567890123456', inputFile);
      print("Decrypted global config: $decrypted");
    } catch (e) {
      print("Decryption failed: $e");
      return null;
    }

    try {
      final jsonData = jsonDecode(decrypted);
      return Config.fromJson(jsonData);
    } catch (e) {
      print("Error parsing global config: $e");
      return null;
    }
  }

  /// Loads, decrypts, and parses the enrollment configuration file.
  static Future<EnrolConfig?> getEnrolConfig() async {
    //String content = await SdCardUtility.loadFile('EnrolConfig_standard.json');
    final inputFile = await SdCardUtility.loadFileAsFile('EnrolConfig_standard.json');
    if (inputFile== null) {
      print("Enrollment config not found");
      return null;
    }

    String decrypted;
    try {
      //decrypted = decryptEncryptedContent(content, keyString: keyString);
      decrypted = await CryptoUtils.decryptStream('1234567890123456', inputFile);
      print("Decrypted enrollment config: $decrypted");
    } catch (e) {
      print("Decryption failed for enrollment config: $e");
      return null;
    }

    try {
      final jsonData = jsonDecode(decrypted);
      return EnrolConfig.fromJson(jsonData);
    } catch (e) {
      print("Error parsing enrollment config: $e");
      return null;
    }
  }
}
