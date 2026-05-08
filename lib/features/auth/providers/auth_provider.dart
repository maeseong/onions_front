import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/auth_repository.dart';

final authControllerProvider = NotifierProvider<AuthController, bool>(() {
  return AuthController();
});

class AuthController extends Notifier<bool> {
  @override
  bool build() {
    return false; // 초기 상태: false
  }

  // 카카오 로그인 실행 함수
  Future<bool?> loginWithKakao() async {
    state = true; // 화면에 로딩 상태 표시 시작
    
    try {
      final repository = ref.read(authRepositoryProvider);
      
      const dummyKakaoToken = "test_kakao_token_12345"; 
      final isNewUser = await repository.loginWithKakao(dummyKakaoToken);
      
      state = false; // 통신 완료 시 로딩 상태 해제
      return isNewUser; 
      
    } catch (e) {
      state = false; // 에러 발생 시에도 로딩 스피너 멈춤
      return null;
    }
  }
}