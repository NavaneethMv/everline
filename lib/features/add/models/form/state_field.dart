import 'package:formz/formz.dart';

enum StateFieldValidationError { empty }

class StateField extends FormzInput<String, StateFieldValidationError> {
  const StateField.pure() : super.pure('');
  const StateField.dirty([super.value = '']) : super.dirty();

  @override
  StateFieldValidationError? validator(String value) {
    if (value.trim().isEmpty) return StateFieldValidationError.empty;
    return null;
  }
}
