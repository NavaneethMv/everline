import 'package:formz/formz.dart';

enum DateOfBirthValidationError { empty }

class DateOfBirth extends FormzInput<DateTime?, DateOfBirthValidationError> {
  const DateOfBirth.pure() : super.pure(null);
  const DateOfBirth.dirty([super.value]) : super.dirty();

  @override
  DateOfBirthValidationError? validator(DateTime? value) {
    if (value == null) return DateOfBirthValidationError.empty;
    return null;
  }
}
