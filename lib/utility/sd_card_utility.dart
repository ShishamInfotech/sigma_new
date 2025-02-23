import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sigma_new/config/config.dart';
import 'package:sigma_new/ui_helper/constant.dart';
import 'package:sigma_new/utility/crypto_utils.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SdCardUtility{

  static Future<void> listFilesOnSDCard() async {
    if (await requestStoragePermission()) {
      try {
        final directories = await getExternalStorageDirectories();
        if (directories != null && directories.isNotEmpty) {
          for (var directory in directories) {
            print('Checking Directory: ${directory.path}');
            final files = Directory(directory.path).listSync();
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



  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      return true;
    } else {
      // Handle denied permissions gracefully
      print('Storage permission denied.');
      return false;
    }
  }


  Future<List<String>> getAccessibleDirectories() async {
    final directories = await getExternalStorageDirectories();
    return directories?.map((dir) => dir.path).toList() ?? [];
  }

  static Future<String> getSdcardName() async {
    const String SIGMA_DIR = "sigma";

    // List files in the 'storage' directory
   /* Directory storageDir = Directory("storage/");
     List<FileSystemEntity> listOfStorages = [];

     if (await storageDir.exists()) {
       listOfStorages = storageDir.listSync();
     }*/

    // For API levels below Android 9 (P)
    /*if (Platform.isAndroid && Platform.version.compareTo("9") < 0) {
      for (var entity in listOfStorages) {
        String path = "/storage/${entity.uri.pathSegments.last}";
        if (entity is Directory) {
          // Check if the directory contains SIGMA_DIR
          Directory sigmaDir = Directory("$path/$SIGMA_DIR");
          print("sigmaDir.exists() ${sigmaDir.exists()}");
          if (await sigmaDir.exists()) {
            return path;
          }

          // Return if the name contains a hyphen (likely an SD card)
          if (entity.uri.pathSegments.last.contains("-")) {
            return path;
          }
        }
      }
    }*/

    // For modern Android versions
    List<Directory> storageDirectories = (await getExternalStorageDirectories()) ?? [];
    String sdCardPath = "";
    for (Directory directory in storageDirectories) {
      // Check if the storage is removable
      //if (await directory.path) {
        sdCardPath = directory.path;

        print("SSSS ${sdCardPath}");
        //break;
      //}
    }

    // Extract base path for removable storage
    if (sdCardPath.isNotEmpty) {
      List<String> pathSegments = sdCardPath.split("/");
      if (pathSegments.length >= 3) {
        print("PASS /${pathSegments[1]}/${pathSegments[2]}");
        return "/${pathSegments[1]}/${pathSegments[2]}";
      }
    }

    // Default return path
    return "/mnt/external_sd";
  }



  static Future<bool> isSigmaDirAvl() async {
    try {
      // Get the external storage directory (SD card path)
      final directory = await getExternalStorageDirectory();
      print("Error ${directory}");
      if (directory == null) {
        /*Fluttertoast.showToast(
          msg: "Error! No SDCARD Found!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );*/
        print("Error 1");
        Get.snackbar("Error","No SD Card Found");
        return false;
      }

      String basePath =await getSdcardName();
      const String SIGMA_DIR = "sigma"; // Replace with your actual directory name

      print("Base Pattth ${basePath}");
      // Check if the directory exists
      final sigmaDir = Directory('$basePath/$SIGMA_DIR');



      print("Error ${await sigmaDir.exists()}");
      if (await sigmaDir.exists()) {
        Get.snackbar("Done", "Success", backgroundColor: redColor,snackPosition:  SnackPosition.TOP);

        return true;
      } else {
        /*Fluttertoast.showToast(
          msg: "Error! Sigma Directory Not Found!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );*/
        print("Error NO Sigma");
        Get.snackbar("Error","Sigma Directory Not Found!");
        return false;
      }
    } catch (e) {
      /*Fluttertoast.showToast(
        msg: "An error occurred: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );*/

      print("Error 1 ${e}");
      Get.snackbar("Error","An error occurred: ${e}");

      return false;
    }
  }




  static Future<List<String>?> getIntroImages() async {
    try {
      // Get the external storage directory


      String basePath =await getSdcardName();
      const String SIGMA_DIR = "sigma"; // Replace with your actual directory name
      const String INTRO_DIR = "intro"; // Replace with your actual intro directory name

      // Check if the Sigma directory exists
      final sigmaDir = Directory('$basePath/$SIGMA_DIR/$INTRO_DIR');
      if (await sigmaDir.exists()) {
        // Get a list of files in the directory
        List<FileSystemEntity> fileList = sigmaDir.listSync();

        if (fileList.isNotEmpty) {
          // Sort files in reverse order and get their absolute paths
          List<String> filePaths = fileList
              .whereType<File>() // Ensure we only include files
              .map((file) => file.path)
              .toList()
            ..sort((a, b) => b.compareTo(a)); // Sort in reverse order

          print("File Paths ${jsonEncode(filePaths)}");
          return filePaths;
        }
      } else {
        /*Fluttertoast.showToast(
          msg: "Error! Sigma Directory Not Found!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );*/
        Get.snackbar("Error","Sigma Directory Not Found");
      }
    } catch (e) {
      /*Fluttertoast.showToast(
        msg: "An error occurred: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );*/
      Get.snackbar("Error","Error Occcured $e");
    }

    return null; // Return null if no valid files are found
  }




  Future<bool> isJsonDataAvl(String path) async {
    try {
      // Get the external storage directory
      final directory = await getExternalStorageDirectory();

      if (directory == null) {
        /*Fluttertoast.showToast(
          msg: "Error! No SDCARD Found!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );*/
        return false;
      }

      String basePath =await getSdcardName();
      const String SIGMA_DIR = "sigma"; // Replace with your actual directory name
      const String TAG_SIGMA_JSON = "sigma.json"; // Replace with your JSON file name

      // Check if the Sigma directory is available
      final sigmaJsonFile = File('$basePath/$SIGMA_DIR/$path/$TAG_SIGMA_JSON');
      if (await sigmaJsonFile.exists()) {
        return true;
      }
    } catch (e) {
     /*Fluttertoast.showToast(
        msg: "An error occurred: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );*/
    }
    return false;
  }




  static Future<Config?> getConfigObject() async {
    // Get the external storage directory

    // Build the path to the encrypted configuration file
    String basePath = await getSdcardName();
    const String SIGMA_DIR = "sigma"; // Replace with your actual directory name
    const String TAG_CONFIG_FILE = "sigma.json"; // Replace with your encrypted file name
    // final String encFilePath = '/storage/extSdCard/sigma/12/MH/testseries/sigma_data.json';
    final String encFilePath = '/storage/0000-0000/sigma/12/MH/testseries/sigma_data.json';


    // final File encryptedFile = File(encFilePath);

    print("PAthhh $encFilePath");


    // Check if the encrypted file exists
    if (await isSigmaDirAvl()) {
      final String keyString = '1234567890123456'; // Encryption key
      final File encryptedFile = File(encFilePath);


      if (!await encryptedFile.exists()) {
        print("File not found: $encryptedFile");
        return null;
      }


      Uint8List encryptedBytes = await encryptedFile.readAsBytes();
      String encryptedBase64 = base64Encode(
          encryptedBytes); // Convert to Base64

      // Convert the key to a valid format (AES requires a 32-byte key)
      final key = encrypt.Key.fromUtf8(keyString);
      final iv = encrypt.IV.fromLength(await encryptedFile.length()); // Default IV (change if required)
      final encrypter = encrypt.Encrypter(
          encrypt.AES(key));

      // Decrypt the data
      final decrypted = encrypter.decrypt64(encryptedBase64, iv: iv);

      // Parse JSON
      Map<String, dynamic> jsonData = jsonDecode(decrypted);
      print("jsonData ${jsonData}");
      return null;

      /*try {


          final String decryptedText = await CryptoUtils.decryptStream(key, encryptedFile);
          print("Decrypted ${decryptedText}");
         */ /* if (decryptedText.isNotEmpty) {
            try {
              final jsonMap = jsonDecode(utf8.decode(decryptedText.codeUnits));
              final Config config = Config.fromJson(jsonMap);
              print("Config Object: $config");
              return config;
            } on FormatException catch (e) {
              print('JSON parsing error: $e');
              return null;
            } catch (e) {
              print('Unexpected error: $e');
              return null;
            }
          }*/ /*
        } catch (e) {
          print('Decryption error: $e');
          return null;
        }
      }
      return null;*/
    }
  }


  static Future<String?> getSubjectEncJsonData(String path) async {


    await requestStoragePermission();
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      /* Fluttertoast.showToast(
          msg: "Error! No SDCARD Found!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );*/
      return null;
    }
    final basePath =await getSdcardName();
    const String sigmaDir = "sigma";
    const String encryptionKey = "1234567890123456";

    print("BasePath Path $basePath");

    print("Available ${await isSigmaDirAvl()}");
    if (await isSigmaDirAvl()) {

    //  File encryptedFile = new File('$basePath/$File.separator + SIGMA_DIR + File.separator + path);
      final encryptedFile = File('$basePath/$sigmaDir/$path');

      print("encryptedFile ${await encryptedFile.exists()}");
      if (await encryptedFile.exists()) {
        try {
          // Read file content as bytes
        //  final fileBytes = await encryptedFile.readAsBytes();

          // Decrypt the file content
         // final decryptedText = decryptFile(fileBytes, encryptionKey);
          final str =await CryptoUtils.decryptStream(encryptionKey, encryptedFile);

          print('Decrypted Text: $str');
          return str;
        } catch (e) {
          print('Error decrypting file: $e');
        }
      }
    }

    return null;
  }


  static String decryptFile(Uint8List fileBytes, String key) {
    final keyBytes = encrypt.Key.fromUtf8(key);
    final iv = encrypt.IV.fromLength(16); // Assuming an IV of 16 bytes (default)
    final encrypter = encrypt.Encrypter(encrypt.AES(keyBytes, mode: encrypt.AESMode.cbc));

    final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(fileBytes), iv: iv);
    return utf8.decode(decryptedBytes);
  }



}