// lib/config_loader.dart
import 'dart:convert';
import 'package:sigma_new/utility/sd_card_utility.dart';
import 'package:sigma_new/utility/crypto_utils.dart';
import 'package:sigma_new/config/config.dart';

/// Model for Standard configuration
class EnrolConfigStandard {
  final String stdID;
  final String name;
  EnrolConfigStandard({required this.stdID, required this.name});
  factory EnrolConfigStandard.fromJson(Map<String, dynamic> json) {
    return EnrolConfigStandard(
      stdID: json['StdID'] as String,
      name: json['Name'] as String,
    );
  }
}

/// Wrapper for Standard config file
class EnrolConfigStandardModal {
  final List<EnrolConfigStandard> sigmaData;
  EnrolConfigStandardModal({required this.sigmaData});
  factory EnrolConfigStandardModal.fromJson(Map<String, dynamic> json) {
    return EnrolConfigStandardModal(
      sigmaData: (json['sigma_data'] as List<dynamic>)
          .map((e) => EnrolConfigStandard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model for Board configuration
class EnrolConfigBoard {
  final String board;
  final String boardKey;
  EnrolConfigBoard({required this.board, required this.boardKey});
  factory EnrolConfigBoard.fromJson(Map<String, dynamic> json) {
    return EnrolConfigBoard(
      board: json['Board'] as String,
      boardKey: json['BoardKey'] as String,
    );
  }
}

/// Wrapper for Board config file
class EnrolConfigBoardModal {
  final List<EnrolConfigBoard> sigmaData;
  EnrolConfigBoardModal({required this.sigmaData});
  factory EnrolConfigBoardModal.fromJson(Map<String, dynamic> json) {
    return EnrolConfigBoardModal(
      sigmaData: (json['sigma_data'] as List<dynamic>)
          .map((e) => EnrolConfigBoard.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Model for Courses configuration
class EnrolConfigCourses {
  final String stdBoardKey;
  final String courseID;
  final String course;
  EnrolConfigCourses({required this.stdBoardKey, required this.courseID, required this.course});
  factory EnrolConfigCourses.fromJson(Map<String, dynamic> json) {
    return EnrolConfigCourses(
      stdBoardKey: json['StdBoard_Key'] as String,
      courseID: json['CourseID'] as String,
      course: json['Course'] as String,
    );
  }
}

/// Wrapper for Courses config file
class EnrolConfigCoursesModal {
  final List<EnrolConfigCourses> sigmaData;
  EnrolConfigCoursesModal({required this.sigmaData});
  factory EnrolConfigCoursesModal.fromJson(Map<String, dynamic> json) {
    return EnrolConfigCoursesModal(
      sigmaData: (json['sigma_data'] as List<dynamic>)
          .map((e) => EnrolConfigCourses.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Loader for enrollment configurations.
class ConfigLoader {
  static const String keyString = '1234567890123456'; // Use your actual key

  /// Loads, decrypts, and parses the Standard configuration file.
  static Future<List<EnrolConfigStandard>?> getEnrolConfigStandard() async {
    final inputFile = await SdCardUtility.loadFileAsFile('EnrolConfig_standard.json');
    if (inputFile == null) {
      print("Enrollment Standard config not found");
      return null;
    }
    String decrypted;
    try {
      decrypted = await CryptoUtils.decryptStream(keyString, inputFile);
      print("Decrypted EnrolConfig_standard: $decrypted");
    } catch (e) {
      print("Decryption failed for EnrolConfig_standard: $e");
      return null;
    }
    try {
      final jsonData = jsonDecode(decrypted);
      final modal = EnrolConfigStandardModal.fromJson(jsonData);
      return modal.sigmaData;
    } catch (e) {
      print("Error parsing EnrolConfig_standard: $e");
      return null;
    }
  }

  /// Loads, decrypts, and parses the Board configuration file.
  static Future<List<EnrolConfigBoard>?> getEnrolConfigBoard() async {
    final inputFile = await SdCardUtility.loadFileAsFile('EnrolConfig_Board.json');
    if (inputFile == null) {
      print("Enrollment Board config not found");
      return null;
    }
    String decrypted;
    try {
      decrypted = await CryptoUtils.decryptStream(keyString, inputFile);
      print("Decrypted EnrolConfig_Board: $decrypted");
    } catch (e) {
      print("Decryption failed for EnrolConfig_Board: $e");
      return null;
    }
    try {
      final jsonData = jsonDecode(decrypted);
      final modal = EnrolConfigBoardModal.fromJson(jsonData);
      return modal.sigmaData;
    } catch (e) {
      print("Error parsing EnrolConfig_Board: $e");
      return null;
    }
  }

  /// Loads, decrypts, and parses the Courses configuration file.
  static Future<List<EnrolConfigCourses>?> getEnrolConfigCourses() async {
    final inputFile = await SdCardUtility.loadFileAsFile('EnrolConfig_Courses.json');
    if (inputFile == null) {
      print("Enrollment Courses config not found");
      return null;
    }
    String decrypted;
    try {
      decrypted = await CryptoUtils.decryptStream(keyString, inputFile);
      print("Decrypted EnrolConfig_Courses: $decrypted");
    } catch (e) {
      print("Decryption failed for EnrolConfig_Courses: $e");
      return null;
    }
    try {
      final jsonData = jsonDecode(decrypted);
      final modal = EnrolConfigCoursesModal.fromJson(jsonData);
      return modal.sigmaData;
    } catch (e) {
      print("Error parsing EnrolConfig_Courses: $e");
      return null;
    }
  }

static Future<Config?> getGlobalConfig() async {
    //String content = await SdCardUtility.loadFile('config.json');
    final inputFile = await SdCardUtility.loadFileAsFile('config.json');
    if (inputFile== null) {
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
}
