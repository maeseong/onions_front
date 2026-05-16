import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_provider.dart';
import '../../../core/constants/app_constants.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient.dio, const FlutterSecureStorage());
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  // 이메일 로그인 API 호출
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        await _storage.write(key: AppConstants.accessTokenKey, value: data['accessToken']);
        await _storage.write(key: AppConstants.refreshTokenKey, value: data['refreshToken']);

        return true;
      }
      return false;
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 카카오 로그인 API 호출
  Future<Map<String, bool>> loginWithKakao(String kakaoToken) async {
    try {
      final response = await _dio.post('/api/auth/kakao', data: {'kakaoToken': kakaoToken});

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        await _storage.write(key: AppConstants.accessTokenKey, value: data['accessToken']);
        await _storage.write(key: AppConstants.refreshTokenKey, value: data['refreshToken']);

        // 백엔드 명세에 맞춰 newUser와 user 내부의 isOnboarded 상태를 맵으로 묶어 반환
        return {
          'isNewUser': data['newUser'] ?? false,
          'isOnboarded': data['user']?['isOnboarded'] ?? false,
        };
      }
      throw Exception('로그인 응답 처리 실패');
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  Future<Map<String, bool>> loginWithGoogle(String googleToken) async {
    try {
      // 백엔드 명세에 따라 주소는 '/api/auth/google' 등으로 수정 팔요
      final response = await _dio.post('/api/auth/google', data: {'googleToken': googleToken});

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        await _storage.write(key: AppConstants.accessTokenKey, value: data['accessToken']);
        await _storage.write(key: AppConstants.refreshTokenKey, value: data['refreshToken']);

        return {
          'isNewUser': data['newUser'] ?? false,
          'isOnboarded': data['user']?['isOnboarded'] ?? false,
        };
      }
      throw Exception('구글 로그인 응답 처리 실패');
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
  
  // 로그아웃
  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (e) {
      // 에러 무시
    } finally {
      await _storage.deleteAll(); 
    }
  }
}