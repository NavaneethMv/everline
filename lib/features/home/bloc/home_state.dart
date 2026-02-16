part of 'home_cubit.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final int totalMembers;
  final int newSignups;
  final int upcomingBirthdays;
  final List<FamilyTreeNode> recentMembers;
  final Map<DateTime, int> monthlyGrowth;

  const HomeLoaded({
    required this.totalMembers,
    required this.newSignups,
    required this.upcomingBirthdays,
    required this.recentMembers,
    required this.monthlyGrowth,
  });

  @override
  List<Object> get props => [
    totalMembers,
    newSignups,
    upcomingBirthdays,
    recentMembers,
    monthlyGrowth,
  ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError(this.message);

  @override
  List<Object> get props => [message];
}
