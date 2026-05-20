import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_provider.dart';
import '../../../core/constants/app_constants.dart';

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CompanyRepository(apiClient.dio, const FlutterSecureStorage());
});

class CompanyRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  CompanyRepository(this._dio, this._storage);

  // API 요청 헤더에 토큰 달아주기
  Future<Options> _getHeaders() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return Options(headers: {if (token != null) 'Authorization': 'Bearer $token'});
  }

  // 1. 맞춤형 추천 기업 목록 조회
  Future<Map<String, dynamic>> fetchRecommendedCompanies({
    String sort = 'match_rate',
    String? companyType,
  }) async {
    final response = await _dio.get(
      '/api/companies/recommended',
      queryParameters: {
        'sort': sort,
        // 전체(null)가 아니면 필터 값(대기업, 중견 등)을 보냄
        if (companyType != null && companyType != '전체') 'company_type': companyType,
      },
      options: await _getHeaders(),
    );
    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception('기업 목록 조회 실패');
  }

  // 2. 기업 상세 정보 조회
  Future<Map<String, dynamic>> fetchCompanyDetail(int companyId) async {
    final response = await _dio.get(
      '/api/companies/$companyId',
      options: await _getHeaders(),
    );
    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception('기업 상세 조회 실패');
  }

  // 3. 합격자 스펙 대비 갭 분석 조회
  Future<Map<String, dynamic>> fetchMatchAnalysis(int companyId) async {
    final response = await _dio.get(
      '/api/companies/$companyId/match-analysis',
      options: await _getHeaders(),
    );
    if (response.data['success'] == true) {
      return response.data['data'] ?? {};
    }
    throw Exception('매칭 분석 조회 실패');
  }

  // 4. 기업 스크랩 (찜하기)
  Future<void> scrapCompany(int companyId) async {
    final response = await _dio.post(
      '/api/companies/$companyId/scrap',
      options: await _getHeaders(),
    );
    if (response.data['success'] != true) {
      throw Exception('스크랩 실패');
    }
  }

  // 5. 기업 스크랩 취소
  Future<void> unscrapCompany(int companyId) async {
    final response = await _dio.delete(
      '/api/companies/$companyId/scrap',
      options: await _getHeaders(),
    );
    if (response.data['success'] != true) {
      throw Exception('스크랩 취소 실패');
    }
  }
}