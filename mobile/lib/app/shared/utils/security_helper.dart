import 'dart:convert';

class Obfuscator {
  // A secure salt key to XOR data, preventing plaintext reverse engineering
  static const String _key = "OldLikeNewSuperSecretKey123!@#";

  /// Encrypts/Obfuscates a string to base64Url XORed value.
  static String encrypt(String text) {
    List<int> bytes = utf8.encode(text);
    List<int> keyBytes = utf8.encode(_key);
    List<int> result = [];
    
    for (int i = 0; i < bytes.length; i++) {
      result.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
    }
    
    return base64Url.encode(result);
  }

  /// Decrypts/Deobfuscates a base64Url XORed string back to original.
  static String decrypt(String encryptedText) {
    try {
      List<int> bytes = base64Url.decode(encryptedText);
      List<int> keyBytes = utf8.encode(_key);
      List<int> result = [];
      
      for (int i = 0; i < bytes.length; i++) {
        result.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(result);
    } catch (_) {
      return '';
    }
  }
}
