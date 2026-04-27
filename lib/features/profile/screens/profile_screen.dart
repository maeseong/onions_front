import 'package:flutter/material.dart';
import 'achievement_screen.dart'; // 상세 화면 연결을 위해 필요

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF61B099); // 피그마 메인 초록색

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('프로필', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(color: Colors.grey[100], shape: BoxShape.circle),
            child: IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.black87), onPressed: () {}),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // 1. 상단 성장 경험치 카드
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
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('김성장', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('취업 준비생 · 백엔드 개발자', style: TextStyle(color: Colors.white70, fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                        child: const Row(children: [Icon(Icons.star, color: Colors.white, size: 14), SizedBox(width: 4), Text('Lv.7', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [Text('성장 경험치', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text('650 / 1000 EXP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: const LinearProgressIndicator(value: 0.65, backgroundColor: Colors.white24, color: Colors.white, minHeight: 10),
                  ),
                  const SizedBox(height: 12),
                  const Text('다음 레벨까지 350 EXP 남음', style: TextStyle(color: Colors.white70, fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 2. 내 스펙 (인턴 0회 빨간색 포인트)
            _buildSectionCard(
              title: '내 스펙',
              action: _buildPillButton('수정', Icons.edit, primaryColor),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.6,
                children: [
                  _buildSpecItem('학점', '3.8/4.5', false),
                  _buildSpecItem('토익', '850', false),
                  _buildSpecItem('자격증', '2개', false),
                  _buildSpecItem('인턴', '0회', true), // Warning 상태
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. 목표 기업
            _buildSectionCard(
              title: '목표 기업',
              action: Container(width: 32, height: 32, decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle), child: const Icon(Icons.add, color: Colors.white, size: 20)),
              child: Column(
                children: [
                  _buildCompanyRow('네이버', 0.75, primaryColor),
                  _buildCompanyRow('카카오', 0.68, primaryColor),
                  _buildCompanyRow('토스', 0.82, primaryColor),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. 업적 및 뱃지 진입 배너
            InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AchievementScreen())),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: primaryColor.withOpacity(0.08), borderRadius: BorderRadius.circular(24), border: Border.all(color: primaryColor.withOpacity(0.2))),
                child: Row(
                  children: [
                    Container(width: 48, height: 48, decoration: const BoxDecoration(color: primaryColor, shape: BoxShape.circle), child: const Icon(Icons.emoji_events_outlined, color: Colors.white)),
                    const SizedBox(width: 16),
                    const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('업적 및 뱃지', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text('획득한 칭호와 뱃지를 확인하세요', style: TextStyle(color: Colors.black54, fontSize: 13))])),
                    const Icon(Icons.chevron_right, color: primaryColor),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required Widget action, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey[100]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), action]), const SizedBox(height: 20), child]),
    );
  }

  Widget _buildPillButton(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Row(children: [Icon(icon, size: 14, color: color), const SizedBox(width: 4), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13))]),
    );
  }

  Widget _buildSpecItem(String title, String value, bool isWarning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isWarning ? const Color(0xFFFFF5F5) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isWarning ? Colors.red[100]! : Colors.grey[100]!)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.black54, fontSize: 12)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isWarning ? Colors.red : Colors.black87))]),
    );
  }

  Widget _buildCompanyRow(String name, double rate, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(children: [SizedBox(width: 60, child: Text(name, style: const TextStyle(fontWeight: FontWeight.bold))), Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: rate, backgroundColor: Colors.grey[100], color: color, minHeight: 8))), const SizedBox(width: 12), Text('${(rate * 100).toInt()}%', style: TextStyle(color: color, fontWeight: FontWeight.bold))]),
    );
  }
}