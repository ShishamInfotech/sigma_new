// lib/utils/sd_card_utility.dart
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show MethodChannel, PlatformException, rootBundle;
import 'package:get/get.dart';
import 'package:path/path.dart' as Saf;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:sigma_new/utility/crypto_utils.dart';
import 'constants.dart';
import 'crypto_exception.dart';

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
      List<String>? extPaths = await ExternalPath.getExternalStorageDirectories();
      print("External paths: $extPaths");
      for (String path in extPaths!) {
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
      String fullFilePath = "${basePath}/$path";
     // String fullFilePath = "$path";

      print("Full File Path: $fullFilePath");

      File encryptedFile = File(fullFilePath);
      if (await encryptedFile.exists()) {
        // Read and decrypt file
        String decryptedData = await CryptoUtils.decryptStream(encryptionKey,encryptedFile);
        print("Decrypted Data: $decryptedData");
        if(decryptedData.contains("{")){
          return decryptedData;
        }else {
          String fixedData = _fixBase64(decryptedData);
          // Decode Base64 to bytes, then decode bytes to a UTF-8 string.
          final decodedBytes = base64Decode(fixedData);
          final jsonString = utf8.decode(decodedBytes);
          print("Decoded JSON: $jsonString");
          return jsonString;
        }
      } else {
        print("File does not exist.");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }


  static Future<String?> getSubjectEncJsonDataForMock(String path) async {
    try {
      // Get base path (like getSdcardName in Java)
      String basePath = await getBasePath();
      if (basePath == null) {
        print("Storage not available.");
        return null;
      }

      print('basePath ${basePath}');

      // Construct full file path
     // String fullFilePath = "${basePath}/$path";
       String fullFilePath = "$path";

      print("Full File Path: $fullFilePath");

      File encryptedFile = File(fullFilePath);
      if (await encryptedFile.exists()) {
        // Read and decrypt file
        String decryptedData = await CryptoUtils.decryptStream(encryptionKey,encryptedFile);
        print("Decrypted Data: $decryptedData");
        if(decryptedData.contains("{")){
          return decryptedData;
        }else {
          String fixedData = _fixBase64(decryptedData);
          // Decode Base64 to bytes, then decode bytes to a UTF-8 string.
          final decodedBytes = base64Decode(fixedData);
          final jsonString = utf8.decode(decodedBytes);
          print("Decoded JSON: $jsonString");
          return jsonString;
        }
      } else {
        print("File does not exist.");
      }
    } catch (e) {
      print("Error: $e");
    }
    return null;
  }


  static String _fixBase64(String input) {
    input = input.trim().replaceAll("\n", "").replaceAll("\r", "");
    while (input.length % 4 != 0) {
      input += '=';
    }
    return input;
  }





  //For Mock Exammm

 static Future<List<Uri>?> getFileListBasedOnPref(
      BuildContext context, String path, String pref) async {
    // Request storage permission
    var status = await Permission.storage.request();
    /*if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is not granted')),
      );
      return null;
    }*/

    // External storage directory
    Directory? externalDir = await getExternalStorageDirectory();
    if (externalDir == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error! No external storage found.')),
      );
      return null;
    }

    // Construct full path

    String basePath = await getBasePath();
    if (basePath == null) {
      print("Storage not available.");
      return null;
    }

    print('basePath ${basePath}');

    // Construct full file path
    String fullFilePath = "${basePath}/$path";

    final directoryPath = fullFilePath;
    final directory = Directory(directoryPath);

    if (!directory.existsSync()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Directory not found: $directoryPath')),
      );
      return null;
    }

    final files = directory.listSync();
    final uriList = <Uri>[];

    for (var file in files) {
      if (file is File && file.path.contains(pref)) {
        final uri = Uri.file(file.path);
        if (uri.toString().isNotEmpty) {
          uriList.add(uri);
        } else {
          debugPrint("Empty URI");
        }
      }
    }

    return uriList;
  }

  static const platform = MethodChannel('com.example.sigma_new/device_info');
  static const String bindFile = 'bind.dat';
  static const String hashFile = 'bind.hash';
  static const String folder = 'sigma';



  static Future<String> getDeviceId() async {
    const platform = MethodChannel('com.example.sigma_new/device_info');
    try {
      final String androidId = await platform.invokeMethod('getAndroidId');
      return androidId;
    } on PlatformException catch (e) {
      return "UNKNOWN";
    }
  }

  static Future<void> createBindingFiles() async {
    final path = await getBasePath();
    final deviceId = await getDeviceId();

    // Encrypt device ID
    final encrypted = CryptoUtils.encrypt1(deviceId);
    final bindFilePath = File('$path/$bindFile');
    await bindFilePath.writeAsBytes(encrypted);

    // Generate SHA256 hash
    final hash = sha256.convert(encrypted).toString();
    final hashFilePath = File('$path/$hashFile');
    await hashFilePath.writeAsString(hash);
  }

  static Future<void> validateBinding() async {
    final path = await getBasePath();
    final bindFilePath = File('$path/$bindFile');
    final hashFilePath = File('$path/$hashFile');

    if (!bindFilePath.existsSync() || !hashFilePath.existsSync()) {
      throw CryptoException('Binding files missing. SD card may be tampered.');
    }

    final encryptedBytes = await bindFilePath.readAsBytes();
    final expectedHash = await hashFilePath.readAsString();

    final actualHash = sha256.convert(encryptedBytes).toString();
    if (expectedHash != actualHash) {
      throw CryptoException('Bind file integrity check failed.');
    }

    final decryptedId = CryptoUtils.decrypt(encryptedBytes);
    final currentId = await getDeviceId();

    if (decryptedId != currentId) {
      throw CryptoException('Device ID mismatch. SD card bound to a different device.');
    }
  }

  static Future<void> initializeBindingIfNeeded() async {
    final path = await getBasePath();
    final bindFile = File('$path/bind.dat');
    final hashFile = File('$path/bind.hash');

    if (!bindFile.existsSync() || !hashFile.existsSync()) {
      // First-time setup: create binding files
      print("Binding files not found. Creating new binding...");
      await createBindingFiles();
    }
  }

  static Future<String?> pickSdCardFolder() async {
    try {
      final uri = await platform.invokeMethod<String>('pickSdCardFolder');
      return uri;
    } on PlatformException catch (e) {
      print("Failed to pick folder: \${e.message}");
      return null;
    }
  }

  static final _key = encrypt.Key.fromUtf8('1234567890123456'); // 16-char key
  static final _iv = encrypt.IV.fromLength(16);

  static String encryptDeviceId(String deviceId) {
    final encrypter = encrypt.Encrypter(encrypt.AES(_key));
    final encrypted = encrypter.encrypt(deviceId, iv: _iv);
    return base64Encode(encrypted.bytes);
  }

  static String generateHash(String content) {
    return sha256.convert(utf8.encode(content)).toString();
  }

  static Future<void> bindDeviceToSdCard(String deviceId, String folderPath) async {
    final encrypted = encryptDeviceId(deviceId);
    final hash = generateHash(encrypted);

    final bindFile = File('$folderPath/bind.dat');
    final hashFile = File('$folderPath/bind.hash');

    await bindFile.writeAsString(encrypted);
    await hashFile.writeAsString(hash);
  }

  }



