import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/app_constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  // 토큰 및 온보딩 완료 여부를 검사하여 화면을 분기하는 함수
  Future<void> _checkAuthStatus() async {
    // 스플래시 애니메이션이나 로고를 최소 2초간은 보여주기 위한 타이머 시작
    final startTime = DateTime.now();

    // 기기에 저장된 유저 데이터(토큰 및 온보딩 완료 여부)를 읽어옴
    final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    final isOnboarded = await _storage.read(key: 'isOnboarded');

    // API 조회 처리가 2초보다 빨리 끝나더라도, 최소 2초는 채우고 넘어가도록 대기 시간을 계산
    final elapsed = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(seconds: 2) - elapsed;

    if (remainingDelay > Duration.zero) {
      await Future.delayed(remainingDelay);
    }

    if (!mounted) return;

    // 읽어온 유저 상태에 따라 정확한 화면 분기
    if (accessToken != null) {
      if (isOnboarded == 'true') {
        debugPrint('[스플래시] 로그인 토큰 보유 + 온보딩 완료 유저 -> 홈 화면');
        context.go('/home');
      } else {
        debugPrint('[스플래시] 로그인 토큰 보유 + 온보딩 미완료 유저 -> 온보딩 화면');
        context.go('/onboarding');
      }
    } else {
      debugPrint('[스플래시] 로그인 정보 없음 -> 로그인 화면');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: Icon(Icons.eco, size: 64, color: primaryColor), // 임시 로고
            ),
            const SizedBox(height: 24),
            const Text('나만의 커리어 성장 트리', style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2)),
            const SizedBox(height: 8),
            const Text(
              'SpecCheck',
              style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 2.0),
            ),
          ],
        ),
      ),
    );
  }
}
