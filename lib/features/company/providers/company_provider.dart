import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../repositories/company_repository.dart';

final companyFilterProvider = NotifierProvider<CompanyFilterNotifier, String?>(
  CompanyFilterNotifier.new,
);

class CompanyFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? type) => state = type;
}

// 추천 기업 목록
final recommendedCompaniesProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  try {
    final filter = ref.watch(companyFilterProvider);
    final repository = ref.watch(companyRepositoryProvider);
    return await repository.fetchRecommendedCompanies(companyType: filter);
  } catch (e) {
    debugPrint('[API 에러] 추천 기업 목록 실패: $e');
    if (e is DioException && e.response?.statusCode == 404) {
      return {'total': 0, 'companies': []};
    }
    rethrow;
  }
});

// 기업 상세
final companyDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  companyId,
) async {
  final repository = ref.watch(companyRepositoryProvider);
  return await repository.fetchCompanyDetail(companyId);
});

// 기업 매칭 갭 분석
final matchAnalysisProvider = FutureProvider.family<Map<String, dynamic>, int>((
  ref,
  companyId,
) async {
  final repository = ref.watch(companyRepositoryProvider);
  return await repository.fetchMatchAnalysis(companyId);
});
