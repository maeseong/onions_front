import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_provider.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRepository(apiClient.dio);
});

class HomeRepository {
  final Dio _dio;
  HomeRepository(this._dio);

  // 성장도 조회
  Future<Map<String, dynamic>> fetchGrowth() async {
    final response = await _dio.get('/api/career/growth');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('성장도 조회 실패');
  }
  // 내 로드맵 조회
  Future<Map<String, dynamic>> fetchRoadmap() async {
    final response = await _dio.get('/api/roadmaps/me');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('로드맵 조회 실패');
  }

// 로드맵 단계 목록 조회
  Future<List<dynamic>> fetchRoadmapSteps() async {
    final response = await _dio.get('/api/roadmaps/me/steps');
    if (response.data['success'] == true) {
      return response.data['data']['stages'];
    }
    throw Exception('로드맵 단계 조회 실패');
  }

  // 퀘스트 목록 조회
  Future<List<dynamic>> fetchQuests({String type = 'main'}) async {
    final response = await _dio.get('/api/quests', queryParameters: {'type': type});
    if (response.data['success'] == true) {
      return response.data['data']['quests'];
    }
    throw Exception('퀘스트 조회 실패');
  }
}