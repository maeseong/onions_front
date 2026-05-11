import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_provider.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScheduleRepository(apiClient.dio);
});

class ScheduleRepository {
  final Dio _dio;
  ScheduleRepository(this._dio);

  // 월별 일정 조회
  Future<List<dynamic>> fetchSchedules(int year, int month) async {
    final response = await _dio.get(
      '/api/schedules',
      queryParameters: {'year': year, 'month': month},
    );
    if (response.data['success'] == true) {
      return response.data['data']['schedules'];
    }
    throw Exception('일정 조회 실패');
  }

  // 일정 추가
  Future<Map<String, dynamic>> addSchedule({
    required String title,
    required String scheduleType,
    required String scheduledDate,
    String? memo,
  }) async {
    final response = await _dio.post(
      '/api/schedules',
      data: {
        'title': title,
        'schedule_type': scheduleType,
        'scheduled_date': scheduledDate,
        if (memo != null) 'memo': memo,
      },
    );
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('일정 추가 실패');
  }

  // 일정 삭제
  Future<void> deleteSchedule(int scheduleId) async {
    await _dio.delete('/api/schedules/$scheduleId');
  }
}