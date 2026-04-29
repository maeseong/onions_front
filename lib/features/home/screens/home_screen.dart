import 'package:flutter/material.dart';
import '../widgets/ground.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // 내 성장 필드
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ]
                ),
                child: Column(
                  children: [
                    // 카드 상단: 타이틀 및 뱃지
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '내 성장 필드',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.eco, size: 16, color: primaryColor),
                              const SizedBox(width: 4),
                              Text('8/20', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 카드 중단: 땅바닥
                    Container(
                      width: double.infinity,
                      height: 220,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2B22),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: GroundPlot(
                          width: 260, 
                          height: 130,
                          elevation: 25,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 카드 하단: 경험치 바
                    LinearProgressIndicator(
                      value: 8 / 20,
                      backgroundColor: Colors.grey[200],
                      color: primaryColor,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.emoji_events_outlined, size: 18, color: Colors.black54),
                            SizedBox(width: 4),
                            Text('완료한 퀘스트 3개', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                          ],
                        ),
                        Text('목표까지 12개', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 로드맵 펼치기
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('로드맵 펼치기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Icon(Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 퀘스트 탭
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(child: Text('메인 퀘스트', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Center(child: Text('서브 퀘스트', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 퀘스트 카드 리스트
              _buildQuestCard('프로젝트 진행하기', '더 프로젝트를 진행하고 GitHub에 업로드하세요', '개발', context),
              const SizedBox(height: 12),
              _buildQuestCard('정보처리기사 취득하기', '정보처리기사 자격증을 취득하세요', '자격증', context),
            ],
          ),
        ),
      ),
    );
  }

  // 퀘스트 카드를 그리는 내부 위젯 함수
  Widget _buildQuestCard(String title, String subtitle, String tag, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2)),
        ]
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.laptop_mac, color: Colors.black54),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                      child: Text(tag, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(Icons.eco, size: 14, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 2),
                        Text('성장 +1', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(12)),
                      child: Text('진행중', style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}