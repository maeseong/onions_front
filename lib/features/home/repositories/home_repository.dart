import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
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
    debugPrint('[API 요청] GET ${_dio.options.baseUrl}/api/roadmaps/me');
    final response = await _dio.get(
      '/api/roadmaps/me',
      options: await _getHeaders(),
    );
    debugPrint(
      '[API 응답] GET /api/roadmaps/me status=${response.statusCode} body=${response.data}',
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      if (data is Map<String, dynamic>) {
        final roadmap = data['roadmap'];
        if (roadmap is Map<String, dynamic>) return roadmap;
        return data;
      }
      return {};
    }
    throw Exception('로드맵 데이터를 불러오지 못했습니다.');
  }

  // 3. 퀘스트 목록 조회 API 연동
  Future<List<dynamic>> fetchQuests({String? type}) async {
    debugPrint('[API 요청] GET ${_dio.options.baseUrl}/api/quests');
    final response = await _dio.get(
      '/api/quests',
      options: await _getHeaders(),
    );
    debugPrint(
      '[API 응답] GET /api/quests status=${response.statusCode} body=${response.data}',
    );

    if (response.data['success'] == true) {
      final data = response.data['data'];
      final quests = data is Map<String, dynamic> ? data['quests'] : null;
      if (quests is List) {
        if (type == null) return quests;
        return quests.where((quest) {
          if (quest is! Map) return false;
          return _matchesQuestType(
            quest['questType'] ?? quest['quest_type'],
            type,
          );
        }).toList();
      }
      return [];
    }
    throw Exception('퀘스트 목록을 불러오지 못했습니다.');
  }

  bool _matchesQuestType(dynamic value, String expectedType) {
    final normalizedValue = value?.toString().toLowerCase().replaceAll(
      '-',
      '_',
    );
    final normalizedExpected = expectedType.toLowerCase().replaceAll('-', '_');

    if (normalizedValue == null) return false;
    if (normalizedValue == normalizedExpected) return true;
    if (normalizedExpected == 'main') {
      return normalizedValue == 'main_quest' || normalizedValue == 'mainquest';
    }
    if (normalizedExpected == 'sub') {
      return normalizedValue == 'sub_quest' || normalizedValue == 'subquest';
    }
    return false;
  }

  // 4. 퀘스트 상태 변경(완료 처리) API 연동
  Future<void> updateQuestStatus(int questId, String status) async {
    debugPrint(
      '[API 요청] PATCH ${_dio.options.baseUrl}/api/quests/$questId/status body={status: $status}',
    );
    final response = await _dio.patch(
      '/api/quests/$questId/status',
      data: {'status': status},
      options: await _getHeaders(),
    );
    debugPrint(
      '[API 응답] PATCH /api/quests/$questId/status status=${response.statusCode} body=${response.data}',
    );

    if (response.data['success'] != true) {
      throw Exception('퀘스트 상태 업데이트 실패');
    }
  }
}
