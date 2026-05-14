import 'package:characters/characters.dart';
import 'package:flutter/services.dart';

class InputSanitizer {
  const InputSanitizer._();

  static final RegExp _emojiAndControlChars = RegExp(
    r'[\u0000-\u001F\u007F-\u009F\u200B-\u200D\uFE0F]|[\u{1F000}-\u{1FAFF}]',
    unicode: true,
  );

  static final TextInputFormatter safeTextFormatter =
      TextInputFormatter.withFunction((oldValue, newValue) {
        final sanitized = sanitizeText(newValue.text);
        if (sanitized == newValue.text) return newValue;
        return TextEditingValue(
          text: sanitized,
          selection: TextSelection.collapsed(
            offset: sanitized.length.clamp(0, sanitized.length),
          ),
        );
      });

  static final TextInputFormatter numericFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'));

  static String sanitizeText(String value, {int maxLength = 120}) {
    return value
        .replaceAll(_emojiAndControlChars, '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trimLeft()
        .characters
        .take(maxLength)
        .toString();
  }

  static String sanitizeName(String value) {
    return sanitizeText(
      value,
      maxLength: 80,
    ).replaceAll(RegExp(r"[^a-zA-Z0-9\s.,'/-]"), '').trim();
  }

  static String? validateName(
    String? value, {
    String field = 'Input',
    int minLength = 3,
    int maxLength = 80,
  }) {
    final sanitized = sanitizeName(value ?? '');
    if (sanitized.isEmpty) return '$field wajib diisi';
    if (sanitized.length < minLength) return 'Minimal $minLength karakter';
    if (sanitized.length > maxLength) return 'Maksimal $maxLength karakter';
    if (sanitized != (value ?? '').trim()) {
      return '$field mengandung karakter tidak valid';
    }
    return null;
  }

  static String? validatePositiveInt(String? value, {String field = 'Angka'}) {
    final sanitized = (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
    if (sanitized.isEmpty) return '$field wajib diisi';
    final parsed = int.tryParse(sanitized);
    if (parsed == null) return '$field harus angka';
    if (parsed <= 0) return '$field harus lebih dari 0';
    return null;
  }

  static String? validateNonNegativeDouble(
    String? value, {
    String field = 'Angka',
    bool optional = false,
  }) {
    final text = (value ?? '').trim();
    if (optional && text.isEmpty) return null;
    if (text.isEmpty) return '$field wajib diisi';
    final parsed = double.tryParse(text);
    if (parsed == null) return '$field harus angka';
    if (parsed < 0) return '$field tidak boleh minus';
    return null;
  }
}
