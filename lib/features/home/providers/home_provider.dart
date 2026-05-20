import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; 
import '../repositories/home_repository.dart';

final growthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    debugPrint('[API 요청] 내 성장 필드 데이터 가져오기...');
    final repository = ref.watch(homeRepositoryProvider);
    final result = await repository.fetchGrowth();
    return result;
  } catch (e) {
    debugPrint('[API 에러] 내 성장 필드 실패: $e');
    if (e is DioException && e.response?.statusCode == 404) {
      return {
        'totalQuests': 0, 'completedQuests': 0,
        'totalExp': 0, 'nextLevelExp': 100,
      };
    }
    rethrow;
  }
});

final mainQuestProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final repository = ref.watch(homeRepositoryProvider);
    return await repository.fetchQuests(type: 'main');
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 404) return [];
    rethrow;
  }
});

final subQuestProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final repository = ref.watch(homeRepositoryProvider);
    return await repository.fetchQuests(type: 'sub');
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 404) return [];
    rethrow;
  }
});

final roadmapProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    final repository = ref.watch(homeRepositoryProvider);
    return await repository.fetchRoadmap();
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 404) {
      return {'title': '아직 생성된 로드맵이 없어요 🌱', 'progress_rate': 0, 'stages': []};
    }
    rethrow;
  }
});

final questTabProvider = NotifierProvider<QuestTabNotifier, int>(QuestTabNotifier.new);
class QuestTabNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int tab) => state = tab;
}

final roadmapExpandedProvider = NotifierProvider<RoadmapExpandedNotifier, bool>(RoadmapExpandedNotifier.new);
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
      
      // 진짜 백엔드 서버에 퀘스트 완료 요청
      await repository.updateQuestStatus(questId, 'completed');
      
      // 완료 후 화면 데이터들을 강제로 새로고침하여 최신 상태 유지
      _ref.invalidate(growthProvider);
      _ref.invalidate(mainQuestProvider);
      _ref.invalidate(subQuestProvider);
    } catch (e) {
      debugPrint('[API 에러] 퀘스트 완료 실패: $e');
      rethrow;
    }
  }
}