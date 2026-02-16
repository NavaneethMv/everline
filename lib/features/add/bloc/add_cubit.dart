import 'dart:developer';

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
import 'package:everline/features/add/models/new_relationship.dart';
import 'package:everline/features/add/repository/add_member_repository.dart';
import 'package:everline/features/add/utils/add_utils.dart';

class AddCubit extends Cubit<AddMemberState> {
  final AddMemberRepository _addMemberRepository = getIt<AddMemberRepository>();

  AddCubit() : super(const AddMemberState()) {
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {
      final members = await _addMemberRepository.getMembers();
      emit(state.copyWith(potentialRelatives: members));
    } catch (e) {
      // Handle error gently or log it
      print('Failed to load potential relatives: $e');
    }
  }

  void resetForm() {
    emit(const AddMemberState());
    loadMembers();
  }

  // ... (imports)

  void stepChanged(int step) {
    emit(state.copyWith(currentStep: step));
  }

  void addRelationship(String memberId, String type) {
    final relationships = List<NewRelationship>.from(state.relationships);

    // Father/Mother should be unique.
    if (type == 'Father' || type == 'Mother' || type == 'Spouse') {
      relationships.removeWhere((r) => r.relationshipType == type);
    }

    // Check if relationship with this member already exists (prevent duplicate links to same person)
    // "You already added a relationship for this member."
    final existingIndex = relationships.indexWhere(
      (r) => r.memberId == memberId,
    );
    if (existingIndex != -1) {
      // Option 1: Replace old relationship
      relationships.removeAt(existingIndex);
      // Option 2: Throw error or return? User UX suggestion was "maybe only let connection to another member"
    }

    relationships.add(
      NewRelationship(memberId: memberId, relationshipType: type),
    );
    emit(state.copyWith(relationships: relationships));
  }

  void setSingleRelationship(String memberId, String type) {
    emit(
      state.copyWith(
        relationships: [
          NewRelationship(memberId: memberId, relationshipType: type),
        ],
      ),
    );
  }

  void removeRelationship(int index) {
    final relationships = List<NewRelationship>.from(state.relationships);
    relationships.removeAt(index);
    emit(state.copyWith(relationships: relationships));
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

  void validateForm() {
    emit(state.copyWith(showErrors: true));
  }

  Future<void> submit() async {
    if (!state.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }

    emit(state.copyWith(status: AddMemberStatus.loading));

    try {
      final memberId = AddUtils.getMemberId(
        firstName: state.firstName.value.trim(),
        lastName: state.lastName.value.trim(),
        dateOfBirth: state.dateOfBirth.value,
        phoneNumber: state.phoneNumber.value.trim(),
      );
      log('Generated Member ID: $memberId');

      final Map<String, dynamic> member = {
        'member_id': memberId,
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

      final checkIfExist = await _addMemberRepository.memberExists(memberId);

      if (!checkIfExist) {
        if (state.profileImagePath != null) {
          final photoPath = await _addMemberRepository.uploadProfileImage(
            memberId,
            state.profileImagePath!,
          );
          member['profile_image_url'] = photoPath;
        }
        final response = await _addMemberRepository.addMember(member);

        if (response != null && response is List && response.isNotEmpty) {
          final newMemberId = response[0]['id'] as String;

          const relationshipTypeMap = {
            'Father': 'parent',
            'Mother': 'parent',
            'Spouse': 'spouse',
            'Child': 'child',
            'Sibling': 'sibling',
          };

          for (final rel in state.relationships) {
            final dbType =
                relationshipTypeMap[rel.relationshipType] ??
                rel.relationshipType.toLowerCase();

            // Only proceed if it's a valid type (or let it fail if not in map, but we want to be safe)
            // Since we simplified the UI list, all should be covered.

            if (dbType == 'child') {
              // User selected 'Child' -> Implies "New Member (member2) is Child of Existing Member (member1)"?
              // NO, User Feedback: "I'm creating Lilly, selecting Kyle, selecting Child -> Lilly is Child".
              // So: New Member (Lilly) = Child. Existing (Kyle) = Parent.
              // We want to store: (Lilly, Kyle, Child).
              // member1 = Lilly (newMemberId), member2 = Kyle (rel.memberId), type = Child.

              await _addMemberRepository.addRelationship(
                member1Id: newMemberId,
                member2Id: rel.memberId,
                relationshipType: 'child',
              );

              // Reciprocal: If Lilly is Child of Kyle, Kyle is Parent of Lilly.
              await _addMemberRepository.addRelationship(
                member1Id: rel.memberId,
                member2Id: newMemberId,
                relationshipType: 'parent',
              );
            } else {
              // Default behavior (Father/Mother/Spouse/Parent).
              // "Kyle is Father". -> member1=Kyle, member2=Lilly. type=Parent.
              await _addMemberRepository.addRelationship(
                member1Id: rel.memberId,
                member2Id: newMemberId,
                relationshipType: dbType,
              );

              if (dbType == 'spouse') {
                await _addMemberRepository.addRelationship(
                  member1Id: newMemberId,
                  member2Id: rel.memberId,
                  relationshipType: 'spouse',
                );
              } else if (dbType == 'parent') {
                // If Kyle is Parent of Lilly, Lilly is Child of Kyle.
                await _addMemberRepository.addRelationship(
                  member1Id: newMemberId,
                  member2Id: rel.memberId,
                  relationshipType: 'child',
                );
              }
            }
          }

          emit(state.copyWith(status: AddMemberStatus.success));
        } else {
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
