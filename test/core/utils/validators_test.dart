import 'package:flutter_test/flutter_test.dart';
import 'package:lavender/core/utils/validators.dart';

void main() {
  test('validatePhone', () {
    expect(validatePhone(''), PhoneError.empty);
    expect(validatePhone('51234'), PhoneError.tooShort);
    expect(validatePhone('412345678'), PhoneError.mustStartWith5);
    expect(validatePhone('512345678'), PhoneError.ok);
  });

  test('validatePassword', () {
    expect(validatePassword(''), PasswordError.empty);
    expect(validatePassword('1234567'), PasswordError.tooShort);
    expect(validatePassword('12345678'), PasswordError.ok);
  });

  test('validateConfirm', () {
    expect(validateConfirm('abc12345', ''), ConfirmError.empty);
    expect(validateConfirm('abc12345', 'abc12346'), ConfirmError.mismatch);
    expect(validateConfirm('abc12345', 'abc12345'), ConfirmError.ok);
  });

  test('validateName', () {
    expect(validateName('  '), NameError.empty);
    expect(validateName('a'), NameError.tooShort);
    expect(validateName('Al'), NameError.ok);
  });

  test('startsWithLetterOrDigit / stripLeadingNonAlnum', () {
    expect(startsWithLetterOrDigit('a1'), isTrue);
    expect(startsWithLetterOrDigit('5'), isTrue);
    expect(startsWithLetterOrDigit('أحمد'), isTrue);
    expect(startsWithLetterOrDigit(' a'), isFalse);
    expect(startsWithLetterOrDigit(''), isFalse);
    expect(stripLeadingNonAlnum('@abc'), 'abc');
    expect(stripLeadingNonAlnum('abc'), 'abc');
    expect(stripLeadingNonAlnum(''), '');
    expect(stripLeadingNonAlnum('@'), '');
  });

  test('isValidEmail / isValidKsaNumber', () {
    expect(isValidEmail('a.b@mail.com'), isTrue);
    expect(isValidEmail('a@b'), isFalse);
    expect(isValidEmail('plain'), isFalse);
    expect(isValidKsaNumber('512345678'), isTrue);
    expect(isValidKsaNumber(' 512345678 '), isTrue);
    expect(isValidKsaNumber('412345678'), isFalse);
    expect(isValidKsaNumber('51234567'), isFalse);
    expect(isValidKsaNumber(null), isFalse);
  });
}
