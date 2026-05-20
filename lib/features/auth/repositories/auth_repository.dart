import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

        // 이메일 로그인은 이미 가입된 회원이므로 온보딩 완료 상태로 로컬에 저장
        await _storage.write(key: 'isOnboarded', value: 'true');

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

        final bool isNewUser = data['isNewUser'] ?? data['newUser'] ?? false;
        final bool isOnboarded = data['user']?['isOnboarded'] ?? data['user']?['onboarded'] ?? false;

        await _storage.write(key: 'isOnboarded', value: isOnboarded.toString());

        return {
          'isNewUser': isNewUser,
          'isOnboarded': isOnboarded,
        };
      }
      throw Exception('로그인 응답 처리 실패');
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

  // 구글 로그인 API 호출
  Future<Map<String, bool>> loginWithGoogle(String googleToken) async {
    try {
      final response = await _dio.post('/api/auth/google', data: {'googleToken': googleToken});

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        await _storage.write(key: AppConstants.accessTokenKey, value: data['accessToken']);
        await _storage.write(key: AppConstants.refreshTokenKey, value: data['refreshToken']);

        final bool isNewUser = data['isNewUser'] ?? data['newUser'] ?? false;
        final bool isOnboarded = data['user']?['isOnboarded'] ?? data['user']?['onboarded'] ?? false;

        await _storage.write(key: 'isOnboarded', value: isOnboarded.toString());

        return {
          'isNewUser': isNewUser,
          'isOnboarded': isOnboarded,
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