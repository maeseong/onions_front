import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_provider.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // apiClientProvider에서 dio 객체만 가져옴
  final apiClient = ref.watch(apiClientProvider);
  return AuthRepository(apiClient.dio, const FlutterSecureStorage());
});

class AuthRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AuthRepository(this._dio, this._storage);

  // 카카오 로그인 API 호출
  // 반환값(bool): is_new_user(신규 유저 여부)
  Future<bool> loginWithKakao(String kakaoToken) async {
    try {
      // 백엔드로 카카오 토큰 전송(명세서 기준 POST 요청)
      final response = await _dio.post(
        '/api/auth/kakao',
        data: {'kakao_token': kakaoToken},
      );

      // 응답 성공(success: true)일 경우 처리
      if (response.data['success'] == true) {
        final data = response.data['data'];
        
        // 기기 내부에 발급받은 JWT 토큰 저장
        await _storage.write(key: 'access_token', value: data['access_token']);
        await _storage.write(key: 'refresh_token', value: data['refresh_token']);

        // 신규 유저 여부 반환(UI에서 라우팅 분기 처리에 사용)
        return data['is_new_user'];
      }
      
      throw Exception('로그인 응답 처리 실패');
    } catch (e) {
      // 에러 핸들링 로직
      throw Exception('네트워크 오류: $e');
    }
  }
  
  // 로그아웃 API 호출
  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (e) {
      // 서버에서 에러가 나더라도 기기 내 토큰은 무조건 지움
    } finally {
      await _storage.deleteAll(); 
    }
  }
}