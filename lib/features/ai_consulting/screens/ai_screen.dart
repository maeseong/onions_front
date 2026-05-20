import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/profile_provider.dart';
import '../../profile/repositories/profile_repository.dart';
import '../../home/providers/home_provider.dart';
import 'ai_chat_screen.dart';

class AiScreen extends ConsumerWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // 온보딩에서 입력한 사용자의 실제 상세 스펙이 들어있는 프로필 프로바이더를 구독
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        titleSpacing: 20.0,
        centerTitle: false,
        title: const Text('AI 스펙진단', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          // 프로필 화면의 데이터 원천을 비동기식 데이터 상태에서 안전하게 꺼내어 바텀시트로 넘기기
          profileAsync.maybeWhen(
            data: (profile) {
              final spec = profile['spec'] ?? {};
              return TextButton(
                onPressed: () => _showEditSpecDialog(context, ref, spec, primaryColor),
                child: Text('스펙 수정하기', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('스펙 정보를 불러오지 못했어요 😢', style: TextStyle(color: Colors.black54))),
        data: (profile) {
          // 데이터 바인딩 및 가짜 껍데기 완전 제거
          final spec = profile['spec'] ?? {};
          final String userName = profile['name'] ?? profile['user_name'] ?? '사용자';

          final double gpa = (spec['gpa'] as num?)?.toDouble() ?? 0.0;
          final int toeic = (spec['toeicScore'] ?? spec['toeic_score'] as num?)?.toInt() ?? 0;
          final int certificate = (spec['certificateCount'] ?? spec['certificate_count'] as num?)?.toInt() ?? 0;
          final int internship = (spec['internshipCount'] ?? spec['internship_count'] as num?)?.toInt() ?? 0;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$userName님의 스펙 데이터', style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
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

                      // 실시간 온보딩/수정 데이터 바인딩 그리드
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

  // 스펙 수정 모달 바텀 시트 로직 이식
  void _showEditSpecDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> currentSpec, Color primaryColor) {
    final gpaCtrl = TextEditingController(text: currentSpec['gpa']?.toString() ?? '');
    final toeicCtrl = TextEditingController(text: (currentSpec['toeicScore'] ?? currentSpec['toeic_score'])?.toString() ?? '');
    final certCtrl = TextEditingController(text: (currentSpec['certificateCount'] ?? currentSpec['certificate_count'])?.toString() ?? '');
    final internCtrl = TextEditingController(text: (currentSpec['internshipCount'] ?? currentSpec['internship_count'])?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('내 스펙 수정하기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              _buildEditField('학점 (GPA)', gpaCtrl, TextInputType.number),
              _buildEditField('토익 점수', toeicCtrl, TextInputType.number),
              _buildEditField('자격증 개수', certCtrl, TextInputType.number),
              _buildEditField('인턴십 경험 횟수', internCtrl, TextInputType.number),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity, height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor, 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
                    elevation: 0
                  ),
                  onPressed: () async {
                    try {
                      final repository = ref.read(profileRepositoryProvider);
                      
                      // 백엔드 명세대로 데이터 구조 패치
                      await repository.updateSpec({
                        'gpa': double.tryParse(gpaCtrl.text) ?? 0.0,
                        'toeicScore': int.tryParse(toeicCtrl.text) ?? 0,
                        'certificateCount': int.tryParse(certCtrl.text) ?? 0,
                        'internshipCount': int.tryParse(internCtrl.text) ?? 0,
                      });
                      
                      // 수동으로 프로필과 홈 화면의 캐시 데이터를 무효화하여 화면을 즉시 동기화
                      ref.invalidate(profileProvider);
                      ref.invalidate(growthProvider); 

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('스펙이 성공적으로 수정되었습니다! 🌱')));
                      }
                    } catch (e) {
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('스펙 수정에 실패했어요.')));
                    }
                  },
                  child: const Text('수정 완료', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          filled: true, fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
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