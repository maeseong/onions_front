import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_provider.dart';
import '../../../core/constants/app_constants.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRepository(apiClient.dio, const FlutterSecureStorage());
});

class HomeRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  HomeRepository(this._dio, this._storage);

  // 모든 API 요청 헤더에 토큰을 자동으로 붙여주는 헬퍼
  Future<Options> _getHeaders() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return Options(
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  // 1. 성장도 조회 API 연동
  Future<Map<String, dynamic>> fetchGrowth() async {
    final response = await _dio.get(
      '/api/career/growth',
      options: await _getHeaders(),
    );
    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception('성장도 데이터를 불러오지 못했습니다.');
  }

  // 2. 내 로드맵 조회 API 연동
  Future<Map<String, dynamic>> fetchRoadmap() async {
    final response = await _dio.get(
      '/api/roadmaps/me',
      options: await _getHeaders(),
    );
    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception('로드맵 데이터를 불러오지 못했습니다.');
  }

  // 3. 퀘스트 목록 조회 API 연동
  Future<List<dynamic>> fetchQuests({String type = 'main'}) async {
    // 백엔드에서 퀘스트 타입을 구분할 수 있도록 쿼리 파라미터를 함께 보냄
    final response = await _dio.get(
      '/api/quests',
      queryParameters: {'type': type},
      options: await _getHeaders(),
    );
    if (response.data['success'] == true) {
      return response.data['data'] ?? [];
    }
    throw Exception('퀘스트 목록을 불러오지 못했습니다.');
  }
  
  // 4. 퀘스트 상태 변경(완료 처리) API 연동
  Future<void> updateQuestStatus(int questId, String status) async {
    final response = await _dio.patch(
      '/api/quests/$questId/status',
      data: {'status': status},
      options: await _getHeaders(),
    );
    if (response.data['success'] != true) {
      throw Exception('퀘스트 상태 업데이트 실패');
    }
  }
}