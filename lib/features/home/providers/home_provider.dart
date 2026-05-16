import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart'; // 💡 DioException 처리를 위해 반드시 추가!
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
    // 💡 404(데이터 없음) 에러일 경우 터지지 않고 빈 초기값 반환
    if (e is DioException && e.response?.statusCode == 404) {
      return {
        // 백엔드 모델 명칭(camel/snake)에 상관없이 파싱되도록 두 가지 모두 대비
        'totalQuests': 0, 'total_quests': 0,
        'completedQuests': 0, 'completed_quests': 0,
        'totalExp': 0, 'total_exp': 0,
        'nextLevelExp': 100, 'next_level_exp': 100,
      };
    }
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
    if (e is DioException && e.response?.statusCode == 404) {
      return []; // 빈 퀘스트 리스트 반환
    }
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
    if (e is DioException && e.response?.statusCode == 404) {
      return []; // 빈 퀘스트 리스트 반환
    }
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
    if (e is DioException && e.response?.statusCode == 404) {
      return {
        'title': '아직 생성된 로드맵이 없어요 🌱',
        'progress_rate': 0,
        'stages': [], // 스테이지 없음
      };
    }
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
      
      await repository.updateQuestStatus(questId, 'completed');
      debugPrint('[API 성공] 퀘스트 완료 처리됨!');
      
      _ref.invalidate(growthProvider);
      _ref.invalidate(mainQuestProvider);
      _ref.invalidate(subQuestProvider);
    } catch (e) {
      debugPrint('🚨 [API 에러] 퀘스트 완료 실패: $e');
      rethrow;
    }
  }
}