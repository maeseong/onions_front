import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spec_check/features/home/models/career_growth_model.dart';
import '../../home/providers/home_provider.dart';
import 'ai_chat_screen.dart';

class AiScreen extends ConsumerWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // 온보딩 과정에서 전송했던 사용자의 실제 스펙 데이터 소스를 구독
    final growthAsync = ref.watch(growthProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: const Text('AI 스펙 진단', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('스펙 수정하기', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: growthAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('스펙 정보를 불러오지 못했어요 😢', style: TextStyle(color: Colors.black54))),
        data: (growthJson) {
          // 데이터 파싱
          final growthData = CareerGrowthModel.fromJson(growthJson);

          // API 명세 규격에 맞게 온보딩 학년, 직무 정보 매핑 (백엔드 JSON 키 대응)
          final String userGrade = growthJson['grade']?.toString() ?? '전체';
          final String userJob = growthJson['jobName'] ?? growthJson['job_name'] ?? '개발';
          final String userName = growthJson['name'] ?? growthJson['user_name'] ?? '사용자';

          // 백엔드로부터 넘어온 실제 스펙 지표들 추출
          final double gpa = (growthJson['gpa'] as num?)?.toDouble() ?? 0.0;
          final int toeic = (growthJson['toeicScore'] ?? growthJson['toeic_score'] as num?)?.toInt() ?? 0;
          final int certificate = (growthJson['certificateCount'] ?? growthJson['certificate_count'] as num?)?.toInt() ?? 0;
          final int internship = (growthJson['internshipCount'] ?? growthJson['internship_count'] as num?)?.toInt() ?? 0;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 실시간 유저 정보 바인딩
                Text('$userGrade · $userJob · $userName', style: const TextStyle(color: Colors.black54, fontSize: 14)),
                const SizedBox(height: 24),

                // 현재 스펙 영역
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('나의 현재 스펙', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),

                      // 실시간 DB 데이터 그리드 표출
                      Row(
                        children: [
                          Expanded(child: _buildSpecItem('🎓', '학점', '$gpa/4.5', gpa < 3.0)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSpecItem('🌐', '어학 성적', toeic > 0 ? 'TOEIC $toeic' : '기록 없음', toeic == 0)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildSpecItem('📜', '자격증', '$certificate개 보유', false)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSpecItem('💼', '인턴십', internship > 0 ? '$internship회 경험' : '경험 없음', internship == 0)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 챗봇 진입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AiChatScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('AI와 스펙 진단하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSpecItem(String icon, String title, String value, bool isWarning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF0F0) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isWarning ? Colors.red[200]! : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.redAccent : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}