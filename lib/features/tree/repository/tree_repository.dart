import 'package:everline/core/service_locator.dart';
import 'package:everline/services/supabase_service.dart';

class TreeRepository {
  final SupabaseService _supabaseService = getIt<SupabaseService>();

  Future<List<Map<String, dynamic>>> fetchMembers() async {
    try {
      final response = await _supabaseService.client
          .from('family_members')
          .select(
            'id, member_id, first_name, last_name, gender, date_of_birth, profile_image_url, nickname, email, phone_number, occupation, address, city, state, created_at',
          )
          .order('date_of_birth', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch members: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRelationships() async {
    try {
      final response = await _supabaseService.client
          .from('family_relationships')
          .select('member1_id, member2_id, relationship_type');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch relationships: $e');
    }
  }

  Future<Map<String, dynamic>> fetchMemberById(String id) async {
    try {
      final response = await _supabaseService.client
          .from('family_members')
          .select()
          .eq('id', id)
          .single();
      return response;
    } catch (e) {
      throw Exception('Failed to fetch member: $e');
    }
  }

  Future<void> updateRelationship({
    required String member1Id,
    required String member2Id,
    required String relationshipType,
  }) async {
    try {
      await _supabaseService.client
          .from('family_relationships')
          .update({'relationship_type': relationshipType})
          .eq('member1_id', member1Id)
          .eq('member2_id', member2Id);
    } catch (e) {
      throw Exception('Failed to update relationship: $e');
    }
  }

  Future<void> addRelationship({
    required String member1Id,
    required String member2Id,
    required String relationshipType,
  }) async {
    try {
      await _supabaseService.client.from('family_relationships').insert({
        'member1_id': member1Id,
        'member2_id': member2Id,
        'relationship_type': relationshipType,
      });
    } catch (e) {
      throw Exception('Failed to add relationship: $e');
    }
  }

  Future<void> deleteRelationship({
    required String member1Id,
    required String member2Id,
  }) async {
    try {
      await _supabaseService.client
          .from('family_relationships')
          .delete()
          .eq('member1_id', member1Id)
          .eq('member2_id', member2Id);
    } catch (e) {
      throw Exception('Failed to delete relationship: $e');
    }
  }

  Future<void> updateMember(String id, Map<String, dynamic> updates) async {
    try {
      await _supabaseService.client
          .from('family_members')
          .update(updates)
          .eq('id', id);
    } catch (e) {
      throw Exception('Failed to update member: $e');
    }
  }

  Future<bool> hasRelationships(String memberId) async {
    try {
      final response = await _supabaseService.client
          .from('family_relationships')
          .select('member1_id')
          .or('member1_id.eq.$memberId,member2_id.eq.$memberId')
          .limit(1);
      return (response as List).isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<void> deleteMember(String memberId) async {
    try {
      // 1. Fetch relationships to identify spouses and children
      final relationships = await _supabaseService.client
          .from('family_relationships')
          .select()
          .or('member1_id.eq.$memberId,member2_id.eq.$memberId');

      final List<String> spouseIds = [];
      final List<String> childIds = [];

      for (var rel in relationships) {
        final isMember1 = rel['member1_id'] == memberId;
        final otherId = isMember1 ? rel['member2_id'] : rel['member1_id'];
        final type = rel['relationship_type'];

        if (type == 'spouse') {
          spouseIds.add(otherId as String);
        } else if ((isMember1 && type == 'parent') ||
            (!isMember1 && type == 'child')) {
          // If member is parent of other, then other is child
          childIds.add(otherId as String);
        }
      }

      // 2. Link spouses to children (inherit parenthood)
      if (spouseIds.isNotEmpty && childIds.isNotEmpty) {
        for (final spouseId in spouseIds) {
          for (final childId in childIds) {
            // Check if ANY relationship already exists between spouse and child
            final existingRel = await _supabaseService.client
                .from('family_relationships')
                .select('member1_id')
                .or(
                  'and(member1_id.eq.$spouseId,member2_id.eq.$childId),and(member1_id.eq.$childId,member2_id.eq.$spouseId)',
                )
                .limit(1)
                .maybeSingle();

            if (existingRel == null) {
              // Create parent link: Spouse -> Child
              await addRelationship(
                member1Id: spouseId,
                member2Id: childId,
                relationshipType: 'parent',
              );
              // Create reverse child link: Child -> Spouse
              await addRelationship(
                member1Id: childId,
                member2Id: spouseId,
                relationshipType: 'child',
              );
            }
          }
        }
      }

      // 3. Delete the member
      await _supabaseService.client
          .from('family_members')
          .delete()
          .eq('id', memberId);
    } catch (e) {
      throw Exception('Failed to delete member: $e');
    }
  }
}
