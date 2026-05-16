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
    // [프론트엔드 테스트 전용] 이메일에 'master', 비밀번호에 '1234'를 입력하면 백엔드 없이 바로 통과
    if (email == 'master' && password == '1234') {
      debugPrint('[테스트 모드] 마스터 계정으로 로그인 (백엔드 통신 생략)');
      
      // 기기에 가짜 토큰과 온보딩 완료 징표 삽입
      await _storage.write(key: AppConstants.accessTokenKey, value: 'fake_master_access_token');
      await _storage.write(key: AppConstants.refreshTokenKey, value: 'fake_master_refresh_token');
      await _storage.write(key: 'isOnboarded', value: 'true'); // 온보딩 패스하고 홈으로 직행
      
      return true; 
    }

    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        await _storage.write(key: AppConstants.accessTokenKey, value: data['accessToken']);
        await _storage.write(key: AppConstants.refreshTokenKey, value: data['refreshToken']);

        // 이메일 로그인은 이미 가입된 회원이므로 온보딩 완료 상태(true)로 로컬에 저장
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

        // 'isNewUser'와 'newUser' 둘 다 체크
        final bool isNewUser = data['isNewUser'] ?? data['newUser'] ?? false;
        
        // 'isOnboarded'와 'onboarded' 둘 다 체크
        final bool isOnboarded = data['user']?['isOnboarded'] ?? data['user']?['onboarded'] ?? false;

        // 앱 재진입 시 기억할 수 있도록 로컬 저장소에 온보딩 완료 여부 저장
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

        // 'isNewUser'와 'newUser' 둘 다 체크
        final bool isNewUser = data['isNewUser'] ?? data['newUser'] ?? false;
        
        // 'isOnboarded'와 'onboarded' 둘 다 체크
        final bool isOnboarded = data['user']?['isOnboarded'] ?? data['user']?['onboarded'] ?? false;

        // 앱 재진입 시 기억할 수 있도록 로컬 저장소에 온보딩 완료 여부 저장
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