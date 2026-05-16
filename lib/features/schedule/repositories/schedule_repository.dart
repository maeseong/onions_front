import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
    try {
      final response = await _dio.get(
        '/api/schedules',
        queryParameters: {'year': year, 'month': month},
      );
      if (response.data['success'] == true) {
        return response.data['data']['schedules'];
      }
      throw Exception('일정 조회 실패');
    } catch (e) {
      debugPrint('백엔드 응답 없음: 월별 일정 가짜 데이터 반환');
      // 서버가 죽어있을 때 달력을 테스트할 수 있는 가짜 데이터
      final today = DateTime.now();
      return [
        {
          'schedule_id': 1,
          'title': '네이버 프론트엔드 서류 마감',
          'schedule_type': '서류',
          'company_id': 1,
          'scheduled_date': '$year-${month.toString().padLeft(2, '0')}-15',
          'd_day': 5,
        },
        {
          'schedule_id': 2,
          'title': '카카오 코딩테스트',
          'schedule_type': '코딩테스트',
          'company_id': 2,
          'scheduled_date': '$year-${month.toString().padLeft(2, '0')}-20',
          'd_day': 10,
        },
      ];
    }
  }

  // 다가오는 일정 조회
  Future<List<dynamic>> fetchUpcomingSchedules() async {
    try {
      final response = await _dio.get('/api/schedules/upcoming');
      if (response.data['success'] == true) {
        return response.data['data']['schedules'];
      }
      throw Exception('다가오는 일정 조회 실패');
    } catch (e) {
      debugPrint('백엔드 응답 없음: 다가오는 일정 가짜 데이터 반환');
      
      // 현재 날짜를 기준으로 3일 뒤의 날짜를 동적으로 계산
      final today = DateTime.now();
      final targetDate = today.add(const Duration(days: 3));
      
      return [
        {
          'schedule_id': 99,
          'title': '네이버 프론트엔드 서류 마감',
          'schedule_type': '서류',
          // 계산된 날짜를 yyyy-MM-dd 형식으로 변환
          'scheduled_date': '${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}',
          'd_day': 3,
        },
      ];
    }
  }

  // 일정 추가
  Future<Map<String, dynamic>> addSchedule({
    required String title,
    required String scheduleType,
    required String scheduledDate,
    required int companyId,
    String? memo,
  }) async {
    try {
      final response = await _dio.post(
        '/api/schedules',
        data: {
          'title': title,
          'scheduleType': scheduleType,
          'companyId': companyId,
          'scheduledDate': scheduledDate,
          if (memo != null) 'memo': memo,
        },
      );
      if (response.data['success'] == true) {
        return response.data['data'];
      }
      throw Exception('일정 추가 실패');
    } catch (e) {
      debugPrint('백엔드 응답 없음: 일정 추가 가짜 성공 처리');
      return {'success': true, 'message': '가짜 저장 완료'};
    }
  }

  // 일정 삭제
  Future<void> deleteSchedule(int scheduleId) async {
    try {
      await _dio.delete('/api/schedules/$scheduleId');
    } catch (e) {
      debugPrint('백엔드 응답 없음: 일정 삭제 가짜 성공 처리');
    }
  }
}