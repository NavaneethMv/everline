import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:everline/features/tree/models/family_tree_node.dart';
import 'package:everline/features/tree/repository/tree_repository.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final TreeRepository _repository;

  HomeCubit({required TreeRepository repository})
    : _repository = repository,
      super(HomeInitial());

  Future<void> loadHomeData() async {
    emit(HomeLoading());
    try {
      final members = await _repository.fetchMembers();

      final nodes = members.map((m) {
        return FamilyTreeNode.fromJson(m);
      }).toList();

      final totalMembers = nodes.length;

      final newSignups = nodes
          .where(
            (n) =>
                n.createdAt != null &&
                n.createdAt!.isAfter(
                  DateTime.now().subtract(const Duration(days: 30)),
                ),
          )
          .length;

      final upcomingBirthdays = nodes.where((n) {
        if (n.dob == null) return false;
        final now = DateTime.now();
        final dob = n.dob!;
        final nextBday = DateTime(now.year, dob.month, dob.day);
        final diff = nextBday.difference(now).inDays;
        return diff >= 0 && diff <= 30;
      }).length;

      final recentMembers = List<FamilyTreeNode>.from(nodes);
      recentMembers.sort((a, b) {
        if (a.createdAt == null) return 1;
        if (b.createdAt == null) return -1;
        return b.createdAt!.compareTo(a.createdAt!);
      });
      final topRecentMembers = recentMembers.take(4).toList();

      // Calculate Monthly Growth (Last 6 Months)
      final now = DateTime.now();
      final Map<DateTime, int> monthlyGrowth = {};

      for (int i = 5; i >= 0; i--) {
        final monthStart = DateTime(now.year, now.month - i, 1);
        final monthEnd = DateTime(now.year, now.month - i + 1, 0);

        final count = nodes.where((n) {
          if (n.createdAt == null) return false;
          return n.createdAt!.isAfter(
                monthStart.subtract(const Duration(days: 1)),
              ) &&
              n.createdAt!.isBefore(monthEnd.add(const Duration(days: 1)));
        }).length;

        monthlyGrowth[monthStart] = count;
      }

      emit(
        HomeLoaded(
          totalMembers: totalMembers,
          newSignups: newSignups,
          upcomingBirthdays: upcomingBirthdays,
          recentMembers: topRecentMembers,
          monthlyGrowth: monthlyGrowth,
        ),
      );
    } catch (e) {
      emit(HomeError(e.toString()));
    }
  }
}
