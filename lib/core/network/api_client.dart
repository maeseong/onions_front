import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient()
      : dio = Dio(BaseOptions(
          baseUrl: AppConstants.baseUrl,
          contentType: 'application/json',
          connectTimeout: AppConstants.connectTimeout,
          receiveTimeout: AppConstants.receiveTimeout,
        )),
        storage = const FlutterSecureStorage() {
    dio.interceptors.add(InterceptorsWrapper(
      // 요청을 보내기 직전(토큰 끼워넣기 제어)
      onRequest: (options, handler) async {
        // 토큰이 필요 없는 경로 목록 정의
        final noTokenPaths = [
          '/api/auth/login',
          '/api/auth/kakao',
          '/api/auth/google',
          AppConstants.refreshTokenPath, // /api/auth/refresh
        ];

        // 현재 요청 경로가 토큰이 필요한 경로인지 확인
        // (noTokenPaths에 포함되지 않은 경우에만 토큰을 넣음)
        bool requiresToken = !noTokenPaths.any((path) => options.path.contains(path));

        if (requiresToken) {
          final accessToken = await storage.read(key: AppConstants.accessTokenKey);
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
        }
        
        return handler.next(options);
      },

      // 에러가 발생했을 때(401 만료 시 토큰 재발급)
      onError: (DioException e, handler) async {
        if (e.response?.statusCode == 401) {
          final refreshToken = await storage.read(key: AppConstants.refreshTokenKey);

          if (refreshToken == null) {
            return handler.next(e);
          }

          try {
            final refreshResponse = await Dio().post(
              '${AppConstants.baseUrl}${AppConstants.refreshTokenPath}',
              data: {'refreshToken': refreshToken},
            );

            final newAccessToken = refreshResponse.data['data']['accessToken'];
            await storage.write(key: AppConstants.accessTokenKey, value: newAccessToken);

            e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(e.requestOptions);
            return handler.resolve(retryResponse);
          } catch (refreshError) {
            await storage.deleteAll();
            return handler.next(e);
          }
        }

        return handler.next(e);
      },
    ));
  }
}