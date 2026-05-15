import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';
import 'package:flutter/services.dart'; 
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart'; 

final authControllerProvider = NotifierProvider<AuthController, bool>(() {
  return AuthController();
});

class AuthController extends Notifier<bool> {
  @override
  bool build() {
    return false; // 초기 상태: 로딩 중 아님
  }

  // --- 1. 이메일 로그인 함수 (새로 추가) ---
  Future<bool> loginWithEmail(String email, String password) async {
    state = true; // 로딩 시작 (화면에 인디케이터 표시)
    print('[디버그] 이메일 로그인 시도: $email');

    try {
      final repository = ref.read(authRepositoryProvider);
      
      // repository에 이메일 로그인 요청 (성공 시 true 반환 가정)
      final success = await repository.loginWithEmail(email, password);
      
      state = false; // 로딩 종료
      return success;
    } catch (e) {
      print('[이메일 로그인 에러 발생] : $e');
      state = false; 
      return false; 
    }
  }

  // --- 2. 카카오 로그인 함수 (기존 코드 유지) ---
  Future<bool?> loginWithKakao() async {
    state = true; 
    print('[디버그 1] 카카오 로그인 함수 시작'); 
    
    try {
      OAuthToken token;
      
      if (await isKakaoTalkInstalled()) {
        try {
          print('[디버그 2] 카톡 앱으로 로그인 시도');
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          if (error is PlatformException && error.code == 'CANCELED') {
            state = false;
            return null;
          }
          print('[디버그 3] 카톡 앱 실패, 웹 브라우저 로그인 시도');
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        print('[디버그 4] 카톡 앱 없음, 웹 브라우저 로그인 시도'); 
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      print('[디버그 5] 카카오 토큰 발급 성공, 서버로 보냄'); 

      final repository = ref.read(authRepositoryProvider);
      final isNewUser = await repository.loginWithKakao(token.accessToken);
      
      print('[디버그 6] 백엔드 서버 통신 성공'); 
      state = false; 
      return isNewUser; 
      
    } catch (e) {
      print('[에러 발생] : $e'); 
      state = false; 
      return null;
    }
  }
}