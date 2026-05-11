// lib/features/home/repositories/home_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_provider.dart';
import '../models/career_growth_model.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRepository(apiClient.dio);
});

class HomeRepository {
  final Dio _dio;

  HomeRepository(this._dio);

  Future<CareerGrowthModel> getCareerGrowth() async {
    // UI 확인용 가짜 데이터 로직
    // 통신하는 척 1초 대기
    await Future.delayed(const Duration(seconds: 1));

    // API 명세서에 있던 예시 데이터를 그대로 넣었습니다.
    return CareerGrowthModel(
      growthRate: 40,      // 경험치 바 40%
      level: 7,            // 레벨 7
      totalExp: 620,       // 현재 경험치
      nextLevelExp: 1000,  // 다음 레벨 경험치
      streakDays: 5,       // 연속 5일
    );

    /* 나중에 백엔드 서버가 켜지면, 위의 가짜 데이터 반환 로직을 지우고 아래 주석을 해제하세요
    try {
      final response = await _dio.get('/api/career/growth');
      if (response.data['success'] == true) {
        return CareerGrowthModel.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? '데이터 불러오기 실패');
    } catch (e) {
      throw Exception('성장도 정보를 가져오는데 실패했습니다: $e');
    }
    */
  }
}