import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

// 컨트롤러 관리를 위해 ConsumerStatefulWidget으로 변경합니다.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // 1. 입력값을 제어할 컨트롤러 선언
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // 메모리 누수 방지를 위해 컨트롤러 해제
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

              // 이메일 입력
              const Text('이메일', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController, // 컨트롤러 연결
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

              // 비밀번호 입력
              const Text('비밀번호', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController, // 컨트롤러 연결
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

              // 비밀번호 찾기
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text('비밀번호를 잊으셨나요?', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),

              // 일반 로그인 버튼 (수정됨)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isLoading ? null : () async {
                    // 2. 유효성 검사 (빈칸 확인)
                    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이메일과 비밀번호를 모두 입력해주세요.')),
                      );
                      return;
                    }

                    // 3. 서버 로그인 시도 (auth_provider에 loginWithEmail 함수가 있다고 가정)
                    final success = await ref.read(authControllerProvider.notifier).loginWithEmail(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );

                    // 4. 결과에 따른 처리
                    if (context.mounted) {
                      if (success) {
                        context.go('/home'); // 성공 시에만 이동!
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

              // 간편 로그인 영역 (기존과 동일)
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

              // 소셜 로그인 버튼 (기존과 동일)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: isLoading ? null : () async {
                      final isNewUser = await ref.read(authControllerProvider.notifier).loginWithKakao();
                      if (context.mounted && isNewUser != null) {
                        if (isNewUser) {
                          context.go('/onboarding');
                        } else {
                          context.go('/home');
                        }
                      } else if (context.mounted && isNewUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('카카오 로그인에 실패했습니다.')));
                      }
                    },
                    child: _buildClippedImageSocialButton(
                      imagePath: 'assets/images/kakao_logo.jpg',
                      isLoading: isLoading,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildClippedImageSocialButton(
                    backgroundColor: Colors.white,
                    imagePath: 'assets/images/google_logo.webp',
                    hasBorder: true,
                    iconPadding: 10.0,
                  ),
                  const SizedBox(width: 16),
                  _buildImageSocialButton(
                    backgroundColor: Colors.black,
                    iconData: Icons.apple,
                    iconColor: Colors.white,
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

  // --- 하단 헬퍼 함수들은 기존 코드와 동일 ---
  Widget _buildImageSocialButton({required Color backgroundColor, required IconData iconData, required Color iconColor, bool hasBorder = false}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: Colors.grey[300]!) : null,
      ),
      child: Center(child: Icon(iconData, color: iconColor, size: 32)),
    );
  }

  Widget _buildClippedImageSocialButton({
    required String imagePath,
    Color? backgroundColor,
    double iconPadding = 0.0,
    bool hasBorder = false,
    bool isLoading = false,
  }) {
    return Opacity(
      opacity: isLoading ? 0.5 : 1.0,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: hasBorder ? Border.all(color: Colors.grey[300]!) : null,
        ),
        child: isLoading 
            ? const Center(child: CircularProgressIndicator(strokeWidth: 2)) 
            : Padding(
                padding: EdgeInsets.all(iconPadding),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: Image.asset(imagePath, fit: BoxFit.cover),
                ),
              ),
      ),
    );
  }
}