import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/schedule_repository.dart';

// 현재 포커스된 날짜
final focusedDayProvider = NotifierProvider<FocusedDayNotifier, DateTime>(
  FocusedDayNotifier.new,
);

class FocusedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void set(DateTime day) => state = day;
}

// 선택된 날짜
final selectedDayProvider = NotifierProvider<SelectedDayNotifier, DateTime?>(
  SelectedDayNotifier.new,
);

class SelectedDayNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => DateTime.now();
  void set(DateTime? day) => state = day;
}

// 월별 일정 조회
final scheduleProvider = FutureProvider.family<List<dynamic>, String>((ref, yearMonth) async {
  final parts = yearMonth.split('-');
  final year = int.parse(parts[0]);
  final month = int.parse(parts[1]);
  final repository = ref.watch(scheduleRepositoryProvider);
  return repository.fetchSchedules(year, month);
});