import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  late final SupabaseClient client;

  Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['URL']!,
      anonKey: dotenv.env['ANON_KEY']!,
    );
    client = Supabase.instance.client;
  }
}
