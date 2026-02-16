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

  void initializeEditMode(Map<String, dynamic> memberData) {
    emit(
      state.copyWith(
        isEditMode: true,
        editingMemberId: memberData['id'],
        firstName: FirstName.dirty(memberData['first_name'] ?? ''),
        lastName: LastName.dirty(memberData['last_name'] ?? ''),
        nickName: memberData['nickname'] ?? '',
        dateOfBirth: memberData['date_of_birth'] != null
            ? DateOfBirth.dirty(DateTime.parse(memberData['date_of_birth']))
            : const DateOfBirth.pure(),
        gender: Gender.dirty(memberData['gender'] ?? ''),
        email: memberData['email'] ?? '',
        phoneNumber: memberData['phone_number'] != null
            ? PhoneNumber.dirty(memberData['phone_number'])
            : const PhoneNumber.pure(),
        address: memberData['address'] != null
            ? Address.dirty(memberData['address'])
            : const Address.pure(),
        city: memberData['city'] != null
            ? City.dirty(memberData['city'])
            : const City.pure(),
        state: memberData['state'] != null
            ? StateField.dirty(memberData['state'])
            : const StateField.pure(),
        occupation: memberData['occupation'] ?? '',
        profileImagePath: memberData['profile_image_url'],
      ),
    );
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
    if (state.currentStep == 0) {
      emit(
        state.copyWith(
          showErrors: true,
          firstName: FirstName.dirty(state.firstName.value),
          lastName: LastName.dirty(state.lastName.value),
          dateOfBirth: DateOfBirth.dirty(state.dateOfBirth.value),
          gender: Gender.dirty(state.gender.value),
        ),
      );
    } else if (state.currentStep == 1) {
      emit(
        state.copyWith(
          showErrors: true,
          phoneNumber: PhoneNumber.dirty(state.phoneNumber.value),
          address: Address.dirty(state.address.value),
          city: City.dirty(state.city.value),
          state: StateField.dirty(state.state.value),
        ),
      );
    } else {
      emit(state.copyWith(showErrors: true));
    }
  }

  Future<void> submit() async {
    if (!state.isValid) {
      emit(state.copyWith(showErrors: true));
      return;
    }

    emit(state.copyWith(status: AddMemberStatus.loading));

    try {
      // If in edit mode, update existing member
      if (state.isEditMode && state.editingMemberId != null) {
        final updates = <String, dynamic>{
          'first_name': state.firstName.value.trim(),
          'last_name': state.lastName.value.trim(),
          'nickname': state.nickName.trim().isEmpty
              ? null
              : state.nickName.trim(),
          'date_of_birth': state.dateOfBirth.value?.toIso8601String(),
          'gender': state.gender.value,
          'email': state.email.trim().isEmpty ? null : state.email.trim(),
          'phone_number': state.phoneNumber.value.trim().isEmpty
              ? null
              : state.phoneNumber.value.trim(),
          'address': state.address.value.trim().isEmpty
              ? null
              : state.address.value.trim(),
          'city': state.city.value.trim().isEmpty
              ? null
              : state.city.value.trim(),
          'state': state.state.value.trim().isEmpty
              ? null
              : state.state.value.trim(),
          'occupation': state.occupation.trim().isEmpty
              ? null
              : state.occupation.trim(),
          'updated_at': DateTime.now().toIso8601String(),
        };

        await _addMemberRepository.updateMember(
          state.editingMemberId!,
          updates,
        );
        emit(state.copyWith(status: AddMemberStatus.success));
        return;
      }

      // Original add member logic
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
          };

          for (final rel in state.relationships) {
            final dbType =
                relationshipTypeMap[rel.relationshipType] ??
                rel.relationshipType.toLowerCase();

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
                member1Id: newMemberId,
                member2Id: rel.memberId,
                relationshipType: dbType,
              );

              if (dbType == 'spouse') {
                await _addMemberRepository.addRelationship(
                  member1Id: rel.memberId,
                  member2Id: newMemberId,
                  relationshipType: 'spouse',
                );
              } else if (dbType == 'parent') {
                // If New Member is Parent of Existing (Kyle), then Kyle is Child of New Member.
                await _addMemberRepository.addRelationship(
                  member1Id: rel.memberId,
                  member2Id: newMemberId,
                  relationshipType: 'child',
                );

                // Auto-link spouses: Find other parents of Kyle and link New Member to them.
                try {
                  final kyleParents = await _addMemberRepository.getParents(
                    rel.memberId,
                  );
                  for (final parentId in kyleParents) {
                    if (parentId != newMemberId) {
                      try {
                        await _addMemberRepository.addRelationship(
                          member1Id: newMemberId,
                          member2Id: parentId,
                          relationshipType: 'spouse',
                        );
                      } catch (_) {}
                      try {
                        await _addMemberRepository.addRelationship(
                          member1Id: parentId,
                          member2Id: newMemberId,
                          relationshipType: 'spouse',
                        );
                      } catch (_) {}
                    }
                  }
                } catch (_) {}
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
