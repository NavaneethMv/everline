import 'package:equatable/equatable.dart';
import 'package:everline/features/add/models/form/address.dart';
import 'package:everline/features/add/models/form/city.dart';
import 'package:everline/features/add/models/form/date_of_birth.dart';
import 'package:everline/features/add/models/form/first_name.dart';
import 'package:everline/features/add/models/form/gender.dart';
import 'package:everline/features/add/models/form/last_name.dart';
import 'package:everline/features/add/models/form/phone_number.dart';
import 'package:everline/features/add/models/form/state_field.dart';
import 'package:formz/formz.dart';

enum AddMemberStatus { initial, loading, success, failure }

class AddMemberState extends Equatable {
  final FirstName firstName;
  final LastName lastName;
  final DateOfBirth dateOfBirth;
  final Gender gender;
  final PhoneNumber phoneNumber;
  final Address address;
  final City city;
  final StateField state;

  final String nickName;
  final String email;
  final String occupation;
  final String? profileImagePath;
  final bool showErrors;
  final AddMemberStatus status;
  final String? errorMessage;

  const AddMemberState({
    this.firstName = const FirstName.pure(),
    this.lastName = const LastName.pure(),
    this.dateOfBirth = const DateOfBirth.pure(),
    this.gender = const Gender.pure(),
    this.phoneNumber = const PhoneNumber.pure(),
    this.address = const Address.pure(),
    this.city = const City.pure(),
    this.state = const StateField.pure(),
    this.nickName = '',
    this.email = '',
    this.occupation = '',
    this.profileImagePath,
    this.status = AddMemberStatus.initial,
    this.errorMessage,
    this.showErrors = false,
  });

  bool get isValid => Formz.validate([
    firstName,
    lastName,
    dateOfBirth,
    gender,
    phoneNumber,
    address,
    city,
    state,
  ]);

  AddMemberState copyWith({
    FirstName? firstName,
    LastName? lastName,
    DateOfBirth? dateOfBirth,
    Gender? gender,
    PhoneNumber? phoneNumber,
    Address? address,
    City? city,
    StateField? state,
    String? nickName,
    String? email,
    String? occupation,
    String? profileImagePath,
    AddMemberStatus? status,
    String? errorMessage,
    bool? showErrors,
  }) {
    return AddMemberState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      nickName: nickName ?? this.nickName,
      email: email ?? this.email,
      occupation: occupation ?? this.occupation,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      status: status ?? this.status,
      errorMessage: errorMessage,
      showErrors: showErrors ?? this.showErrors,
    );
  }

  @override
  List<Object?> get props => [
    firstName,
    lastName,
    dateOfBirth,
    gender,
    phoneNumber,
    address,
    city,
    state,
    nickName,
    email,
    occupation,
    profileImagePath,
    status,
    errorMessage,
    showErrors,
  ];
}
