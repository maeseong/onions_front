import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/schedule_repository.dart';

// 현재 포커스된 날짜 (달력에서 보고 있는 월)
final focusedDayProvider = NotifierProvider<FocusedDayNotifier, DateTime>(
  FocusedDayNotifier.new,
);

class FocusedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void set(DateTime day) => state = day;
}

// 선택된 날짜 (달력에서 찍은 특정 일)
final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime?>(
  SelectedDayNotifier.new,
);

class SelectedDayNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => DateTime.now();
  void set(DateTime? day) => state = day;
}

// 월별 일정 조회 Provider
final scheduleProvider = FutureProvider.family<List<dynamic>, String>((ref, yearMonth) async {
  final parts = yearMonth.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.fetchSchedules(year, month);
});

// 다가오는 일정 조회 Provider
final upcomingScheduleProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.fetchUpcomingSchedules();
});