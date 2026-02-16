import 'dart:io';

import 'package:everline/core/service_locator.dart';
import 'package:everline/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddMemberRepository {
  final client = getIt<SupabaseService>();

  /// Inserts a new member record into the 'family_members' table.
  ///
  /// [member]: A map containing the member's data to be inserted.
  ///
  /// Returns the response from Supabase if successful, otherwise throws an error.
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

  /// Uploads a profile image to Supabase Storage and returns its public URL.
  ///
  /// [memberId]: The unique identifier for the member (used in the file name).
  /// [filePath]: The local file path of the image to upload.
  ///
  /// Returns the public URL of the uploaded image if successful, otherwise throws an error.
  Future<String?> uploadProfileImage(String memberId, String filePath) async {
    try {
      final fileName = 'avatar/profile_$memberId.jpg';
      final photoFile = File(filePath);
      await client.client.storage
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

  /// Checks if a member with the given member ID already exists in the 'family_members' table.
  ///
  /// [memberId]: The member ID to check for existence.
  ///
  /// Returns true if a member exists, false otherwise. Throws an error on failure.
  Future<dynamic> memberExists(String memberId) async {
    try {
      final response = await client.client
          .from('family_members')
          .select()
          .eq('member_id', memberId)
          .limit(1);
      return response.isNotEmpty;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getMembers() async {
    try {
      final response = await client.client
          .from('family_members')
          .select('id, first_name, last_name, gender, member_id')
          .order('first_name', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch members: $e');
    }
  }

  Future<void> addRelationship({
    required String member1Id,
    required String member2Id,
    required String relationshipType,
  }) async {
    try {
      await client.client.from('family_relationships').insert({
        'member1_id': member1Id,
        'member2_id': member2Id,
        'relationship_type': relationshipType,
      });
    } catch (e) {
      throw Exception('Failed to add relationship: $e');
    }
  }

  Future<void> updateMember(String id, Map<String, dynamic> updates) async {
    try {
      // id should be the UUID primary key usually
      await client.client.from('family_members').update(updates).eq('id', id);
    } catch (e) {
      throw Exception('Failed to update member: $e');
    }
  }

  Future<void> updateRelationship({
    required String member1Id,
    required String member2Id,
    required String relationshipType,
  }) async {
    try {
      // Check if relationship exists
      final existing = await client.client
          .from('family_relationships')
          .select()
          .eq('member1_id', member1Id)
          .eq('member2_id', member2Id);

      if (existing.isNotEmpty) {
        await client.client
            .from('family_relationships')
            .update({'relationship_type': relationshipType})
            .eq('member1_id', member1Id)
            .eq('member2_id', member2Id);
      } else {
        await addRelationship(
          member1Id: member1Id,
          member2Id: member2Id,
          relationshipType: relationshipType,
        );
      }
    } catch (e) {
      throw Exception('Failed to update relationship: $e');
    }
  }

  Future<void> deleteRelationship({
    required String member1Id,
    required String member2Id,
  }) async {
    try {
      await client.client
          .from('family_relationships')
          .delete()
          .eq('member1_id', member1Id)
          .eq('member2_id', member2Id);
    } catch (e) {
      throw Exception('Failed to delete relationship: $e');
    }
  }

  Future<List<String>> getParents(String childId) async {
    try {
      final response = await client.client
          .from('family_relationships')
          .select('member1_id')
          .eq('member2_id', childId)
          .eq('relationship_type', 'parent');
      return (response as List).map((e) => e['member1_id'] as String).toList();
    } catch (e) {
      return [];
    }
  }
}
