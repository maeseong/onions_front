import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _clearOldTokens();
  }

  Future<void> _clearOldTokens() async {
    await _storage.deleteAll();
    debugPrint('로그인 화면: 기기에 저장된 옛날 토큰을 모두 지우기');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isLoading = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Icon(Icons.eco, size: 48, color: primaryColor),
              const SizedBox(height: 16),
              const Text('만나서 반가워요!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('나의 성장과 스펙을 기록해 보세요.', style: TextStyle(fontSize: 15, color: Colors.black54)),
              const SizedBox(height: 48),

              const Text('이메일', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: '이메일을 입력해주세요',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              const Text('비밀번호', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: '비밀번호를 입력해주세요',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('비밀번호를 잊으셨나요?', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요.')),
                      );
                      return;
                    }
                    final success = await ref.read(authControllerProvider.notifier).loginWithEmail(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    if (context.mounted) {
                      if (success) {
                        context.go('/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('로그인 실패: 이메일 또는 비밀번호를 확인해주세요.')),
                        );
                      }
                    }
                  },
                  child: isLoading 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[200])),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text('간편 로그인', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ),
                  Expanded(child: Divider(color: Colors.grey[200])),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 카카오 로그인 버튼
                  InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: isLoading ? null : () async {
                      try {
                        final loginResult = await ref.read(authControllerProvider.notifier).loginWithKakao();
                        
                        if (context.mounted && loginResult != null) {
                          final isNewUser = loginResult['isNewUser'] ?? false;
                          final isOnboarded = loginResult['isOnboarded'] ?? false;

                          if (isNewUser || !isOnboarded) {
                            debugPrint('카카오 온보딩 미완료 유저 -> 온보딩 화면으로 이동');
                            context.go('/onboarding');
                          } else {
                            debugPrint('카카오 온보딩 완료 유저 -> 홈 화면으로 이동');
                            context.go('/home');
                          }
                        } else if (context.mounted && loginResult == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('카카오 로그인 결과가 null입니다.')));
                        }
                      } catch (e) {
                        debugPrint('flutter: [카카오 에러 발생] : Exception: 네트워크 오류:');
                        if (e is DioException) {
                          debugPrint('1. 실패한 API 주소: ${e.requestOptions.uri}');
                          debugPrint('2. 서버 상태 코드: ${e.response?.statusCode}');
                          debugPrint('3. 서버가 보낸 메시지: ${e.response?.data}');
                        } else {
                          debugPrint('알 수 없는 에러: $e');
                        }
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('로그인 실패: 서버 오류가 발생했습니다. 콘솔 메시지를 확인하세요.')),
                          );
                        }
                      }
                    },
                    child: _buildClippedImageSocialButton(
                      imagePath: 'assets/images/kakao_logo.jpg',
                    ),
                  ),
                  const SizedBox(width: 24), 
                  
                  // 구글 로그인 버튼
                  InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: isLoading ? null : () async {
                      try {
                        final loginResult = await ref.read(authControllerProvider.notifier).loginWithGoogle();
                        
                        if (context.mounted && loginResult != null) {
                          final isNewUser = loginResult['isNewUser'] ?? false;
                          final isOnboarded = loginResult['isOnboarded'] ?? false;

                          if (isNewUser || !isOnboarded) {
                            debugPrint('구글 온보딩 미완료 유저 -> 온보딩 화면으로 이동');
                            context.go('/onboarding');
                          } else {
                            debugPrint('구글 온보딩 완료 유저 -> 홈 화면으로 이동');
                            context.go('/home');
                          }
                        }
                      } catch (e) {
                        debugPrint('flutter: [구글 에러 발생] : Exception: 네트워크 오류:');
                        if (e is DioException) {
                          debugPrint('1. 실패한 API 주소: ${e.requestOptions.uri}');
                          debugPrint('2. 서버 상태 코드: ${e.response?.statusCode}');
                          debugPrint('3. 서버가 보낸 메시지: ${e.response?.data}');
                        } else {
                          debugPrint('알 수 없는 에러: $e');
                        }
                        
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('구글 로그인 중 오류가 발생했습니다. 콘솔 메시지를 확인하세요.')),
                          );
                        }
                      }
                    },
                    child: _buildClippedImageSocialButton(
                      backgroundColor: Colors.white,
                      imagePath: 'assets/images/google_logo.webp',
                      hasBorder: true,
                      iconPadding: 10.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('아직 계정이 없으신가요?', style: TextStyle(color: Colors.grey[600])),
                  TextButton(
                    onPressed: () {},
                    child: Text('회원가입', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildClippedImageSocialButton({
    required String imagePath,
    Color? backgroundColor,
    double iconPadding = 0.0,
    bool hasBorder = false,
  }) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: Colors.grey[300]!) : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(iconPadding),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}