import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../../core/constants/app_constants.dart';

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

    // 앱이 켜질 때마다 기존 로그인 기록을 싹 비워버립니다.
    await _storage.deleteAll(); 

    // 스플래시 화면을 최소 2초간 보여주기 위한 딜레이 계산
    final elapsed = DateTime.now().difference(startTime);
    final remainingDelay = const Duration(seconds: 2) - elapsed;

    if (remainingDelay > Duration.zero) {
      await Future.delayed(remainingDelay);
    }

    if (!mounted) return;

    // 토큰 검사를 없애고, 무조건 로그인 화면으로 강제 이동
    debugPrint('[스플래시] 로그인 화면으로 이동');
    context.go('/login');
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
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                ],
              ),
              child: Icon(Icons.eco, size: 64, color: primaryColor), 
            ),
            const SizedBox(height: 24),
            const Text(
              '나만의 커리어 성장 트리', 
              style: TextStyle(color: Colors.white70, fontSize: 16, letterSpacing: 1.2)
            ),
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