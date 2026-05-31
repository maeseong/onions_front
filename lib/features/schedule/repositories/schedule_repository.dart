import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_provider.dart';
import '../../../core/constants/app_constants.dart';

final scheduleRepositoryProvider = Provider<ScheduleRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ScheduleRepository(apiClient.dio, const FlutterSecureStorage());
});

class ScheduleRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ScheduleRepository(this._dio, this._storage);

  // API 요청 헤더에 토큰 달아주는 헬퍼
  Future<Options> _getHeaders() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  // 1. 월별 일정 조회
  Future<List<dynamic>> fetchSchedules(int year, int month) async {
    final response = await _dio.get(
      '/api/schedules',
      queryParameters: {'year': year, 'month': month},
      options: await _getHeaders(),
    );
    if (response.data['success'] == true) {
      // 명세서 구조에 맞게 'schedules' 리스트 반환 (없으면 빈 리스트)
      return response.data['data']['schedules'] ?? [];
    }
    throw Exception('일정 조회 실패');
  }

  // 2. 다가오는 일정 조회 (D-day)
  Future<List<dynamic>> fetchUpcomingSchedules() async {
    final response = await _dio.get(
      '/api/schedules/upcoming',
      options: await _getHeaders(),
    );
    if (response.data['success'] == true) {
      return response.data['data']['schedules'] ?? [];
    }
    throw Exception('다가오는 일정 조회 실패');
  }

  // 3. 일정 추가
  Future<Map<String, dynamic>> addSchedule({
    required String title,
    required String scheduleType,
    required String scheduledDate,
    int? companyId,
    String? memo,
  }) async {
    final trimmedTitle = title.trim();
    final trimmedType = scheduleType.trim();
    final trimmedDate = scheduledDate.trim();

    if (trimmedTitle.isEmpty) {
      throw Exception('제목을 입력해주세요.');
    }
    if (trimmedType.isEmpty) {
      throw Exception('일정 유형을 선택해주세요.');
    }
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmedDate)) {
      throw Exception('일정 날짜 형식이 올바르지 않습니다.');
    }

    final requestBody = <String, dynamic>{
      'title': trimmedTitle,
      'scheduleType': trimmedType,
      'scheduledDate': trimmedDate,
      if (companyId != null) 'companyId': companyId,
      if (memo != null) 'memo': memo,
    };

    try {
      final response = await _dio.post(
        '/api/schedules',
        data: requestBody,
        options: await _getHeaders(),
      );
      if (response.data['success'] == true) {
        return response.data['data'] ?? {};
      }
      throw Exception(response.data['message'] ?? '일정 추가 실패');
    } on DioException catch (e) {
      final message = e.response?.data is Map
          ? e.response?.data['message'] as String?
          : null;
      throw Exception(message ?? '일정 추가 실패');
    }
  }

  // 4. 일정 삭제
  Future<void> deleteSchedule(int scheduleId) async {
    final response = await _dio.delete(
      '/api/schedules/$scheduleId',
      options: await _getHeaders(),
    );
    if (response.data['success'] != true) {
      throw Exception('일정 삭제 실패');
    }
  }
}
