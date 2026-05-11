import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/company_repository.dart';

// 필터 타입 (전체, 대기업, 중견, 스타트업)
final companyFilterProvider = NotifierProvider<CompanyFilterNotifier, String?>(
  CompanyFilterNotifier.new,
);

class CompanyFilterNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? type) => state = type;
}

// 추천 기업 목록
final recommendedCompaniesProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final filter = ref.watch(companyFilterProvider);
  final repository = ref.watch(companyRepositoryProvider);
  return repository.fetchRecommendedCompanies(companyType: filter);
});

// 기업 상세
final companyDetailProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, companyId) async {
  final repository = ref.watch(companyRepositoryProvider);
  return repository.fetchCompanyDetail(companyId);
});

// 기업 매칭 분석
final matchAnalysisProvider = FutureProvider.family<Map<String, dynamic>, int>((ref, companyId) async {
  final repository = ref.watch(companyRepositoryProvider);
  return repository.fetchMatchAnalysis(companyId);
});