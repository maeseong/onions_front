import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_provider.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRepository(apiClient.dio);
});

class HomeRepository {
  final Dio _dio;
  HomeRepository(this._dio);

  int _totalExp = 750;
  int _nextLevelExp = 1000;
  int _totalQuests = 15;
  int _completedQuests = 5;

  // 💡 메인 퀘스트에도 'is_repeatable': true 스위치를 모두 켜두었습니다!
  final List<Map<String, dynamic>> _mainQuests = [
    {'quest_id': 1, 'title': 'Spring Boot 핵심 원리 완강하기 ♾️', 'status': 'in_progress', 'exp_reward': 200, 'is_repeatable': true},
    {'quest_id': 2, 'title': '정보처리기사 실기 기출문제 3회독 ♾️', 'status': 'not_started', 'exp_reward': 300, 'is_repeatable': true},
    {'quest_id': 3, 'title': '개인 프로젝트 API 명세서 작성 ♾️', 'status': 'in_progress', 'exp_reward': 250, 'is_repeatable': true},
  ];

  final List<Map<String, dynamic>> _subQuests = [
    {'quest_id': 4, 'title': '이력서 및 포트폴리오 초안 작성', 'status': 'in_progress', 'exp_reward': 50},
    {'quest_id': 5, 'title': 'IT 기술 블로그 첫 글 포스팅', 'status': 'completed', 'exp_reward': 100},
    {'quest_id': 6, 'title': '오늘의 알고리즘 1문제 풀기 ♾️', 'status': 'in_progress', 'exp_reward': 20, 'is_repeatable': true},
  ];

  // 1. 성장도 조회
  Future<Map<String, dynamic>> fetchGrowth() async {
    await Future.delayed(const Duration(milliseconds: 300)); 
    return {
      'totalQuests': _totalQuests,
      'completedQuests': _completedQuests,
      'totalExp': _totalExp, 
      'nextLevelExp': _nextLevelExp, 
    };
  }

  // 2. 내 로드맵 조회
  Future<Map<String, dynamic>> fetchRoadmap() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'title': '신입 백엔드 개발자 마스터 패스 🚀',
      'progress_rate': 65,
      'stages': [
        {'stage_order': 1, 'stage_name': '프로그래밍 기초', 'description': 'Java와 객체지향의 이해'},
        {'stage_order': 2, 'stage_name': '웹 프레임워크', 'description': 'Spring Boot와 MVC 패턴'},
        {'stage_order': 3, 'stage_name': '데이터베이스', 'description': 'MySQL 설계 및 JPA 연동'},
        {'stage_order': 4, 'stage_name': '실전 프로젝트', 'description': '팀 프로젝트 및 AWS 배포'},
      ]
    };
  }

  Future<List<dynamic>> fetchRoadmapSteps() async {
    return [];
  }

  // 3. 퀘스트 목록 조회
  Future<List<dynamic>> fetchQuests({String type = 'main'}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return type == 'main' ? _mainQuests : _subQuests;
  }
  
  // 4. 퀘스트 상태 변경
  Future<void> updateQuestStatus(int questId, String status) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    Map<String, dynamic>? targetQuest;
    for (var q in _mainQuests) {
      if (q['quest_id'] == questId) targetQuest = q;
    }
    for (var q in _subQuests) {
      if (q['quest_id'] == questId) targetQuest = q;
    }

    if (targetQuest != null) {
      final isRepeatable = targetQuest['is_repeatable'] == true;

      if (!isRepeatable && targetQuest['status'] == 'completed') return;

      if (isRepeatable) {
        _totalExp += (targetQuest['exp_reward'] as int);
        debugPrint('♾️ 무한 퀘스트 클릭! 경험치 누적: +${targetQuest['exp_reward']} (현재: $_totalExp)');
      } else {
        targetQuest['status'] = 'completed';
        _completedQuests += 1;
        _totalExp += (targetQuest['exp_reward'] as int);
      }

      if (_totalExp >= _nextLevelExp) {
        _totalExp = _totalExp - _nextLevelExp; 
        _nextLevelExp += 500; 
      }
    }
  }
}