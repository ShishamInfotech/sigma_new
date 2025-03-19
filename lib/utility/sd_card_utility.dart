// lib/utils/sd_card_utility.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:sigma_new/utility/crypto_utils.dart';
import 'constants.dart';

class SdCardUtility {
  /// Request storage permission.
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  /// Request manage external storage permission (if needed).
  static Future<bool> requestManageStoragePermission() async {
    var status = await Permission.manageExternalStorage.request();
    return status.isGranted;
  }

  /// Returns the base path to use.
  /// First, checks external storage directories (using external_path) for a removable SD card
  /// that contains the sigma folder. If not found, falls back to internal application documents.
  static Future<String> getBasePath() async {
    // First, try to get removable storage.
    try {
      List<String> extPaths = await ExternalPath.getExternalStorageDirectories();
      print("External paths: $extPaths");
      for (String path in extPaths) {
        if (!path.toLowerCase().contains("emulated")) {
          final sigmaDir = Directory("$path/${Constants.SIGMA_DIR}");
          if (await sigmaDir.exists()) {
            print("Sigma folder found on removable SD card: ${sigmaDir.path}");
            return sigmaDir.path;
          }
        }
      }
      // If none found, try the primary external directory.
      if (extPaths.isNotEmpty) {
        final sigmaDir = Directory("${extPaths.first}/${Constants.SIGMA_DIR}");
        if (await sigmaDir.exists()) {
          print("Sigma folder found on primary external storage: ${sigmaDir.path}");
          return sigmaDir.path;
        }
      }
    } catch (e) {
      print("Error checking external storage: $e");
    }
    // Fallback: use application documents directory.
    try {
      Directory localDir = await getApplicationDocumentsDirectory();
      String localSigmaPath = "${localDir.path}/${Constants.SIGMA_DIR}";
      Directory sigmaDirLocal = Directory(localSigmaPath);
      if (await sigmaDirLocal.exists()) {
        print("Sigma folder found in local storage: $localSigmaPath");
        return sigmaDirLocal.path;
      } else {
        print("Sigma folder not found in local storage. Creating one at: $localSigmaPath");
        await sigmaDirLocal.create(recursive: true);
        return sigmaDirLocal.path;
      }
    } catch (e) {
      print("Error checking local storage: $e");
    }
    return "";
  }

  /// Unified method to load a file from the sigma folder.
  /// [relativePath] is relative to the sigma folder (e.g. "config.json" or "EnrolConfig_standard.json").
  static Future<String> loadFile(String relativePath) async {
    String fileContent = '';
    try {
      String basePath = await getBasePath();
      if (basePath.isNotEmpty) {
        File externalFile = File('$basePath/$relativePath');
        if (await externalFile.exists()) {
          try {
            fileContent = await externalFile.readAsString(encoding: utf8);
            print('File read as string: ${externalFile.path}');
            return fileContent;
          } on FileSystemException catch (e) {
            print('Failed to decode as UTF-8, reading as bytes: $e');
            final bytes = await externalFile.readAsBytes();
            fileContent = base64Encode(bytes);
            print('File read as bytes and converted to Base64: ${externalFile.path}');
            return fileContent;
          }
        } else {
          print('File not found at: ${externalFile.path}. Falling back to assets.');
        }
      }
    } catch (e) {
      print('Error checking storage: $e');
    }
    // Fallback: load from assets
    try {
      fileContent = await rootBundle.loadString('assets/sigma/$relativePath');
      print('File loaded from assets: assets/sigma/$relativePath');
    } catch (e) {
      print('Error loading file from assets: $e');
    }
    return fileContent;
  }

  /// Retrieves intro images from the sigma/intro folder.
  static Future<List<String>?> getIntroImages() async {
    try {
      String basePath = await getBasePath();
      final sigmaDir = Directory('$basePath/${Constants.INTRO_DIR}');
      if (await sigmaDir.exists()) {
        if (!await Permission.storage.isGranted) {
          await requestStoragePermission();
        }
        List<FileSystemEntity> fileList = sigmaDir.listSync();
        if (fileList.isNotEmpty) {
          List<String> filePaths = fileList
              .whereType<File>()
              .map((file) => file.path)
              .toList()
            ..sort((a, b) => b.compareTo(a));
          print("Intro Image Paths: ${filePaths.toString()}");
          return filePaths;
        }
      } else {
        Get.snackbar("Error", "Sigma/intro Directory Not Found");
      }
    } catch (e) {
      Get.snackbar("Error", "Error Occurred $e");
    }
    return null;
  }

  /// Unified method to load a file from the sigma folder.
  /// [relativePath] is relative to the sigma folder (e.g. "config.json" or "EnrolConfig_standard.json").
  /// Returns a File object.
  static Future<File> loadFileAsFile(String relativePath) async {
    // First, try to load from external/local storage.
    try {
      String basePath = await getBasePath();
      if (basePath.isNotEmpty) {
        File externalFile = File('$basePath/$relativePath');
        if (await externalFile.exists()) {
          print('Found external file: ${externalFile.path}');
          return externalFile;
        } else {
          print('External file not found at: ${externalFile.path}');
        }
      }
    } catch (e) {
      print('Error checking storage: $e');
    }
    // Fallback: load from assets.
    try {
      // Load the asset as ByteData.
      final byteData = await rootBundle.load('assets/sigma/$relativePath');
      // Get a temporary directory to store the file.
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$relativePath');
      // Ensure the directory exists.
      await tempFile.create(recursive: true);
      // Write the asset bytes to the file.
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());
      print('File loaded from assets and written to temporary file: ${tempFile.path}');
      return tempFile;
    } catch (e) {
      print('Error loading file from assets: $e');
      throw Exception('Unable to load file: $relativePath, error: $e');
    }
  }


  static const String sigmaDir = "testseries";
  static const String encryptionKey = "1234567890123456"; // 16-byte key

  static Future<String?> getSubjectEncJsonData(String path) async {
    try {
      // Get base path (like getSdcardName in Java)
      String basePath = await getBasePath();
      if (basePath == null) {
        print("Storage not available.");
        return null;
      }

      print('basePath ${basePath}');

      // Construct full file path
      String fullFilePath = "${basePath}/10/MH/$sigmaDir$path";
      print("Full File Path: $fullFilePath");

      File encryptedFile = File(fullFilePath);
      if (await encryptedFile.exists()) {
        // Read and decrypt file
        String decryptedData = await CryptoUtils.decryptStream(encryptionKey,encryptedFile);
        print("Decrypted Data: $decryptedData");
        return decryptedData;
      } else {
        print("File does not exist.");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }

}



