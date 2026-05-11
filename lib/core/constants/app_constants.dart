class AppConstants {
  AppConstants._();

  static const String baseUrl = 'http://10.0.2.2:8000';

  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';

  static const String kakaoLoginPath = '/api/auth/kakao';
  static const String googleLoginPath = '/api/auth/google';
  static const String refreshTokenPath = '/api/auth/refresh';
  static const String logoutPath = '/api/auth/logout';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}