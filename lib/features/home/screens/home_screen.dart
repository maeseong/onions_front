import 'package:flutter/material.dart';
import '../widgets/ground.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int treeCount = 25;

  // ground.dart 기준으로 수학적으로 정확히 계산된 5x5 = 25칸 중심 좌표
  // width=260, height=130 아이소메트릭 격자
  static const List<Offset> _allSlots = [
    Offset(130.0, 13.0),   // 1
    Offset(156.0, 26.0),   // 2
    Offset(104.0, 26.0),   // 3
    Offset(182.0, 39.0),   // 4
    Offset(130.0, 39.0),   // 5
    Offset(78.0,  39.0),   // 6
    Offset(208.0, 52.0),   // 7
    Offset(156.0, 52.0),   // 8
    Offset(104.0, 52.0),   // 9
    Offset(52.0,  52.0),   // 10
    Offset(234.0, 65.0),   // 11
    Offset(182.0, 65.0),   // 12
    Offset(130.0, 65.0),   // 13
    Offset(78.0,  65.0),   // 14
    Offset(26.0,  65.0),   // 15
    Offset(208.0, 78.0),   // 16
    Offset(156.0, 78.0),   // 17
    Offset(104.0, 78.0),   // 18
    Offset(52.0,  78.0),   // 19
    Offset(182.0, 91.0),   // 20
    Offset(130.0, 91.0),   // 21
    Offset(78.0,  91.0),   // 22
    Offset(156.0, 104.0),  // 23
    Offset(104.0, 104.0),  // 24
    Offset(130.0, 117.0),  // 25
  ];

  List<Widget> _buildTrees(int count) {
    return List.generate(count.clamp(0, _allSlots.length), (i) {
      return Positioned(
        left: _allSlots[i].dx - 16,
        top:  _allSlots[i].dy - 24,
        child: const Text('🌳', style: TextStyle(fontSize: 32)),
      );
    });
  }

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

                    // 카드 중단: 땅바닥 + 나무
                    SizedBox(
                      width: double.infinity,
                      height: 220,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          color: const Color(0xFF1B2B22),
                          child: Center(
                            child: SizedBox(
                              width: 260,
                              height: 200,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  const GroundPlot(
                                    width: 260,
                                    height: 130,
                                    elevation: 25,
                                  ),
                                  ..._buildTrees(treeCount),
                                ],
                              ),
                            ),
                          ),
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
              _buildQuestCard('프로젝트 진행하기', '프로젝트를 진행하고 GitHub에 업로드하세요', '개발', context),
              const SizedBox(height: 12),
              _buildQuestCard('정보처리기사 취득하기', '정보처리기사 자격증을 취득하세요', '자격증', context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestCard(String title, String subtitle, String tag, BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

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
                        Icon(Icons.eco, size: 14, color: primaryColor),
                        const SizedBox(width: 2),
                        Text('성장 +1', style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.teal[50], borderRadius: BorderRadius.circular(12)),
                      child: Text('진행중', style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold)),
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