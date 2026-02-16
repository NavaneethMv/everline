part of 'settings_cubit.dart';

abstract class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final ThemeMode themeMode;
  final String startupPage;

  const SettingsLoaded({required this.themeMode, required this.startupPage});

  @override
  List<Object?> get props => [themeMode, startupPage];

  SettingsLoaded copyWith({ThemeMode? themeMode, String? startupPage}) {
    return SettingsLoaded(
      themeMode: themeMode ?? this.themeMode,
      startupPage: startupPage ?? this.startupPage,
    );
  }
}
