import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/ground.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Offset> _allSlots = [
    Offset(130.0, 13.0),
    Offset(156.0, 26.0),
    Offset(104.0, 26.0),
    Offset(182.0, 39.0),
    Offset(130.0, 39.0),
    Offset(78.0,  39.0),
    Offset(208.0, 52.0),
    Offset(156.0, 52.0),
    Offset(104.0, 52.0),
    Offset(52.0,  52.0),
    Offset(234.0, 65.0),
    Offset(182.0, 65.0),
    Offset(130.0, 65.0),
    Offset(78.0,  65.0),
    Offset(26.0,  65.0),
    Offset(208.0, 78.0),
    Offset(156.0, 78.0),
    Offset(104.0, 78.0),
    Offset(52.0,  78.0),
    Offset(182.0, 91.0),
    Offset(130.0, 91.0),
    Offset(78.0,  91.0),
    Offset(156.0, 104.0),
    Offset(104.0, 104.0),
    Offset(130.0, 117.0),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final growthAsync = ref.watch(growthProvider);
    final questTab = ref.watch(questTabProvider);
    final questAsync = questTab == 0
        ? ref.watch(mainQuestProvider)
        : ref.watch(subQuestProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // 내 성장 필드
              growthAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(child: Text('성장도를 불러오지 못했어요')),
                data: (growth) {
                  final completedQuests = growth['completed_quests'] ?? 0;
                  final totalQuests = growth['total_quests'] ?? 20;
                  final totalExp = growth['total_exp'] ?? 0;
                  final nextLevelExp = growth['next_level_exp'] ?? 1000;

                  return Container(
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
                                  Text('$completedQuests/$totalQuests', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
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
                                      ..._buildTrees(completedQuests),
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
                          value: nextLevelExp > 0 ? totalExp / nextLevelExp : 0,
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
                                Text('완료한 퀘스트 ${completedQuests}개', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Text('목표까지 ${totalQuests - completedQuests}개', style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ],
                    ),
                  );
                },
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
                    child: GestureDetector(
                      onTap: () => ref.read(questTabProvider.notifier).set(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: questTab == 0 ? primaryColor : Colors.white,
                          border: Border.all(color: questTab == 0 ? primaryColor : Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            '메인 퀘스트',
                            style: TextStyle(
                              color: questTab == 0 ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref.read(questTabProvider.notifier).set(1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: questTab == 1 ? primaryColor : Colors.white,
                          border: Border.all(color: questTab == 1 ? primaryColor : Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            '서브 퀘스트',
                            style: TextStyle(
                              color: questTab == 1 ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 퀘스트 카드 리스트
              questAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const Center(child: Text('퀘스트를 불러오지 못했어요')),
                data: (quests) {
                  if (quests.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text('퀘스트가 없어요', style: TextStyle(color: Colors.black54)),
                      ),
                    );
                  }
                  return Column(
                    children: quests.map((quest) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildQuestCard(
                          title: quest['quest_name'] ?? '',
                          subtitle: quest['description'] ?? '',
                          tag: quest['category'] ?? '',
                          status: quest['status'] ?? 'not_started',
                          expReward: quest['exp_reward'] ?? 0,
                          context: context,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestCard({
    required String title,
    required String subtitle,
    required String tag,
    required String status,
    required int expReward,
    required BuildContext context,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    String statusText;
    Color statusColor;
    switch (status) {
      case 'completed':
        statusText = '완료';
        statusColor = Colors.green;
        break;
      case 'in_progress':
        statusText = '진행중';
        statusColor = primaryColor;
        break;
      default:
        statusText = '시작 전';
        statusColor = Colors.grey;
    }

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
                        Text('성장 +$expReward', style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(statusText, style: TextStyle(fontSize: 12, color: statusColor, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}