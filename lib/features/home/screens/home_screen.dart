import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spec_check/features/home/models/career_growth_model.dart';
import '../widgets/ground.dart';
import '../providers/home_provider.dart';
import 'roadmap_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const List<Offset> _allSlots = [
    Offset(130.0, 9.0),
    Offset(151.0, 17.0),
    Offset(109.0, 17.0),
    Offset(172.0, 25.0),
    Offset(130.0, 25.0),
    Offset(88.0, 25.0),
    Offset(193.0, 33.0),
    Offset(151.0, 33.0),
    Offset(109.0, 33.0),
    Offset(67.0, 33.0),
    Offset(214.0, 41.0),
    Offset(172.0, 41.0),
    Offset(130.0, 41.0),
    Offset(88.0, 41.0),
    Offset(46.0, 41.0),
    Offset(235.0, 49.0),
    Offset(193.0, 49.0),
    Offset(151.0, 49.0),
    Offset(109.0, 49.0),
    Offset(67.0, 49.0),
    Offset(25.0, 49.0),
    Offset(214.0, 57.0),
    Offset(172.0, 57.0),
    Offset(130.0, 57.0),
    Offset(88.0, 57.0),
    Offset(46.0, 57.0),
    Offset(235.0, 65.0),
    Offset(193.0, 65.0),
    Offset(151.0, 65.0),
    Offset(109.0, 65.0),
    Offset(67.0, 65.0),
    Offset(25.0, 65.0),
    Offset(214.0, 73.0),
    Offset(172.0, 73.0),
    Offset(130.0, 73.0),
    Offset(88.0, 73.0),
    Offset(46.0, 73.0),
    Offset(193.0, 81.0),
    Offset(151.0, 81.0),
    Offset(109.0, 81.0),
    Offset(67.0, 81.0),
    Offset(172.0, 89.0),
    Offset(130.0, 89.0),
    Offset(88.0, 89.0),
    Offset(151.0, 97.0),
    Offset(109.0, 97.0),
    Offset(130.0, 105.0),
    Offset(151.0, 113.0),
    Offset(109.0, 113.0),
    Offset(130.0, 121.0),
  ];

  List<Widget> _buildTrees(int plantedTreeCount, int maxTreeCount) {
    final treeImages = ['tree1.png', 'tree2.png', 'tree3.png', 'tree4.png'];
    final count = plantedTreeCount
        .clamp(0, maxTreeCount)
        .clamp(0, _allSlots.length);

    return List.generate(count, (i) {
      return Positioned(
        left: _allSlots[i].dx - 16,
        top: _allSlots[i].dy - 16,
        child: Image.asset(
          'assets/images/${treeImages[i % treeImages.length]}',
          width: 32,
          height: 32,
        ),
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
    final isExpanded = ref.watch(roadmapExpandedProvider);
    final roadmapAsync = ref.watch(roadmapProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              growthAsync.when(
                loading: () => const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Center(
                    child: Text(
                      '성장 필드를 불러오지 못했어요 😢',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                data: (growthJson) {
                  final growthData = CareerGrowthModel.fromJson(growthJson);

                  return Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              '내 성장 필드',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.eco,
                                    size: 16,
                                    color: primaryColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${growthData.completedQuests}/${growthData.totalQuests}',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

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
                                      ..._buildTrees(
                                        growthData.plantedTreeCount,
                                        growthData.maxTreeCount,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        LinearProgressIndicator(
                          value: growthData.fieldProgressValue,
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
                                const Icon(
                                  Icons.emoji_events_outlined,
                                  size: 18,
                                  color: Colors.black54,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '완료한 퀘스트 ${growthData.completedQuests}개',
                                  style: const TextStyle(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '목표까지 ${growthData.remainingQuests}개',
                              style: const TextStyle(
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () =>
                      ref.read(roadmapExpandedProvider.notifier).toggle(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isExpanded ? '로드맵 접기' : '로드맵 펼치기',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ],
                  ),
                ),
              ),

              if (isExpanded) ...[
                const SizedBox(height: 16),
                roadmapAsync.when(
                  loading: () => const Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, _) => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: const Center(
                      child: Text(
                        '로드맵을 불러오지 못했어요 😢',
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),
                  data: (roadmap) {
                    final stages = roadmap['stages'] as List? ?? [];
                    final title = roadmap['title'] ?? '아직 로드맵이 없어요';
                    final progressRate =
                        roadmap['progressRate'] ??
                        roadmap['progress_rate'] ??
                        0;

                    return Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                '$progressRate%',
                                style: TextStyle(
                                  color: primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: (progressRate as num) / 100,
                            backgroundColor: Colors.grey[200],
                            color: primaryColor,
                            minHeight: 8,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          const SizedBox(height: 20),

                          if (stages.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Text(
                                  '진행 중인 로드맵 단계가 없습니다.',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ),
                            ),

                          ...stages.asMap().entries.map((entry) {
                            final index = entry.key;
                            final stage = entry.value;
                            final isCompleted =
                                stage['completed'] ??
                                stage['isCompleted'] ??
                                stage['is_completed'] ??
                                false;
                            final isLast = index == stages.length - 1;

                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RoadmapDetailScreen(stage: stage),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Column(
                                    children: [
                                      Container(
                                        width: 32,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? primaryColor
                                              : Colors.grey[200],
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isCompleted
                                              ? Icons.check
                                              : Icons.radio_button_unchecked,
                                          size: 16,
                                          color: isCompleted
                                              ? Colors.white
                                              : Colors.grey,
                                        ),
                                      ),
                                      if (!isLast)
                                        Container(
                                          width: 2,
                                          height: 48,
                                          color: isCompleted
                                              ? primaryColor.withOpacity(0.3)
                                              : Colors.grey[200],
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 16,
                                      ),
                                      child: Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: isCompleted
                                              ? primaryColor.withOpacity(0.05)
                                              : Colors.grey[50],
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          border: Border.all(
                                            color: isCompleted
                                                ? primaryColor.withOpacity(0.2)
                                                : Colors.grey[200]!,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    stage['stageName'] ??
                                                        stage['stage_name'] ??
                                                        '',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isCompleted
                                                          ? primaryColor
                                                          : Colors.black87,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    stage['description'] ?? '',
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey[400],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    );
                  },
                ),
              ],
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => ref.read(questTabProvider.notifier).set(0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: questTab == 0 ? primaryColor : Colors.white,
                          border: Border.all(
                            color: questTab == 0
                                ? primaryColor
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            '메인 퀘스트',
                            style: TextStyle(
                              color: questTab == 0
                                  ? Colors.white
                                  : Colors.black54,
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
                          border: Border.all(
                            color: questTab == 1
                                ? primaryColor
                                : Colors.grey[300]!,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Center(
                          child: Text(
                            '서브 퀘스트',
                            style: TextStyle(
                              color: questTab == 1
                                  ? Colors.white
                                  : Colors.black54,
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

              questAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      '퀘스트를 불러오지 못했어요 😢',
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
                data: (quests) {
                  if (quests.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          '아직 부여된 퀘스트가 없어요 🌱',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  }
                  return Column(
                    children: quests.map((quest) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildQuestCard(
                          questId: quest['questId'] ?? quest['quest_id'] ?? 0,
                          title:
                              quest['questName'] ??
                              quest['quest_name'] ??
                              quest['title'] ??
                              '',
                          subtitle: quest['description'] ?? '',
                          tag: quest['category'] ?? '',
                          status: quest['status'] ?? 'not_started',
                          expReward:
                              quest['expReward'] ?? quest['exp_reward'] ?? 0,
                          context: context,
                          ref: ref,
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
    required int questId,
    required String title,
    required String subtitle,
    required String tag,
    required String status,
    required int expReward,
    required BuildContext context,
    required WidgetRef ref,
  }) {
    final primaryColor = Theme.of(context).primaryColor;

    String statusText;
    Color statusColor;
    switch (status) {
      case 'completed':
      case 'COMPLETED':
        statusText = '완료';
        statusColor = Colors.green;
        break;
      case 'in_progress':
      case 'IN_PROGRESS':
        statusText = '진행중';
        statusColor = primaryColor;
        break;
      default:
        statusText = '시작 전';
        statusColor = Colors.grey;
    }

    // 이미 완료된 상태라면 완료 버튼 비활성화 시각화
    final bool canComplete =
        (status == 'in_progress' || status == 'IN_PROGRESS');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tag.isNotEmpty ? tag : '기본',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: [
                        Icon(Icons.eco, size: 14, color: primaryColor),
                        const SizedBox(width: 2),
                        Text(
                          '성장 +$expReward',
                          style: TextStyle(
                            fontSize: 12,
                            color: primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),

                    InkWell(
                      onTap: canComplete
                          ? () async {
                              try {
                                await ref
                                    .read(questActionProvider)
                                    .completeQuest(questId);
                                if (context.mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '퀘스트 완료! +$expReward XP 🌲',
                                      ),
                                    ),
                                  );
                              } catch (e) {
                                if (context.mounted)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('완료 처리에 실패했어요.'),
                                    ),
                                  );
                              }
                            }
                          : null,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: canComplete
                              ? primaryColor
                              : statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          canComplete ? '완료하기' : statusText,
                          style: TextStyle(
                            fontSize: 12,
                            color: canComplete ? Colors.white : statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
