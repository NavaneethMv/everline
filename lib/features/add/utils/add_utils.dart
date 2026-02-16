import 'dart:convert';

import 'package:crypto/crypto.dart';

class AddUtils {
  /// Generates a unique member ID using a SHA-256 hash.
  ///
  /// The ID is based on the member's first name, last name, date of birth, and phone number.
  ///
  /// - [firstName]: The member's first name (required).
  /// - [lastName]: The member's last name (required).
  /// - [dateOfBirth]: The member's date of birth (optional).
  /// - [phoneNumber]: The member's phone number (required).
  ///
  /// Returns a SHA-256 hash string representing the unique member ID.
  static String getMemberId({
    required String firstName,
    required String lastName,
    required DateTime? dateOfBirth,
    required String phoneNumber,
  }) {
    final combinedString =
        '${firstName.toLowerCase()}_'
        '${lastName.toLowerCase()}_'
        '${dateOfBirth?.toIso8601String() ?? ''}_'
        '${phoneNumber.isEmpty ? 'no_phone' : phoneNumber}';

    return sha256.convert(utf8.encode(combinedString)).toString();
  }
}
