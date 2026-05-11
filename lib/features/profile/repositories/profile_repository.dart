import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient.dio);
});

class ProfileRepository {
  final Dio _dio;
  ProfileRepository(this._dio);

  // 내 프로필 조회
  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _dio.get('/api/users/me');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('프로필 조회 실패');
  }

  // 스펙 수정
  Future<void> updateSpec(Map<String, dynamic> spec) async {
    final response = await _dio.patch('/api/users/spec', data: spec);
    if (response.data['success'] != true) {
      throw Exception('스펙 수정 실패');
    }
  }
}