import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// 라우터 설정: 화면 이동 규칙
final GoRouter appRouter = GoRouter(
  initialLocation: '/home', // 앱을 켜면 가장 먼저 홈 화면이 나오게
  routes: [
    ShellRoute( // 네비게이션 바를 유지한 채로 내부 화면만 갈아끼워주는 역할
      builder: (context, state, child) {
        return MainNavigationScaffold(child: child);
      },
      routes: [
        GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
        GoRoute(path: '/ai', builder: (context, state) => const AiScreen()),
        GoRoute(path: '/schedule', builder: (context, state) => const ScheduleScreen()),
        GoRoute(path: '/company', builder: (context, state) => const CompanyScreen()),
        GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      ],
    ),
  ],
);

// 네비게이션 바 UI
class MainNavigationScaffold extends StatelessWidget {
  final Widget child;
  const MainNavigationScaffold({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/ai')) return 1;
    if (location.startsWith('/schedule')) return 2;
    if (location.startsWith('/company')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  // 탭을 눌렀을 때 해당 화면으로 이동시키는 함수
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0: context.go('/home'); break;
      case 1: context.go('/ai'); break;
      case 2: context.go('/schedule'); break;
      case 3: context.go('/company'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // 5개 화면 중 하나가 들어감
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI스펙진단'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: '일정'),
          BottomNavigationBarItem(icon: Icon(Icons.domain), label: '기업추천'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '프로필'),
        ],
      ),
    );
  }
}

// 임시 화면: 나중에 features 폴더로 각각 분리할 예정
class HomeScreen extends StatelessWidget { const HomeScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('홈 화면', style: TextStyle(fontSize: 24)))); }
class AiScreen extends StatelessWidget { const AiScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('AI 스펙 진단', style: TextStyle(fontSize: 24)))); }
class ScheduleScreen extends StatelessWidget { const ScheduleScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('일정', style: TextStyle(fontSize: 24)))); }
class CompanyScreen extends StatelessWidget { const CompanyScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('기업 추천', style: TextStyle(fontSize: 24)))); }
class ProfileScreen extends StatelessWidget { const ProfileScreen({super.key}); @override Widget build(BuildContext context) => const Scaffold(body: Center(child: Text('프로필', style: TextStyle(fontSize: 24)))); }