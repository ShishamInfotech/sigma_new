// lib/utils/crypto_exception.dart
class CryptoException implements Exception {
  final String message;
  CryptoException(this.message);
  @override
  String toString() => "CryptoException: $message";
}
