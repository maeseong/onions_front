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
        await _storage.write(key: 'isOnboarded', value: 'true');

        return true;
      }
      return false;
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }

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
  
  // 로그아웃 시에도 누가 로그아웃 하는지 토큰을 실어 보냄
  Future<void> logout() async {
    try {
      final token = await _storage.read(key: AppConstants.accessTokenKey);
      await _dio.post(
        '/api/auth/logout',
        options: Options(headers: {if (token != null) 'Authorization': 'Bearer $token'}),
      );
    } catch (e) {
      // 로그아웃 실패(서버 에러 등) 시에도 기기의 데이터는 삭제
      debugPrint('서버 로그아웃 통신 에러: $e');
    } finally {
      await _storage.deleteAll(); 
    }
  }
}