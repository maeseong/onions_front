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

  // --- 1. 이메일 로그인 API 호출 (새로 추가) ---
  Future<bool> loginWithEmail(String email, String password) async {
    try {
      // 백엔드 주소는 명세서에 따라 '/api/auth/login' 등으로 수정이 필요할 수 있습니다.
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // 토큰 저장 (카카오 로그인과 동일한 로직)
        await _storage.write(key: AppConstants.accessTokenKey, value: data['accessToken']);
        await _storage.write(key: AppConstants.refreshTokenKey, value: data['refreshToken']);

        return true; // 로그인 성공
      }
      
      return false; // 서버에서 success: false를 보낸 경우 (비번 틀림 등)
    } catch (e) {
      // 500 에러나 네트워크 에러 발생 시 에러를 던져서 컨트롤러에서 처리하게 함
      throw Exception('네트워크 오류: $e');
    }
  }

  // --- 2. 카카오 로그인 API 호출 (기존 유지) ---
  Future<bool> loginWithKakao(String kakaoToken) async {
    try {
      final response = await _dio.post('/api/auth/kakao', data: {'kakaoToken': kakaoToken});

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        await _storage.write(key: AppConstants.accessTokenKey, value: data['accessToken']);
        await _storage.write(key: AppConstants.refreshTokenKey, value: data['refreshToken']);

        return data['newUser'];
      }
      
      throw Exception('로그인 응답 처리 실패');
    } catch (e) {
      throw Exception('네트워크 오류: $e');
    }
  }
  
  // --- 3. 로그아웃 (기존 유지) ---
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