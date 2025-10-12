import 'package:everline/features/add/repository/add_member_repository.dart';
import 'package:everline/features/auth/bloc/auth_bloc.dart';
import 'package:everline/features/auth/repository/auth_repository.dart';
import 'package:everline/services/supabase_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<SupabaseService> _initializeSupabase() async {
  final supabaseService = SupabaseService();
  await supabaseService.initialize();
  return supabaseService;
}

Future<void> setupServiceLocator() async {
  final supabaseService = await _initializeSupabase();
  getIt.registerSingleton<SupabaseService>(supabaseService);

  getIt.registerSingleton<AuthRepository>(AuthRepository());
  getIt.registerSingleton<AuthBloc>(AuthBloc());
  getIt.registerFactory<AddMemberRepository>(() => AddMemberRepository());
}
