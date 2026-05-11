import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ground.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  // 내부 UI 상태 관리
  bool _isRoadmapExpanded = false;
  int _plantedTrees = 0; // 심어진 나무 개수 (테스트용)

  // 퀘스트 완료 시 호출되는 함수
  void _completeQuest() {
    setState(() {
      _plantedTrees++;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('퀘스트 완료! 성장 필드에 나무가 심어졌어요 🌲')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    
    // 💡 백엔드 커리어 성장도 데이터 구독
    final careerGrowthAsync = ref.watch(careerGrowthProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ==========================================
              // 1. 내 성장 필드 (5x5 격자 시스템 적용)
              // ==========================================
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
                child: careerGrowthAsync.when(
                  loading: () => const SizedBox(
                    height: 300, 
                    child: Center(child: CircularProgressIndicator())
                  ),
                  error: (error, stack) => SizedBox(
                    height: 300,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('데이터를 불러오지 못했어요.', style: TextStyle(color: Colors.red)),
                          TextButton(
                            onPressed: () => ref.refresh(careerGrowthProvider),
                            child: const Text('다시 시도'),
                          )
                        ],
                      ),
                    ),
                  ),
                  data: (data) => Column(
                    children: [
                      // 카드 상단: 타이틀 및 레벨 뱃지
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
                                Text('Lv.${data.level}', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 카드 중단: 땅바닥 (5x5 격자 배치)
                      Container(
                        width: double.infinity,
                        height: 220,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B2B22),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final containerCenter = constraints.maxWidth / 2;

                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                const GroundPlot(
                                  width: 260, 
                                  height: 130,
                                  elevation: 25,
                                ),
                                // 💡 5x5 격자 나무 렌더링
                                ..._build5x5GridTrees(containerCenter),
                              ],
                            );
                          }
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 카드 하단: 경험치 바 및 텍스트 정보
                      LinearProgressIndicator(
                        value: data.growthRate / 100,
                        backgroundColor: Colors.grey[200],
                        color: primaryColor,
                        minHeight: 12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.emoji_events_outlined, size: 18, color: Colors.black54),
                              const SizedBox(width: 4),
                              Text('현재 경험치 ${data.totalExp}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                            ],
                          ),
                          // 💡 널 체크 오류 해결: data.nextLevelExp 사용
                          Text('다음 레벨까지 ${data.nextLevelExp}', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ==========================================
              // 2. 로드맵 영역 (상태 연동)
              // ==========================================
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isRoadmapExpanded = !_isRoadmapExpanded;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('로드맵 펼치기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Icon(_isRoadmapExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down),
                    ],
                  ),
                ),
              ),
              
              if (_isRoadmapExpanded) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    children: [
                      _buildRoadmapStep(step: 1, title: '기초 학점 및 전공 다지기', isCompleted: true, primaryColor: primaryColor),
                      _buildRoadmapStep(step: 2, title: '필수 어학 점수 취득', isCompleted: true, primaryColor: primaryColor),
                      _buildRoadmapStep(step: 3, title: '직무 관련 자격증 준비', isCompleted: false, primaryColor: primaryColor, isActive: true),
                      _buildRoadmapStep(step: 4, title: '인턴십 및 실무 경험', isCompleted: false, primaryColor: primaryColor),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // ==========================================
              // 3. 퀘스트 탭 및 리스트
              // ==========================================
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

              _buildQuestCard('프로젝트 진행하기', '더 프로젝트를 진행하고 GitHub에 업로드하세요', '개발', context, onComplete: _completeQuest),
              const SizedBox(height: 12),
              _buildQuestCard('정보처리기사 취득하기', '정보처리기사 자격증을 취득하세요', '자격증', context, onComplete: _completeQuest),
            ],
          ),
        ),
      ),
    );
  }

  // 정밀 조정된 5x5 아이소메트릭 격자 시스템
  List<Widget> _build5x5GridTrees(double centerLine) {
    int treeCount = _plantedTrees > 25 ? 25 : _plantedTrees;
    List<Widget> trees = [];

    // 땅 크기(260x130) 내부 표면에 맞춘 간격 튜닝
    const double tileHalfWidth = 22.0;  
    const double tileHalfHeight = 11.0; 
    const double iconSize = 38.0;       
    const double gridTopY = 115.0; // 💡 나무가 땅 표면에 오도록 높이 조정

    for (int i = 0; i < treeCount; i++) {
      int row = i ~/ 5;
      int col = i % 5;

      double horizOffset = (col - row) * tileHalfWidth;
      double bottomPos = gridTopY - ((row + col) * tileHalfHeight);

      trees.add(
        Positioned(
          bottom: bottomPos,
          left: centerLine + horizOffset - (iconSize / 2),
          child: Icon(
            Icons.park, 
            color: Colors.lightGreenAccent,
            size: iconSize, 
          ),
        ),
      );
    }
    // 뒤에 있는 나무가 먼저 계산되므로 그대로 반환 (Z-Index 순서 유지)
    return trees; 
  }

  Widget _buildQuestCard(String title, String subtitle, String tag, BuildContext context, {required VoidCallback onComplete}) {
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
                    
                    InkWell(
                      onTap: onComplete,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: const Text('완료하기', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
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

  Widget _buildRoadmapStep({required int step, required String title, required bool isCompleted, required Color primaryColor, bool isActive = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: isCompleted ? primaryColor : (isActive ? primaryColor.withOpacity(0.2) : Colors.grey[200]),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isCompleted 
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : Text('$step', style: TextStyle(color: isActive ? primaryColor : Colors.grey, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title, 
              style: TextStyle(
                fontSize: 16, 
                color: isCompleted ? Colors.grey : Colors.black87,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}