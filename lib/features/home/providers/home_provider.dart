import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/home_repository.dart';

final growthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    debugPrint('[API 요청] 내 성장 필드 데이터 가져오기...');
    final repository = ref.watch(homeRepositoryProvider);
    final result = await repository.fetchGrowth();
    return result;
  } catch (e) {
    debugPrint('[API 에러] 내 성장 필드 실패: $e');
    // 에러 발생 시 무한 루프를 막기 위해 기본값 리턴
    return {
      'totalQuests': 0,
      'completedQuests': 0,
      'totalExp': 0,
      'nextLevelExp': 100,
    };
  }
});

final mainQuestProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final repository = ref.watch(homeRepositoryProvider);
    return await repository.fetchQuests(type: 'main');
  } catch (e) {
    // 어떤 에러든 빈 리스트를 반환하여 무한 재호출 방지
    return [];
  }
});

final subQuestProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final repository = ref.watch(homeRepositoryProvider);
    return await repository.fetchQuests(type: 'sub');
  } catch (e) {
    // 어떤 에러든 빈 리스트를 반환하여 무한 재호출 방지
    return [];
  }
});

final roadmapProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final repository = ref.watch(homeRepositoryProvider);
    return await repository.fetchRoadmap();
  } catch (e) {
    // 에러 발생 시 안전하게 기본 빈 로드맵 반환
    return {'title': '아직 생성된 로드맵이 없어요 🌱', 'progress_rate': 0, 'stages': []};
  }
});

final questTabProvider = NotifierProvider<QuestTabNotifier, int>(
  QuestTabNotifier.new,
);

class QuestTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int tab) => state = tab;
}

final roadmapExpandedProvider = NotifierProvider<RoadmapExpandedNotifier, bool>(
  RoadmapExpandedNotifier.new,
);

class RoadmapExpandedNotifier extends Notifier<bool> {
  @override
  bool build() => false;
  void toggle() => state = !state;
}

final questActionProvider = Provider<QuestActionService>((ref) {
  return QuestActionService(ref);
});

class QuestActionService {
  final Ref _ref;
  QuestActionService(this._ref);

  Future<void> completeQuest(int questId) async {
    try {
      debugPrint('[API 요청] 퀘스트 $questId 완료 처리...');
      final repository = _ref.read(homeRepositoryProvider);

      await repository.updateQuestStatus(questId, 'completed');

      _ref.invalidate(growthProvider);
      _ref.invalidate(mainQuestProvider);
      _ref.invalidate(subQuestProvider);
    } catch (e) {
      debugPrint('[API 에러] 퀘스트 완료 실패: $e');
      rethrow;
    }
  }
}
