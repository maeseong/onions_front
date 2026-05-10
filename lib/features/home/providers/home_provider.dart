import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/home_repository.dart';

// 성장도 데이터
final growthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchGrowth();
});

// 메인 퀘스트 목록
final mainQuestProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchQuests(type: 'main');
});

// 서브 퀘스트 목록
final subQuestProvider = FutureProvider<List<dynamic>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchQuests(type: 'sub');
});

// 현재 선택된 퀘스트 탭 (0: 메인, 1: 서브)
final questTabProvider = NotifierProvider<QuestTabNotifier, int>(QuestTabNotifier.new);

class QuestTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int tab) => state = tab;
}