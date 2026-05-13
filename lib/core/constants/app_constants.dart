class AppConstants {
  AppConstants._();

  // 로컬
  static const String baseUrl = 'http://10.0.2.2:8000';
  // 백엔드 연결 시 이거 사용
  // static const String baseUrl = 'https://speccheck-production-c9e3.up.railway.app';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const String kakaoLoginPath = '/api/auth/kakao';
  static const String googleLoginPath = '/api/auth/google';
  static const String refreshTokenPath = '/api/auth/refresh';
  static const String logoutPath = '/api/auth/logout';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}