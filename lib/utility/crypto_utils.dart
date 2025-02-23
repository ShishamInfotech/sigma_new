import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart';

class CryptoUtils {
  static const String algorithm = "AES";
  static const int keyLength = 32; // AES-256 requires a 32-byte key
  static const int ivLength = 16; // AES requires a 16-byte IV

  /// Encrypts a file
 /* static Future<void> encryptFile(String key, File inputFile, File outputFile) async {
    try {
      // Validate input file
      if (!inputFile.existsSync()) {
        throw Exception("Input file does not exist: ${inputFile.path}");
      }

      // Prepare the key and IV
      final secretKey = encrypt.Key.fromUtf8(key.padRight(keyLength, ' ').substring(0, keyLength));
      final iv = encrypt.IV.fromLength(ivLength);

      // Initialize encrypter
      final encrypter = encrypt.Encrypter(encrypt.AES(secretKey));

      // Read the input file
      final inputBytes = await inputFile.readAsBytes();

      // Encrypt the input bytes
      final encryptedBytes = encrypter.encryptBytes(inputBytes, iv: iv).bytes;

      // Write the encrypted bytes to the output file
      await outputFile.writeAsBytes(encryptedBytes);

      print("Encryption successful. Encrypted file: ${outputFile.path}");
    } catch (e) {
      print("Error encrypting file: $e");
      rethrow;
    }
  }*/

  /// Decrypts a file
 /* static Future<void> decryptFile(String key, File inputFile, File outputFile) async {
    try {
      // Validate input file
      if (!inputFile.existsSync()) {
        throw Exception("Input file does not exist: ${inputFile.path}");
      }

      // Prepare the key and IV
      final secretKey = encrypt.Key.fromUtf8(key.padRight(keyLength, ' ').substring(0, keyLength));
      final iv = encrypt.IV.fromLength(ivLength);

      // Initialize encrypter
      final encrypter = encrypt.Encrypter(encrypt.AES(secretKey));

      // Read the input file
      final inputBytes = await inputFile.readAsBytes();

      // Decrypt the input bytes
      final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(inputBytes), iv: iv);

      // Write the decrypted bytes to the output file
      await outputFile.writeAsBytes(decryptedBytes);

      print("Decryption successful. Decrypted file: ${outputFile.path}");
    } catch (e) {
      print("Error decrypting file: $e");
      rethrow;
    }
  }
*/
  /// Decrypts the content of a file and returns it as a string
  static Future<String> decryptStream(String key, File inputFile) async {

    String decryptedString = utf8.decode(await doCryptoStream(2, key, inputFile));


    print("decryptedString : $decryptedString");

    return decryptedString;

  }


  static Future<Uint8List> doCryptoStream(
      int cipherMode, String key, File inputFile) async {
    try {
      // Create a Key object from the given key string


      print("Key $key");
      print("File $inputFile");


      final secretKey = Key.fromUtf8(key);

      print("Secret Key ${secretKey.bytes}");
      final encrypter = Encrypter(AES(secretKey)); // Change mode if required
      final iv = IV.fromLength(16); // Initialization vector (adjust as needed)

      // Read the file
      final inputBytes = await inputFile.readAsBytes();

      Uint8List outputBytes;

      if (cipherMode == 1) {
        // Encryption mode
        outputBytes = encrypter.encryptBytes(inputBytes, iv: iv).bytes;
      } else if (cipherMode == 2) {
        // Decryption mode
        outputBytes = Uint8List.fromList(encrypter.decryptBytes(Encrypted(inputBytes), iv: iv));
      } else {
        throw Exception("Invalid cipher mode. Use 1 for encrypt and 2 for decrypt.");
      }

      return outputBytes;
    } catch (e) {
      throw Exception("Error encrypting/decrypting file:$e");
    }
  }


}




