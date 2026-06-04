import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/portfolio_repository.dart';

// 포트폴리오 목록 상태
final portfolioProvider = AsyncNotifierProvider<PortfolioNotifier, List<Map<String, dynamic>>>(
  PortfolioNotifier.new,
);

class PortfolioNotifier extends AsyncNotifier<List<Map<String, dynamic>>> {
  @override
  Future<List<Map<String, dynamic>>> build() async {
    return ref.read(portfolioRepositoryProvider).getPortfolios();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(portfolioRepositoryProvider).getPortfolios(),
    );
  }

  Future<void> create(Map<String, dynamic> body) async {
    await ref.read(portfolioRepositoryProvider).createPortfolio(body);
    await refresh();
  }

  Future<void> updatePortfolio(int id, Map<String, dynamic> body) async {
    await ref.read(portfolioRepositoryProvider).updatePortfolio(id, body);
    await refresh();
  }

  Future<void> delete(int id) async {
    await ref.read(portfolioRepositoryProvider).deletePortfolio(id);
    await refresh();
  }
}
