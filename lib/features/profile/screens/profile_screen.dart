import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../repositories/profile_repository.dart';
import 'achievement_screen.dart';
import '../../home/providers/home_provider.dart'; 

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final profileAsync = ref.watch(profileProvider);
    // 홈 화면 퀘스트 진행도 데이터를 가져오기 위해 구독
    final growthAsync = ref.watch(growthProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        titleSpacing: 20.0,
        centerTitle: false,
        title: const Text('프로필', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          // 로그아웃 버튼 추가
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black87),
            tooltip: '로그아웃',
            onPressed: () => _showLogoutConfirmDialog(context, primaryColor),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('프로필을 불러오지 못했어요 😢')),
        data: (profile) {
          final spec = profile['spec'] ?? {};

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // 1. 상단 성장 퀘스트 카드
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60, height: 60,
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            child: const Icon(Icons.person, color: Colors.white, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(profile['name'] ?? profile['user_name'] ?? '-',
                                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    // 레벨 뱃지
                                    growthAsync.maybeWhen(
                                      data: (growth) {
                                        final int level = growth['level'] ?? 1;
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.25),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text('Lv.$level',
                                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                        );
                                      },
                                      orElse: () => const SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                                Text('${profile['grade'] ?? '-'}학년 · ${profile['jobName'] ?? profile['job_name'] ?? '-'}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 퀘스트 진행 + XP 바
                      growthAsync.maybeWhen(
                        data: (growth) {
                          final int completed = growth['completedQuests'] ?? 0;
                          final int total = growth['totalQuests'] ?? 10;
                          final int totalExp = growth['totalExp'] ?? 0;
                          final int level = growth['level'] ?? 1;
                          final int currentExp = totalExp % 1000;
                          final double questProgress = (completed / (total > 0 ? total : 10)).clamp(0.0, 1.0);
                          final double xpProgress = (currentExp / 1000).clamp(0.0, 1.0);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('완료한 퀘스트', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  Text('$completed / $total개', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: questProgress,
                                  backgroundColor: Colors.white24,
                                  color: Colors.white,
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Lv.$level XP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  Text('$currentExp / 1000 XP', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: xpProgress,
                                  backgroundColor: Colors.white24,
                                  color: Colors.yellowAccent,
                                  minHeight: 8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '다음 레벨까지 ${1000 - currentExp} XP 남았어요!',
                                style: const TextStyle(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          );
                        },
                        orElse: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(color: Colors.white))),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. 나의 스펙
                _buildSectionCard(
                  title: '나의 스펙',
                  action: GestureDetector(
                    onTap: () => _showEditSpecDialog(context, ref, spec, primaryColor),
                    child: _buildPillButton('수정', Icons.edit, primaryColor),
                  ),
                  child: GridView.count(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.6,
                    children: [
                      _buildSpecItem('학점', '${spec['gpa'] ?? '-'}/4.5', false),
                      _buildSpecItem('토익', '${spec['toeicScore'] ?? spec['toeic_score'] ?? '-'}', false),
                      _buildSpecItem('자격증', '${spec['certificateCount'] ?? spec['certificate_count'] ?? 0}개', false),
                      _buildSpecItem('인턴', '${spec['internshipCount'] ?? spec['internship_count'] ?? 0}회', (spec['internshipCount'] ?? spec['internship_count'] ?? 0) == 0),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. 업적 및 뱃지
                InkWell(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementScreen())),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: primaryColor.withOpacity(0.2)),
                    ),
                    child: Row(
                      children: [
                        Container(width: 48, height: 48, decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle), child: const Icon(Icons.emoji_events_outlined, color: Colors.white)),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('업적 및 뱃지', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('획득한 칭호와 뱃지를 확인하세요', style: TextStyle(color: Colors.black54, fontSize: 13)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: primaryColor),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 로그아웃 처리 다이얼로그
  void _showLogoutConfirmDialog(BuildContext context, Color primaryColor) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent,
        contentPadding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '로그아웃 할까요?', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                // 취소 버튼
                Expanded(
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: Colors.grey[200],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('취소', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                // 로그아웃 버튼
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: Size.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () async {
                      const storage = FlutterSecureStorage();
                      await storage.deleteAll(); // 기기의 모든 정보 비우기
                      if (context.mounted) {
                        Navigator.of(context).popUntil((route) => route.isFirst);
                        context.go('/login'); 
                      }
                    },
                    child: const Text('로그아웃', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 스펙 수정
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
                  style: ElevatedButton.styleFrom(backgroundColor: primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), elevation: 0),
                  onPressed: () async {
                    try {
                      final repository = ref.read(profileRepositoryProvider);
                      // 명세서에 맞게 데이터 전송
                      await repository.updateSpec({
                        'gpa': double.tryParse(gpaCtrl.text) ?? 0.0,
                        'toeicScore': int.tryParse(toeicCtrl.text) ?? 0,
                        'certificateCount': int.tryParse(certCtrl.text) ?? 0,
                        'internshipCount': int.tryParse(internCtrl.text) ?? 0,
                      });
                      
                      // 데이터 갱신 (프로필 화면 & 홈 화면 동시 반영)
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

  Widget _buildSectionCard({required String title, required Widget action, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey[100]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), action]),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildPillButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSpecItem(String title, String value, bool isWarning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isWarning ? Colors.red[100]! : Colors.grey[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isWarning ? Colors.red : Colors.black87)),
        ],
      ),
    );
  }
}