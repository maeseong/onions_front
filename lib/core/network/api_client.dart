import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage;
  
  // 백엔드 기본 주소(명세서 기준)
  // 테스트 시에는 'http://10.0.2.2:8000' 또는 실제 서버 주소 입력
  static const String baseUrl = 'http://localhost:8000';

  ApiClient()
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          contentType: 'application/json',
          // 요청 제한 시간 설정 (10초)
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        )),
        storage = const FlutterSecureStorage() {
    
    // 모든 요청과 응답을 중간에서 가로채서 처리
    dio.interceptors.add(InterceptorsWrapper(
      
      // 요청을 보내기 직전(토큰 끼워넣기)
      onRequest: (options, handler) async {
        // 기기에 저장된 액세스 토큰을 꺼내옴
        final accessToken = await storage.read(key: 'access_token');
        
        // 토큰이 있다면 헤더에 장착
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        return handler.next(options);
      },

      // 에러가 발생했을 때(401 만료 시 토큰 재발급)
      onError: (DioException e, handler) async {
        // 에러 코드가 401(권한 없음/만료)인 경우
        if (e.response?.statusCode == 401) {
          final refreshToken = await storage.read(key: 'refresh_token');
          
          // 리프레시 토큰이 없으면 로그아웃 처리 등 로직 필요(그대로 에러 반환)
          if (refreshToken == null) {
            return handler.next(e);
          }

          try {
            // 새로운 액세스 토큰 발급 요청
            final refreshResponse = await Dio().post(
              '$baseUrl/api/auth/refresh',
              data: {'refresh_token': refreshToken},
            );

            // 발급 성공 시 새 토큰을 저장소에 업데이트
            final newAccessToken = refreshResponse.data['data']['access_token'];
            await storage.write(key: 'access_token', value: newAccessToken);

            // 실패했던 원래의 요청을 새 토큰과 함께 재시도
            e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await dio.fetch(e.requestOptions);
            
            return handler.resolve(retryResponse); // 성공한 결과로 덮어씌워서 반환

          } catch (refreshError) {
            // 재발급조차 실패하면 완전 로그아웃 처리 후 로그인 화면으로 이동시켜야 함
            await storage.deleteAll();
            return handler.next(e);
          }
        }
        
        // 401 에러가 아니면 그냥 그대로 에러 반환
        return handler.next(e);
      },
    ));
  }
}