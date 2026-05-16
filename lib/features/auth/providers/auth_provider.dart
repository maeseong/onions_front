import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../repositories/auth_repository.dart';

final authControllerProvider = NotifierProvider<AuthController, bool>(() {
  return AuthController();
});

class AuthController extends Notifier<bool> {
  bool _isGoogleInitialized = false;

  @override
  bool build() {
    return false;
  }

  // 이메일 로그인 함수
  Future<bool> loginWithEmail(String email, String password) async {
    state = true;
    try {
      final repository = ref.read(authRepositoryProvider);
      final success = await repository.loginWithEmail(email, password);
      state = false;
      return success;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  // 카카오 로그인 함수
  Future<Map<String, bool>?> loginWithKakao() async {
    state = true;
    try {
      OAuthToken token;

      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk();
        } catch (error) {
          if (error is PlatformException && error.code == 'CANCELED') {
            state = false;
            return null;
          }
          token = await UserApi.instance.loginWithKakaoAccount();
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }

      final repository = ref.read(authRepositoryProvider);
      final loginResult = await repository.loginWithKakao(token.accessToken);

      state = false;
      return loginResult;
    } catch (e) {
      state = false;
      rethrow;
    }
  }

  // 구글 로그인 함수
  Future<Map<String, bool>?> loginWithGoogle() async {
    state = true;
    try {
      debugPrint('[디버그] 구글 로그인 시도');
      final googleSignIn = GoogleSignIn.instance;
      
      // 초기화가 안 되어 있다면 한 번 초기화
      if (!_isGoogleInitialized) {
        await googleSignIn.initialize(
          serverClientId: '302346923713-87l248atql2n5gssqobke52sdlh3nsl0.apps.googleusercontent.com'
        );
        _isGoogleInitialized = true;
      }
      
      late final GoogleSignInAccount googleUser;
      try {
        googleUser = await googleSignIn.authenticate();
      } catch (e) {
        // authenticate()는 사용자가 로그인을 취소하면 에러를 던짐
        debugPrint('[디버그] 사용자가 구글 로그인을 취소했거나 창이 닫힘: $e');
        state = false;
        return null; // null을 반환하여 UI 로딩을 해제
      }

      // 인증 정보에서 토큰 추출
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? token = googleAuth.idToken;
      
      if (token == null) {
        throw Exception('구글 토큰을 가져오지 못했습니다.');
      }

      debugPrint('[디버그] 구글 토큰 발급 완료, 서버로 전송');
      final repository = ref.read(authRepositoryProvider);
      final loginResult = await repository.loginWithGoogle(token);
      
      state = false; 
      return loginResult; 
      
    } catch (e) {
      debugPrint('[Provider 에러] 구글 로그인 실패: $e');
      state = false; 
      rethrow; 
    }
  }
}