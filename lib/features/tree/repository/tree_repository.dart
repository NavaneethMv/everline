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
}
