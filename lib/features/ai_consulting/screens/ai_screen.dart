import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';

class AiScreen extends StatelessWidget {
  const AiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('2학년 · 개발 · 민준', style: TextStyle(color: Colors.black54, fontSize: 14)),
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

                  // 스펙 그리드
                  Row(
                    children: [
                      Expanded(child: _buildSpecItem('🎓', '학점', '3.8/4.5', false)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSpecItem('🌐', '어학 성적', 'TOEIC 820', false)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(child: _buildSpecItem('📜', '자격증', '정보처리기사', false)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildSpecItem('💼', '인턴십', '경험 없음', true)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 챗봇 진입 버튼(현재는 버튼만 구현된 상태)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AiChatScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(elevation: 0),
                child: const Text('AI와 스펙 진단하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 스펙 아이템을 그리는 위젯
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