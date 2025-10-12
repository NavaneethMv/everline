import 'dart:io';

import 'package:everline/core/service_locator.dart';
import 'package:everline/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMemberRepository {
  final client = getIt<SupabaseService>();

  Future<dynamic> addMember(Map<String, dynamic> member) async {
    try {
      final response = await client.client
          .from('family_members')
          .insert(member)
          .select();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<String?> uploadProfileImage(
    String phoneNumber,
    String filePath,
  ) async {
    try {
      final fileName = 'avatar/profile_$phoneNumber.jpg';
      final photoFile = File(filePath);
      final String response = await client.client.storage
          .from('profile_photo')
          .upload(
            fileName,
            photoFile,
            fileOptions: const FileOptions(upsert: true),
          );
      final publicUrl = client.client.storage
          .from('profile_photo')
          .getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> memberExists(String phoneNumber) async {
    try {
      final response = await client.client
          .from('family_members')
          .select()
          .eq('phone_number', phoneNumber)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  // TODO: phone number country code - alternative phone number
  // TODO: married or not - date of anniversary
  // TODO: alive or not if yes - date of anniversary
}
