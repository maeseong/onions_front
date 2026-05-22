import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. 기본 로그인 화면
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.eco, size: 72, color: primaryColor),
                    const SizedBox(height: 20),
                    const Text(
                      'SpecCheck',
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '만나서 반가워요!\n나만의 성장 나무를 가꾸어 보세요',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54, height: 1.5),
                    ),
                    
                    const SizedBox(height: 60),

                    // 카카오 로그인 버튼
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isLoading ? null : () async {
                        try {
                          final loginResult = await ref.read(authControllerProvider.notifier).loginWithKakao();
                          if (context.mounted && loginResult != null) {
                            final isNewUser = loginResult['isNewUser'] ?? false;
                            final isOnboarded = loginResult['isOnboarded'] ?? false;

                            if (isNewUser || !isOnboarded) {
                              context.go('/onboarding');
                            } else {
                              context.go('/home');
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인 실패: 서버 오류가 발생했습니다.')));
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAE100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/kakao_logo.png',
                              height: 24,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.chat_bubble, size: 24),
                            ),
                            const SizedBox(width: 8),
                            const Text('카카오 계정으로 로그인', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // 구글 로그인 버튼
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: isLoading ? null : () async {
                        try {
                          final loginResult = await ref.read(authControllerProvider.notifier).loginWithGoogle();
                          if (context.mounted && loginResult != null) {
                            final isNewUser = loginResult['isNewUser'] ?? false;
                            final isOnboarded = loginResult['isOnboarded'] ?? false;

                            if (isNewUser || !isOnboarded) {
                              context.go('/onboarding');
                            } else {
                              context.go('/home');
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('구글 로그인 중 오류가 발생했습니다.')));
                          }
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/google_logo.webp',
                              width: 20,
                              height: 20,
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.g_mobiledata, size: 24),
                            ),
                            const SizedBox(width: 8),
                            const Text('구글 계정으로 로그인', style: TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. 로딩 오버레이
          if (isLoading)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                child: Container(
                  color: Colors.black.withOpacity(0.15),
                  child: Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}