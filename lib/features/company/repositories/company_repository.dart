import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_provider.dart';

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CompanyRepository(apiClient.dio);
});

class CompanyRepository {
  final Dio _dio;
  CompanyRepository(this._dio);

  // 추천 기업 목록
  Future<Map<String, dynamic>> fetchRecommendedCompanies({
    String sort = 'match_rate',
    String? companyType,
  }) async {
    final response = await _dio.get(
      '/api/companies/recommended',
      queryParameters: {
        'sort': sort,
        if (companyType != null) 'company_type': companyType,
      },
    );
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('기업 목록 조회 실패');
  }

  // 기업 상세
  Future<Map<String, dynamic>> fetchCompanyDetail(int companyId) async {
    final response = await _dio.get('/api/companies/$companyId');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('기업 상세 조회 실패');
  }

  // 기업 매칭 분석
  Future<Map<String, dynamic>> fetchMatchAnalysis(int companyId) async {
    final response = await _dio.get('/api/companies/$companyId/match-analysis');
    if (response.data['success'] == true) {
      return response.data['data'];
    }
    throw Exception('매칭 분석 조회 실패');
  }

  // 스크랩 추가
  Future<void> scrapCompany(int companyId) async {
    await _dio.post('/api/companies/$companyId/scrap');
  }

  // 스크랩 삭제
  Future<void> unscrapCompany(int companyId) async {
    await _dio.delete('/api/companies/$companyId/scrap');
  }
}