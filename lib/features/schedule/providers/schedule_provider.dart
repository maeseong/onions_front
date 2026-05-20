import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../repositories/schedule_repository.dart';

final focusedDayProvider = NotifierProvider<FocusedDayNotifier, DateTime>(
  FocusedDayNotifier.new,
);

class FocusedDayNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();
  void set(DateTime day) => state = day;
}

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
  try {
    final parts = yearMonth.split('-');
    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final repository = ref.watch(scheduleRepositoryProvider);
    return await repository.fetchSchedules(year, month);
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 404) return []; // 데이터 없으면 빈 리스트 반환
    rethrow;
  }
});

// 다가오는 일정 조회 Provider
final upcomingScheduleProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final repository = ref.watch(scheduleRepositoryProvider);
    return await repository.fetchUpcomingSchedules();
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 404) return [];
    rethrow;
  }
});