import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  // 비동기 작업을 위해 바인딩 확인
  WidgetsFlutterBinding.ensureInitialized(); 
  
  // 카카오 SDK 초기화 (발급받은 네이티브 앱 키 적용)
  KakaoSdk.init(
    nativeAppKey: 'a2cfc5c4bed69b5ea524042a0f9640d8',
  );

  await initializeDateFormatting('ko_KR', null);
  
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
    return MaterialApp.router(
      title: 'SpecCheck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
    );
  }
}