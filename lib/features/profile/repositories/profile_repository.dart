import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_provider.dart';
import '../../../core/constants/app_constants.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient.dio, const FlutterSecureStorage());
});

class ProfileRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  ProfileRepository(this._dio, this._storage);

  Future<Options> _getHeaders() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return Options(headers: {if (token != null) 'Authorization': 'Bearer $token'});
  }

  // 1. 내 프로필 및 게임화 데이터 조회
  Future<Map<String, dynamic>> fetchProfile() async {
    final response = await _dio.get('/api/users/me', options: await _getHeaders());
    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception('프로필 조회 실패');
  }

  // 2. 스펙 수정 API
  Future<void> updateSpec(Map<String, dynamic> spec) async {
    final response = await _dio.patch('/api/users/spec', data: spec, options: await _getHeaders());
    if (response.data['success'] != true) {
      throw Exception('스펙 수정 실패');
    }
  }

  // 3. 획득한 뱃지 목록 조회 API
  Future<List<dynamic>> fetchBadges() async {
    final response = await _dio.get('/api/profile/badges/all', options: await _getHeaders());
    if (response.data['success'] == true) {
      return response.data['data'] ?? [];
    }
    throw Exception('뱃지 목록 조회 실패');
  }
}