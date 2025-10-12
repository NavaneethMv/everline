import 'package:formz/formz.dart';

enum GenderValidationError { empty }

class Gender extends FormzInput<String?, GenderValidationError> {
  const Gender.pure() : super.pure(null);
  const Gender.dirty([super.value]) : super.dirty();

  @override
  GenderValidationError? validator(String? value) {
    if (value == null || value.isEmpty) return GenderValidationError.empty;
    return null;
  }
}
