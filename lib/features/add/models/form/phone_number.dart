import 'package:formz/formz.dart';

enum PhoneNumberValidationError { empty, invalid }

class PhoneNumber extends FormzInput<String, PhoneNumberValidationError> {
  const PhoneNumber.pure() : super.pure('');
  const PhoneNumber.dirty([super.value = '']) : super.dirty();

  static final _phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]+$');

  @override
  PhoneNumberValidationError? validator(String value) {
    if (value.trim().isEmpty) return PhoneNumberValidationError.empty;
    if (!_phoneRegex.hasMatch(value)) return PhoneNumberValidationError.invalid;
    return null;
  }
}
