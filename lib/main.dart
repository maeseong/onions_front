import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart'; // 라우터 불러오기

void main() {
  runApp(
    const ProviderScope(
      child: SpecCheckApp(),
    ),
  );
}

class SpecCheckApp extends StatelessWidget {
  const SpecCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router( // 기존 MaterialApp을 MaterialApp.router로 변경!
      title: 'SpecCheck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}