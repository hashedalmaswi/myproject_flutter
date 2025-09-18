import 'dart:convert';
import 'package:encrypt/encrypt.dart' as encrypt;

/// CryptoHelper: يوفر تشفير/فك تشفير بعدة خوارزميات
/// - AES (مع مفتاح بطول 32 بايت)
/// - Base64
/// - Caesar (إزاحة للأحرف)
///
/// جميع الدوال "static" لسهولة الاستخدام عبر الصفحات.
class CryptoHelper {
  /// تأكد أن مفتاح AES طوله 32 بايت (AES-256)
  static encrypt.Key normalizeKey(String key) {
    // لو المفتاح أقصر من 32: نكرر ونقص
    if (key.isEmpty) key = 'default_key_for_demo_only__do_not_use_in_prod';
    final repeated = (key * ((32 ~/ key.length) + 1)).substring(0, 32);
    return encrypt.Key.fromUtf8(repeated);
  }

  /// IV ثابت لطول 16 (للتبسيط التعليمي فقط)
  static final encrypt.IV defaultIv = encrypt.IV.fromLength(16);

  /// تشفير AES إلى Base64
  static String encryptAES(String plain, String key) {
    try {
      final k = normalizeKey(key);
      final en = encrypt.Encrypter(encrypt.AES(k));
      final out = en.encrypt(plain, iv: defaultIv);
      return out.base64;
    } catch (e) {
      return 'ERROR_AES_ENCRYPT: $e';
    }
  }

  /// فك تشفير AES من Base64
  static String decryptAES(String cipherB64, String key) {
    try {
      final k = normalizeKey(key);
      final en = encrypt.Encrypter(encrypt.AES(k));
      return en.decrypt64(cipherB64, iv: defaultIv);
    } catch (e) {
      return 'ERROR_AES_DECRYPT: $e';
    }
  }

  /// تشفير Base64
  static String encryptBase64(String plain) {
    return base64.encode(utf8.encode(plain));
  }

  /// فك تشفير Base64
  static String decryptBase64(String encoded) {
    try {
      return utf8.decode(base64.decode(encoded));
    } catch (e) {
      return 'ERROR_BASE64_DECODE: $e';
    }
  }

  /// Caesar: يشمل الحروف (a-z,A-Z) فقط – الباقي يتركه كما هو.
  static String encryptCaesar(String plain, int shift) {
    return String.fromCharCodes(plain.runes.map((c) => _shiftChar(c, shift)));
  }

  static String decryptCaesar(String cipher, int shift) {
    return String.fromCharCodes(cipher.runes.map((c) => _shiftChar(c, -shift)));
  }

  static int _shiftChar(int code, int shift) {
    // a..z
    if (code >= 97 && code <= 122) {
      final base = 97;
      return base + ((code - base + shift) % 26 + 26) % 26;
    }
    // A..Z
    if (code >= 65 && code <= 90) {
      final base = 65;
      return base + ((code - base + shift) % 26 + 26) % 26;
    }
    return code;
  }

  /// دالة موحدة حسب نوع الخوارزمية
  static String encryptUnified({
    required String algorithm, // "AES" | "Base64" | "Caesar"
    required String text,
    required String aesKey,
    required int caesarShift,
  }) {
    switch (algorithm) {
      case 'AES':
        return encryptAES(text, aesKey);
      case 'Base64':
        return encryptBase64(text);
      case 'Caesar':
        return encryptCaesar(text, caesarShift);
      default:
        return 'Unsupported algorithm';
    }
  }

  static String decryptUnified({
    required String algorithm,
    required String text,
    required String aesKey,
    required int caesarShift,
  }) {
    switch (algorithm) {
      case 'AES':
        return decryptAES(text, aesKey);
      case 'Base64':
        return decryptBase64(text);
      case 'Caesar':
        return decryptCaesar(text, caesarShift);
      default:
        return 'Unsupported algorithm';
    }
  }
}
