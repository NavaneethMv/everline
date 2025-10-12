import 'package:bloc/bloc.dart';
import 'package:everline/core/service_locator.dart';
import 'package:everline/features/add/bloc/add_state.dart';
import 'package:everline/features/add/models/form/address.dart';
import 'package:everline/features/add/models/form/city.dart';
import 'package:everline/features/add/models/form/date_of_birth.dart';
import 'package:everline/features/add/models/form/first_name.dart';
import 'package:everline/features/add/models/form/gender.dart';
import 'package:everline/features/add/models/form/last_name.dart';
import 'package:everline/features/add/models/form/phone_number.dart';
import 'package:everline/features/add/models/form/state_field.dart';
import 'package:everline/features/add/repository/add_member_repository.dart';

class AddCubit extends Cubit<AddMemberState> {
  final AddMemberRepository _addMemberRepository = getIt<AddMemberRepository>();

  AddCubit() : super(const AddMemberState());

  void resetForm() {
    emit(const AddMemberState());
  }

  void firstNameChanged(String value) {
    final firstName = FirstName.dirty(value);
    emit(state.copyWith(firstName: firstName));
  }

  void lastNameChanged(String value) {
    final lastName = LastName.dirty(value);
    emit(state.copyWith(lastName: lastName));
  }

  void nickNameChanged(String value) {
    emit(state.copyWith(nickName: value));
  }

  void dateOfBirthChanged(DateTime? value) {
    final dateOfBirth = DateOfBirth.dirty(value);
    emit(state.copyWith(dateOfBirth: dateOfBirth));
  }

  void genderChanged(String value) {
    final gender = Gender.dirty(value);
    emit(state.copyWith(gender: gender));
  }

  void emailChanged(String value) {
    emit(state.copyWith(email: value));
  }

  void phoneNumberChanged(String value) {
    final phoneNumber = PhoneNumber.dirty(value);
    emit(state.copyWith(phoneNumber: phoneNumber));
  }

  void addressChanged(String value) {
    final address = Address.dirty(value);
    emit(state.copyWith(address: address));
  }

  void cityChanged(String value) {
    final city = City.dirty(value);
    emit(state.copyWith(city: city));
  }

  void stateChanged(String value) {
    final stateField = StateField.dirty(value);
    emit(state.copyWith(state: stateField));
  }

  void occupationChanged(String value) {
    emit(state.copyWith(occupation: value));
  }

  void profileImageChanged(String? path) {
    emit(state.copyWith(profileImagePath: path));
  }

  Future<void> submit() async {
    if (!state.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }

    emit(state.copyWith(status: AddMemberStatus.loading));

    try {
      final Map<String, dynamic> member = {
        'first_name': state.firstName.value.trim(),
        'last_name': state.lastName.value.trim(),
        'date_of_birth': state.dateOfBirth.value?.toIso8601String(),
        'gender': state.gender.value,
        'phone_number': state.phoneNumber.value.trim(),
        'address': state.address.value.trim(),
        'city': state.city.value.trim(),
        'state': state.state.value.trim(),

        'nickname': state.nickName.trim().isEmpty
            ? null
            : state.nickName.trim(),
        'email': state.email.trim().isEmpty ? null : state.email.trim(),
        'occupation': state.occupation.trim().isEmpty
            ? null
            : state.occupation.trim(),
        'profile_image_url': state.profileImagePath,
      };
      final checkIfExist = await _addMemberRepository.memberExists(
        state.phoneNumber.value.trim(),
      );
      if (checkIfExist == false) {
        final photoPath = await _addMemberRepository.uploadProfileImage(
          state.phoneNumber.value.trim(),
          state.profileImagePath!,
        );
        member['profile_image_url'] = photoPath;
        final response = await _addMemberRepository.addMember(member);
        if (response != null) {
          emit(state.copyWith(status: AddMemberStatus.success));
        }
      } else {
        emit(
          state.copyWith(
            showErrors: true,
            status: AddMemberStatus.failure,
            errorMessage: 'Member already exists.',
          ),
        );
      }
    } catch (e) {
      emit(
        state.copyWith(
          showErrors: true,
          status: AddMemberStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
