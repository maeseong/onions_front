import 'package:flutter/foundation.dart'; // debugPrint 사용을 위해 추가
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/home_repository.dart';

// 성장도 데이터
final growthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    debugPrint('[API 요청] 내 성장 필드 데이터 가져오기...');
    final repository = ref.watch(homeRepositoryProvider);
    final result = await repository.fetchGrowth();
    debugPrint('[API 성공] 내 성장 필드 데이터: $result');
    return result;
  } catch (e) {
    debugPrint('[API 에러] 내 성장 필드 실패: $e');
    rethrow;
  }
});

// 메인 퀘스트 목록
final mainQuestProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    debugPrint('[API 요청] 메인 퀘스트 목록 가져오기...');
    final repository = ref.watch(homeRepositoryProvider);
    final result = await repository.fetchQuests(type: 'main');
    debugPrint('[API 성공] 메인 퀘스트 데이터: $result');
    return result;
  } catch (e) {
    debugPrint('[API 에러] 메인 퀘스트 실패: $e');
    rethrow;
  }
});

// 서브 퀘스트 목록
final subQuestProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    debugPrint('[API 요청] 서브 퀘스트 목록 가져오기...');
    final repository = ref.watch(homeRepositoryProvider);
    final result = await repository.fetchQuests(type: 'sub');
    debugPrint('[API 성공] 서브 퀘스트 데이터: $result');
    return result;
  } catch (e) {
    debugPrint('[API 에러] 서브 퀘스트 실패: $e');
    rethrow;
  }
});

// 로드맵 데이터
final roadmapProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  try {
    debugPrint('[API 요청] 로드맵 데이터 가져오기...');
    final repository = ref.watch(homeRepositoryProvider);
    final result = await repository.fetchRoadmap();
    debugPrint('[API 성공] 로드맵 데이터: $result');
    return result;
  } catch (e) {
    debugPrint('[API 에러] 로드맵 데이터 실패: $e');
    rethrow;
  }
});

// 현재 선택된 퀘스트 탭 (0: 메인, 1: 서브)
final questTabProvider = NotifierProvider<QuestTabNotifier, int>(QuestTabNotifier.new);

class QuestTabNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int tab) => state = tab;
}

// 로드맵 펼치기 상태 (true: 펼침, false: 접힘)
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
      
      // 1. 백엔드에 완료 처리 요청
      await repository.updateQuestStatus(questId, 'completed');
      debugPrint('[API 성공] 퀘스트 완료 처리됨!');
      
      // 2. 요청이 성공하면 기존 데이터를 무효화하여 서버에서 다시 불러오게 함
      _ref.invalidate(growthProvider);
      _ref.invalidate(mainQuestProvider);
      _ref.invalidate(subQuestProvider);
    } catch (e) {
      debugPrint('🚨 [API 에러] 퀘스트 완료 실패: $e');
      rethrow;
    }
  }
}