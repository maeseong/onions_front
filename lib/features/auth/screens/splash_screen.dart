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

  Future<void> _checkAuthStatus() async {
    final startTime = DateTime.now();

    final accessToken = await _storage.read(key: AppConstants.accessTokenKey);
    final isOnboarded = await _storage.read(key: 'isOnboarded');

    final elapsed = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(seconds: 2) - elapsed;

    if (remainingDelay > Duration.zero) {
      await Future.delayed(remainingDelay);
    }

    if (!mounted) return;

    // 마스터 계정 무한 굴레 방지: 가짜 토큰이면 삭제하고 무조건 로그인 화면으로 보냄
    if (accessToken == 'fake_master_access_token') {
      debugPrint('🛠️ [스플래시] 마스터 토큰 감지 -> 흐름 테스트를 위해 로그인 화면으로 이동');
      await _storage.deleteAll();
      context.go('/login');
      return;
    }

    // 일반 유저 정상 분기 로직
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
              child: Icon(Icons.eco, size: 64, color: primaryColor), 
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