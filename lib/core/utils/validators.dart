// Pure validation rules. They return a key; the screen maps it to an l10n string.

enum PhoneError { empty, tooShort, mustStartWith5, ok }

enum PasswordError { empty, tooShort, ok }

enum ConfirmError { empty, mismatch, ok }

enum NameError { empty, tooShort, ok }

PhoneError validatePhone(String phone) {
  final p = phone.trim();
  if (p.isEmpty) return PhoneError.empty;
  if (p.length < 9) return PhoneError.tooShort;
  if (!p.startsWith('5')) return PhoneError.mustStartWith5;
  return PhoneError.ok;
}

PasswordError validatePassword(String password) {
  if (password.isEmpty) return PasswordError.empty;
  if (password.length < 8) return PasswordError.tooShort;
  return PasswordError.ok;
}

ConfirmError validateConfirm(String password, String confirm) {
  if (confirm.isEmpty) return ConfirmError.empty;
  if (confirm != password) return ConfirmError.mismatch;
  return ConfirmError.ok;
}

NameError validateName(String name) {
  final n = name.trim();
  if (n.isEmpty) return NameError.empty;
  if (n.length < 2) return NameError.tooShort;
  return NameError.ok;
}

final RegExp _letterOrDigit = RegExp(r'[\p{L}\p{Nd}]', unicode: true);

/// True when the first character is a letter or digit (Kotlin `isLetterOrDigit`).
bool startsWithLetterOrDigit(String s) =>
    s.isNotEmpty && _letterOrDigit.hasMatch(String.fromCharCode(s.runes.first));

/// Port of the Login/Register text watchers
/// `dropWhileIndexed { i, c -> i == 0 && !c.isLetterOrDigit() }`:
/// drops the first character when it is not a letter or digit.
String stripLeadingNonAlnum(String s) {
  if (s.isEmpty || startsWithLetterOrDigit(s)) return s;
  return String.fromCharCodes(s.runes.skip(1));
}

/// Android `Patterns.EMAIL_ADDRESS`.
final RegExp _email = RegExp(
    r'^[a-zA-Z0-9\+\.\_\%\-\+]{1,256}\@[a-zA-Z0-9][a-zA-Z0-9\-]{0,64}(\.[a-zA-Z0-9][a-zA-Z0-9\-]{0,25})+$');

bool isValidEmail(String email) => _email.hasMatch(email);

/// KSA mobile: starts with 5, exactly 9 digits (Android `isValidKsaNumber`).
bool isValidKsaNumber(String? number) =>
    number != null && RegExp(r'^5\d{8}$').hasMatch(number.trim());
