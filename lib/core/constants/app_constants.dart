import 'package:flutter/foundation.dart';

class AppConstants {
  AppConstants._();

  // 로컬
  static String get baseUrl {
    if (kIsWeb) return 'http://127.0.0.1:8000';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:8000',
      TargetPlatform.iOS => 'http://127.0.0.1:8000',
      TargetPlatform.macOS => 'http://127.0.0.1:8000',
      _ => 'http://127.0.0.1:8000',
    };
  }

  // 백엔드 연결 시 이거 사용
  // static const String productionBaseUrl = 'http://43.203.249.124:8080';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const String kakaoLoginPath = '/api/auth/kakao';
  static const String googleLoginPath = '/api/auth/google';
  static const String refreshTokenPath = '/api/auth/refresh';
  static const String logoutPath = '/api/auth/logout';

  static const Duration connectTimeout = Duration(seconds: 60);
  static const Duration receiveTimeout = Duration(seconds: 60);
}
