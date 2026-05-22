import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';
import '../../home/providers/home_provider.dart';

class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // 백엔드에서 뱃지와 프로필 정보를 가져옴
    final badgesAsync = ref.watch(badgesProvider);
    final profileAsync = ref.watch(profileProvider);
    // 홈 화면 성장 필드 정보 구독
    final growthAsync = ref.watch(growthProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('업적 및 뱃지', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('정보를 불러오지 못했어요')),
        data: (profile) {
          final gamification = profile['gamification'] ?? {};
          final level = gamification['level'] ?? 1; // 칭호 처리를 위해 내부 변수만 유지

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 레벨 및 퀘스트 성장 단계 카드
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(24)),
                  child: Column(
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
                                Text(profile['name'] ?? profile['user_name'] ?? '-', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                Text('${profile['grade'] ?? '-'}학년 · ${profile['jobName'] ?? profile['job_name'] ?? '-'}', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                              ],
                            ),
                          ),
                          const Icon(Icons.park, color: Colors.white, size: 48),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // 퀘스트 데이터 바인딩
                      growthAsync.maybeWhen(
                        data: (growth) {
                          final int completed = growth['completedQuests'] ?? 0;
                          final int total = growth['totalQuests'] ?? 10;
                          final double progress = (completed / (total > 0 ? total : 10)).clamp(0.0, 1.0);

                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween, 
                                children: [
                                  const Text('퀘스트 달성도', style: TextStyle(color: Colors.white, fontSize: 12)), 
                                  Text('$completed / $total개', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))
                                ]
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10), 
                                child: LinearProgressIndicator(value: progress, backgroundColor: Colors.white24, color: Colors.white, minHeight: 8)
                              ),
                              const SizedBox(height: 8),
                              const Text('다음 성장 단계까지 얼마 남지 않았어요!', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            ],
                          );
                        },
                        orElse: () => const LinearProgressIndicator(backgroundColor: Colors.white24, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. 획득 칭호
                const Text('획득 칭호', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _buildTitleTag('🌱 새싹 탐험가', level >= 1, primaryColor),
                    _buildTitleTag('🌿 어린 나무', level >= 3, primaryColor),
                    _buildTitleTag('🌳 성장하는 나무', level >= 5, primaryColor),
                    _buildTitleTag('🌲 푸른 숲 관리자', level >= 10, primaryColor),
                  ],
                ),
                const SizedBox(height: 32),

                // 3. 뱃지 컬렉션
                const Text('뱃지 컬렉션', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                badgesAsync.when(
                  loading: () => const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator())),
                  error: (e, _) => const Center(child: Text('뱃지 목록을 불러오지 못했어요')),
                  data: (badges) {
                    if (badges.isEmpty) return const Center(child: Text('아직 획득한 뱃지가 없어요 🌱'));
                    
                    return GridView.count(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16,
                      children: badges.map((badge) {
                        final name = badge['name'] ?? badge['badge_name'] ?? '알 수 없음';
                        final isUnlocked = badge['isUnlocked'] ?? badge['is_unlocked'] ?? false;
                        
                        // 아이콘 매핑
                        IconData iconData = Icons.star;
                        if (name.contains('첫') || name.contains('새싹')) iconData = Icons.eco;
                        if (name.contains('성장') || name.contains('나무')) iconData = Icons.park;
                        if (name.contains('연속') || name.contains('출석')) iconData = Icons.local_fire_department;
                        if (name.contains('완성')) iconData = Icons.forest;

                        return _buildBadgeItem(name, iconData, isUnlocked, primaryColor);
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitleTag(String label, bool isUnlocked, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: isUnlocked ? color.withOpacity(0.1) : Colors.grey[100], borderRadius: BorderRadius.circular(20), border: Border.all(color: isUnlocked ? color.withOpacity(0.2) : Colors.transparent)),
      child: Text(
        isUnlocked ? label : '$label 🔒', 
        style: TextStyle(color: isUnlocked ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13),
      ),
    );
  }

  Widget _buildBadgeItem(String name, IconData icon, bool isUnlocked, Color color) {
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(
            color: isUnlocked ? Colors.white : Colors.grey[50], 
            shape: BoxShape.circle, 
            border: Border.all(color: isUnlocked ? color.withOpacity(0.2) : Colors.grey[200]!), 
            boxShadow: isUnlocked ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)] : null
          ),
          child: Icon(icon, color: isUnlocked ? color : Colors.grey[300], size: 30),
        ),
        const SizedBox(height: 8),
        Text(
          name, 
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black87 : Colors.grey),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}