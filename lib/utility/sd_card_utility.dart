import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sigma_new/config/config.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:external_path/external_path.dart';

class SdCardUtility {
  /// Lists files on the SD card (external storage).
  static Future<void> listFilesOnSDCard() async {
    if (await requestStoragePermission()) {
      try {
        // Using external_path to get all external storage directories.
        List<String> directories = await ExternalPath.getExternalStorageDirectories();
        if (directories.isNotEmpty) {
          for (var dirPath in directories) {
            print('Checking Directory: $dirPath');
            final files = Directory(dirPath).listSync();
            for (var file in files) {
              print('File: ${file.path}');
            }
          }
        } else {
          print('No accessible external directories found.');
        }
      } catch (e) {
        print('Error accessing directories: $e');
      }
    }
  }

  /// Requests storage permission.
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      print('Storage permission denied.');
      return false;
    }
  }

  /// Returns the base path to use.
  /// First checks for a removable SD card (non-emulated) containing the "sigma" folder.
  /// If not found, falls back to primary external storage or local storage.
  static Future<String> getBasePath() async {
    // Check external storage using the external_path package.
    try {
      List<String> extPaths = await ExternalPath.getExternalStorageDirectories();
      print("External paths: $extPaths");
      // Look for a removable storage (non-emulated).
      for (String path in extPaths) {
        if (!path.toLowerCase().contains("emulated")) {
          Directory sigmaDir = Directory("$path/sigma");
          if (await sigmaDir.exists()) {
            print("Sigma folder found on removable SD card: ${sigmaDir.path}");
            return sigmaDir.path;
          }
        }
      }
      // If no removable storage found, check the primary external storage.
      if (extPaths.isNotEmpty) {
        Directory sigmaDir = Directory("${extPaths.first}/sigma");
        if (await sigmaDir.exists()) {
          print("Sigma folder found on primary external storage: ${sigmaDir.path}");
          return sigmaDir.path;
        }
      }
    } catch (e) {
      print("Error checking external storage: $e");
    }
    // Fallback: Check local storage.
    try {
      Directory localDir = await getApplicationDocumentsDirectory();
      String localSigmaPath = "${localDir.path}/sigma";
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
    // If nothing is found, return an empty string.
    return "";
  }

  /// Checks if the "sigma" folder exists on the determined base path.
  static Future<bool> isSigmaDirAvl() async {
    try {
      String basePath = await getBasePath();
      if (basePath.isEmpty) {
        Get.snackbar("Error", "No SD Card or local storage found for sigma folder");
        return false;
      }
      final sigmaDir = Directory(basePath);
      print("Sigma Directory exists: ${await sigmaDir.exists()}");
      if (await sigmaDir.exists()) {
        Get.snackbar("Done", "Sigma folder found", backgroundColor: redColor, snackPosition: SnackPosition.TOP);
        return true;
      } else {
        print("Sigma Directory Not Found.");
        Get.snackbar("Error", "Sigma Directory Not Found!");
        return false;
      }
    } catch (e) {
      print("Error: $e");
      Get.snackbar("Error", "An error occurred: $e");
      return false;
    }
  }

  /// Retrieves a list of intro images from the sigma folder.
  static Future<List<String>?> getIntroImages() async {
    try {
      String basePath = await getBasePath();
      const String introDir = "intro";
      final sigmaDir = Directory('$basePath/$introDir');
      if (await sigmaDir.exists()) {
        if (!await Permission.storage.isGranted) {
          print("Storage permission not granted!");
          // Optionally, request permission here.
          if (await requestStoragePermission()){

          }

        }
        List<FileSystemEntity> fileList = sigmaDir.listSync();
        if (fileList.isNotEmpty) {
          List<String> filePaths = fileList
              .whereType<File>()
              .map((file) => file.path)
              .toList()
            ..sort((a, b) => b.compareTo(a));
          print("Intro Image Paths: ${jsonEncode(filePaths)}");
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

  /// Checks if JSON data is available at the given relative path.
  /// The provided [path] is relative to the sigma folder.
  Future<bool> isJsonDataAvl(String path) async {
    try {
      String basePath = await getBasePath();
      const String tagSigmaJson = "sigma.json";
      final sigmaJsonFile = File('$basePath/$path/$tagSigmaJson');
      return await sigmaJsonFile.exists();
    } catch (e) {
      print("Error in isJsonDataAvl: $e");
    }
    return false;
  }

  /// Unified method to load a file from the base sigma folder first,
  /// falling back to local assets if not found.
  /// The [relativePath] should be specified relative to the sigma folder.
  static Future<String> loadFile(String relativePath) async {
    String fileContent = '';
    try {
      String basePath = await getBasePath();
      if (basePath.isNotEmpty) {
        File externalFile = File('$basePath/$relativePath');
        if (await externalFile.exists()) {
          print('File found: ${externalFile.path}');
          fileContent = await externalFile.readAsString();
          return fileContent;
        } else {
          print('File not found at: ${externalFile.path}. Falling back to assets.');
        }
      }
    } catch (e) {
      print('Error checking storage: $e');
    }
    try {
      fileContent = await rootBundle.loadString('assets/sigma/$relativePath');
      print('File loaded from assets: assets/sigma/$relativePath');
    } catch (e) {
      print('Error loading file from assets: $e');
    }
    return fileContent;
  }

  /// Retrieves and decrypts the configuration file, then returns a Config object.
  /// The file is expected at sigma/12/MH/testseries/sigma.json relative to the sigma folder.
  static Future<Config?> getConfigObject() async {
    const String tagConfigFile = "sigma.json";
    String relativePath = "12/MH/$tagConfigFile";

    String encryptedContent = await loadFile(relativePath);
    if (encryptedContent.isEmpty) {
      print("Encrypted config file is empty or not found.");
      return null;
    }

    const String keyString = '1234567890123456'; // Replace with your actual encryption key.
    final key = encrypt.Key.fromUtf8(keyString);
    final iv = encrypt.IV.fromLength(16); // Fixed IV; adjust if needed.
    final encrypter = encrypt.Encrypter(encrypt.AES(key));

    String decrypted;
    try {
      decrypted = encrypter.decrypt64(encryptedContent, iv: iv);
    } catch (e) {
      print("Decryption failed: $e");
      return null;
    }

    try {
      Map<String, dynamic> jsonData = jsonDecode(decrypted);
      Config config = Config.fromJson(jsonData);
      print("Config Object: $config");
      return config;
    } catch (e) {
      print("JSON parsing error: $e");
      return null;
    }
  }

  /// Retrieves and decrypts subject-specific encrypted JSON data.
  /// [path] is specified relative to the sigma folder.
  static Future<String?> getSubjectEncJsonData(String path) async {
    await requestStoragePermission();
    // [path] e.g. "subjects/math.json"
    String relativePath = path;
    String encryptedContent = await loadFile(relativePath);
    if (encryptedContent.isEmpty) {
      print("Encrypted subject JSON not found.");
      return null;
    }
    const String encryptionKey = "1234567890123456";
    try {
      final key = encrypt.Key.fromUtf8(encryptionKey);
      final iv = encrypt.IV.fromLength(16);
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      final decryptedText = encrypter.decrypt64(encryptedContent, iv: iv);
      print('Decrypted Subject JSON: $decryptedText');
      return decryptedText;
    } catch (e) {
      print('Error decrypting subject file: $e');
    }
    return null;
  }

  /// Decrypts file bytes using the provided key.
  static String decryptFile(Uint8List fileBytes, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(
        encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc)
    );
    final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(fileBytes), iv: iv);
    return utf8.decode(decryptedBytes);
  }



}
