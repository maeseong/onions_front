import 'package:go_router/go_router.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/schedule/screens/schedule_screen.dart';
import '../../features/ai_consulting/screens/ai_screen.dart';
import '../../features/company/screens/company_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../shared/widgets/main_navigation_scaffold.dart';
import '../../features/auth/screens/onboarding_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    // 네비게이션 바가 없는 단독 화면들
    GoRoute(path: '/splash', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(path: '/onboarding', builder: (context, state) => const OnboardingScreen()),

    // 네비게이션 바가 있는 메인 화면들
    ShellRoute(
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