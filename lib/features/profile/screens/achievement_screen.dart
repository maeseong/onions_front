import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class AchievementScreen extends ConsumerWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // 백엔드에서 뱃지와 프로필 정보를 가져옴
    final badgesAsync = ref.watch(badgesProvider);
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('업적 및 뱃지', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('정보를 불러오지 못했어요')),
        data: (profile) {
          final gamification = profile['gamification'] ?? {};
          final level = gamification['level'] ?? 1;
          final totalExp = gamification['totalExp'] ?? gamification['total_exp'] ?? 0;
          final nextLevelExp = level * 1000;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 레벨 및 나무 성장 단계 카드 (실제 XP 적용)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(24)),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.star, color: Colors.white, size: 30)),
                          const SizedBox(width: 16),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('현재 레벨', style: TextStyle(color: Colors.white70, fontSize: 13)), Text('Level $level', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))]),
                          const Spacer(),
                          const Icon(Icons.park, color: Colors.white, size: 48),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('성장 경험치', style: TextStyle(color: Colors.white, fontSize: 12)), Text('전체 보기 >', style: TextStyle(color: Colors.white70, fontSize: 12))]),
                      const SizedBox(height: 8),
                      Text('$totalExp / $nextLevelExp EXP', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: (totalExp / nextLevelExp).clamp(0.0, 1.0), backgroundColor: Colors.white24, color: Colors.white, minHeight: 8)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 2. 획득 칭호 (임시 고정 유지 - 명세서에 칭호 API는 별도로 없으므로 유지)
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
                        
                        // 아이콘 매핑 (이름에 따라 아이콘 변경, 기본값은 star)
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