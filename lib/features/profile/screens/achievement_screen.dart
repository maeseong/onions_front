import 'package:flutter/material.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF61B099);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: const Text('업적 및 뱃지', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 레벨 및 나무 성장 단계 카드
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(width: 60, height: 60, decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle), child: const Icon(Icons.star, color: Colors.white, size: 30)),
                      const SizedBox(width: 16),
                      const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('현재 레벨', style: TextStyle(color: Colors.white70, fontSize: 13)), Text('Level 7', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))]),
                      const Spacer(),
                      const Icon(Icons.park, color: Colors.white, size: 48), // 나무 아이콘
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('성장하는 나무 단계', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.eco, color: Colors.white, size: 20), Icon(Icons.arrow_forward, color: Colors.white38, size: 16), Icon(Icons.forest, color: Colors.white, size: 24)]),
                  const SizedBox(height: 24),
                  const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('성장 경험치', style: TextStyle(color: Colors.white, fontSize: 12)), Text('650 / 1000 EXP', style: TextStyle(color: Colors.white, fontSize: 12))]),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(10), child: const LinearProgressIndicator(value: 0.65, backgroundColor: Colors.white24, color: Colors.white, minHeight: 8)),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // 획득 칭호
            const Text('획득 칭호', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                _buildTitleTag('🌱 새싹 탐험가', true, primaryColor),
                _buildTitleTag('🌿 어린 나무', true, primaryColor),
                _buildTitleTag('🌳 성장하는 나무', true, primaryColor),
                _buildTitleTag('🌲 푸른 숲 관리자 🔒', false, primaryColor),
              ],
            ),
            const SizedBox(height: 32),

            // 뱃지 컬렉션
            const Text('뱃지 컬렉션', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3, mainAxisSpacing: 16, crossAxisSpacing: 16,
              children: [
                _buildBadgeItem('첫 새싹', Icons.eco, true, primaryColor),
                _buildBadgeItem('가지 확장', Icons.account_tree, true, primaryColor),
                _buildBadgeItem('나무 성장', Icons.park, true, primaryColor),
                _buildBadgeItem('행운의 잎', Icons.yard, true, primaryColor),
                _buildBadgeItem('가을 수확', Icons.bakery_dining, false, primaryColor),
                _buildBadgeItem('숲 완성', Icons.forest, false, primaryColor),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleTag(String label, bool isUnlocked, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: isUnlocked ? color.withOpacity(0.1) : Colors.grey[100], borderRadius: BorderRadius.circular(20), border: Border.all(color: isUnlocked ? color.withOpacity(0.2) : Colors.transparent)),
      child: Text(label, style: TextStyle(color: isUnlocked ? color : Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }

  Widget _buildBadgeItem(String name, IconData icon, bool isUnlocked, Color color) {
    return Column(
      children: [
        Container(
          width: 60, height: 60,
          decoration: BoxDecoration(color: isUnlocked ? Colors.white : Colors.grey[50], shape: BoxShape.circle, border: Border.all(color: isUnlocked ? color.withOpacity(0.2) : Colors.grey[200]!), boxShadow: isUnlocked ? [BoxShadow(color: color.withOpacity(0.1), blurRadius: 8)] : null),
          child: Icon(icon, color: isUnlocked ? color : Colors.grey[300], size: 30),
        ),
        const SizedBox(height: 8),
        Text(name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isUnlocked ? Colors.black87 : Colors.grey)),
      ],
    );
  }
}