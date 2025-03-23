// lib/utils/crypto_utils.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'crypto_exception.dart';

class CryptoUtils {
  /// Encrypts the contents of [inputFile] using AES/ECB/PKCS7Padding and writes the encrypted data to [outputFile].
  static Future<void> encryptFile(String key, File inputFile,
      File outputFile) async {
    try {
      // Create the secret key.
      final secretKey = encrypt.Key.fromUtf8(key);
      // Create an encrypter using AES in ECB mode.
      final encrypter = encrypt.Encrypter(
        encrypt.AES(secretKey, mode: encrypt.AESMode.ecb),
      );
      // Read all bytes from the input file.
      final inputBytes = await inputFile.readAsBytes();
      // Encrypt the bytes.
      final encrypted = encrypter.encryptBytes(inputBytes);
      // Write the encrypted bytes to the output file.
      await outputFile.writeAsBytes(encrypted.bytes, flush: true);
      print("File encrypted successfully to: ${outputFile.path}");
    } catch (e) {
      throw CryptoException("Error encrypting file: $e");
    }
  }

  /// Decrypts the contents of [inputFile] using AES/ECB/PKCS7Padding and writes the decrypted data to [outputFile].
  static Future<void> decryptFile(String key, File inputFile,
      File outputFile) async {
    try {
      final secretKey = encrypt.Key.fromUtf8(key);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(secretKey, mode: encrypt.AESMode.ecb),
      );
      final inputBytes = await inputFile.readAsBytes();
      // Decrypt the encrypted bytes.
      final decryptedBytes = encrypter.decryptBytes(
        encrypt.Encrypted(inputBytes),
      );
      await outputFile.writeAsBytes(decryptedBytes, flush: true);
      print("File decrypted successfully to: ${outputFile.path}");
    } catch (e) {
      throw CryptoException("Error decrypting file: $e");
    }
  }

  /// Decrypts the contents of [inputFile] using AES/ECB/PKCS7Padding and returns the decrypted data as a String.
/*  static Future<String> decryptStream(String key, File inputFile) async {

    try {
      final secretKey = encrypt.Key.fromUtf8(key);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(secretKey, mode: encrypt.AESMode.ecb),
      );
      final inputBytes = await inputFile.readAsBytes();

      print("Input Bytes $inputBytes");

      final decryptedBytes = encrypter.decryptBytes(
        encrypt.Encrypted(inputBytes),
      );
      return utf8.decode(decryptedBytes);
    } catch (e) {
      throw CryptoException("Error decrypting file stream: $e");
    }
  }
}*/

  static Future<String> decryptStream(String key, File inputFile) async {
    try {
      final secretKey = encrypt.Key.fromUtf8(key);
      final encrypter = encrypt.Encrypter(
        encrypt.AES(secretKey, mode: encrypt.AESMode.ecb),
      );
      final inputBytes = await inputFile.readAsBytes();
      final decryptedBytes = encrypter.decryptBytes(
        encrypt.Encrypted(inputBytes),
      );

      int endIndex = decryptedBytes.length;
      while (endIndex > 0 && decryptedBytes[endIndex - 1] == 0) {
        endIndex--;
      }
      final cleanedBytes = decryptedBytes.sublist(0, endIndex);

      // Attempt to decode the cleaned bytes as a UTF-8 string,
      // allowing malformed characters in case of any residual issues.
      final decodedString = utf8.decode(cleanedBytes, allowMalformed: true);
      return decodedString;

      // Attempt to decode the decrypted bytes as a UTF-8 string.
      /*try {
        return utf8.decode(decryptedBytes);
      } catch (e) {
        // If decoding fails, return the decrypted bytes as a Base64-encoded string.
        return base64Encode(decryptedBytes);
      }*/
    } catch (e) {
      throw CryptoException("Error decrypting file strea$e");
    }
  }
}
