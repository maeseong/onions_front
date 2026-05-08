import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // AuthController의 현재 상태(로딩 중인지 여부)를 구독
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

              // 일반 로그인 버튼
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    context.go('/home');
                  },
                  child: const Text('로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),

              // 소셜 로그인 영역
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

              // 소셜 로그인 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 카카오톡 로그인 연동
                  InkWell(
                    // 로딩 중일 때는 버튼 터치 방지
                    onTap: isLoading ? null : () async {
                      // 카카오 로그인 API 호출
                      final isNewUser = await ref.read(authControllerProvider.notifier).loginWithKakao();
                      
                      // 결과에 따른 분기 라우팅
                      if (context.mounted && isNewUser != null) {
                        if (isNewUser) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('신규 유저입니다. 온보딩으로 이동합니다.')));
                          // context.go('/onboarding');
                        } else {
                          context.go('/home');
                        }
                      } else if (context.mounted && isNewUser == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('로그인에 실패했습니다.')));
                      }
                    },
                    child: _buildClippedImageSocialButton(
                      imagePath: 'assets/images/kakao_logo.jpg',
                      isLoading: isLoading, // 로딩 상태 전달
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // 구글
                  _buildClippedImageSocialButton(
                    backgroundColor: Colors.white,
                    imagePath: 'assets/images/google_logo.webp',
                    hasBorder: true,
                    iconPadding: 10.0,
                  ),
                  const SizedBox(width: 16),
                  
                  // 애플
                  _buildImageSocialButton(
                    backgroundColor: Colors.black,
                    iconData: Icons.apple,
                    iconColor: Colors.white,
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // 회원가입 안내
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

  // 이미지 기반 소셜 버튼을 생성하는 함수
  Widget _buildImageSocialButton({required Color backgroundColor, required IconData iconData, required Color iconColor, bool hasBorder = false}) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: hasBorder ? Border.all(color: Colors.grey[300]!) : null,
      ),
      child: Center(
        child: Icon(iconData, color: iconColor, size: 32),
      ),
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
      // 로딩 중일 때 버튼을 흐리게 보이도록 처리
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
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, color: Colors.grey),
                  ),
                ),
              ),
      ),
    );
  }
}