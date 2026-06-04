import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/portfolio_provider.dart';
import 'portfolio_feedback_screen.dart';

class PortfolioScreen extends ConsumerWidget {
  const PortfolioScreen({super.key});

  static const _primaryColor = Color(0xFF61B099);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        titleSpacing: 20,
        centerTitle: false,
        title: const Text('포트폴리오', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
        actions: [
          // 전체 AI 분석 버튼
          portfolioAsync.maybeWhen(
            data: (list) => list.isNotEmpty
                ? TextButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PortfolioFeedbackScreen(isOverall: true)),
                    ),
                    icon: const Icon(Icons.auto_awesome, color: _primaryColor, size: 18),
                    label: const Text('종합분석', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.bold)),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: portfolioAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('불러오지 못했어요 😢', style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 12),
              TextButton(onPressed: () => ref.invalidate(portfolioProvider), child: const Text('다시 시도')),
            ],
          ),
        ),
        data: (portfolios) => _buildBody(context, ref, portfolios),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPortfolioForm(context, ref),
        backgroundColor: _primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, List<Map<String, dynamic>> portfolios) {
    if (portfolios.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.work_outline, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('아직 포트폴리오가 없어요', style: TextStyle(fontSize: 16, color: Colors.black54)),
            const SizedBox(height: 8),
            const Text('프로젝트를 등록하고 AI 피드백을 받아보세요', style: TextStyle(fontSize: 13, color: Colors.black38)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
      itemCount: portfolios.length,
      itemBuilder: (context, index) => _buildPortfolioCard(context, ref, portfolios[index]),
    );
  }

  Widget _buildPortfolioCard(BuildContext context, WidgetRef ref, Map<String, dynamic> item) {
    final typeLabel = _projectTypeLabel(item['projectType']);
    final typeColor = _projectTypeColor(item['projectType']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 16, 0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: typeColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(typeLabel, style: TextStyle(color: typeColor, fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const Spacer(),
                // 수정/삭제 메뉴
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: Colors.black38),
                  onSelected: (value) {
                    if (value == 'edit') _showPortfolioForm(context, ref, existing: item);
                    if (value == 'delete') _confirmDelete(context, ref, item['id']);
                  },
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'edit', child: Text('수정')),
                    const PopupMenuItem(value: 'delete', child: Text('삭제', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
          ),

          // 프로젝트명
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
            child: Text(item['title'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          ),

          // 기간
          if (item['startDate'] != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 0),
              child: Text(
                '${item['startDate']} ~ ${item['endDate'] ?? '진행중'}',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
            ),

          // 설명
          if (item['description'] != null && (item['description'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Text(
                item['description'],
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: Colors.grey[600], height: 1.5),
              ),
            ),

          // 기술 스택 칩
          if (item['techStack'] != null && (item['techStack'] as String).isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (item['techStack'] as String)
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .map((tech) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(tech, style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                        ))
                    .toList(),
              ),
            ),

          // AI 피드백 버튼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PortfolioFeedbackScreen(
                      portfolioId: item['id'],
                      portfolioTitle: item['title'],
                    ),
                  ),
                ),
                icon: const Icon(Icons.auto_awesome, size: 16, color: _primaryColor),
                label: const Text('AI 피드백 받기', style: TextStyle(color: _primaryColor, fontWeight: FontWeight.w600)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _primaryColor),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 포트폴리오 등록/수정 바텀시트
  void _showPortfolioForm(BuildContext context, WidgetRef ref, {Map<String, dynamic>? existing}) {
    final titleCtrl = TextEditingController(text: existing?['title'] ?? '');
    final descCtrl = TextEditingController(text: existing?['description'] ?? '');
    final techCtrl = TextEditingController(text: existing?['techStack'] ?? '');
    final githubCtrl = TextEditingController(text: existing?['githubUrl'] ?? '');
    final startCtrl = TextEditingController(text: existing?['startDate'] ?? '');
    final endCtrl = TextEditingController(text: existing?['endDate'] ?? '');
    String selectedType = existing?['projectType'] ?? 'PERSONAL';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 24, right: 24, top: 32,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  existing == null ? '포트폴리오 등록' : '포트폴리오 수정',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // 프로젝트 유형 선택
                const Text('프로젝트 유형', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black54)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _typeChip('PERSONAL', '개인', selectedType, (v) => setState(() => selectedType = v)),
                    _typeChip('TEAM', '팀', selectedType, (v) => setState(() => selectedType = v)),
                    _typeChip('INTERNSHIP', '인턴십', selectedType, (v) => setState(() => selectedType = v)),
                    _typeChip('OPEN_SOURCE', '오픈소스', selectedType, (v) => setState(() => selectedType = v)),
                  ],
                ),
                const SizedBox(height: 16),

                _field('프로젝트명 *', titleCtrl),
                _field('설명 (담당 역할, 성과 등)', descCtrl, maxLines: 3),
                _field('기술스택 (쉼표로 구분, 예: Java, Spring)', techCtrl),
                _field('GitHub URL', githubCtrl),
                Row(
                  children: [
                    Expanded(child: _field('시작 (예: 2024-03)', startCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _field('종료 (없으면 빈칸)', endCtrl)),
                  ],
                ),

                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    onPressed: () async {
                      if (titleCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('프로젝트명을 입력해주세요')));
                        return;
                      }
                      try {
                        final body = {
                          'title': titleCtrl.text.trim(),
                          'description': descCtrl.text.trim(),
                          'techStack': techCtrl.text.trim(),
                          'githubUrl': githubCtrl.text.trim(),
                          'startDate': startCtrl.text.trim(),
                          'endDate': endCtrl.text.trim().isEmpty ? null : endCtrl.text.trim(),
                          'projectType': selectedType,
                        };
                        if (existing == null) {
                          await ref.read(portfolioProvider.notifier).create(body);
                        } else {
                          await ref.read(portfolioProvider.notifier).updatePortfolio(existing['id'], body);
                        }
                        if (ctx.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(existing == null ? '포트폴리오가 등록되었습니다 🎉' : '수정되었습니다!')),
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('저장에 실패했어요.')));
                      }
                    },
                    child: Text(
                      existing == null ? '등록하기' : '수정 완료',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('삭제하시겠어요?'),
        content: const Text('삭제된 포트폴리오는 복구할 수 없습니다.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(portfolioProvider.notifier).delete(id);
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: ctrl,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _typeChip(String value, String label, String selected, void Function(String) onTap) {
    final isSelected = value == selected;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black54, fontWeight: FontWeight.w600, fontSize: 13)),
      ),
    );
  }

  String _projectTypeLabel(String? type) {
    return switch (type) {
      'PERSONAL' => '개인 프로젝트',
      'TEAM' => '팀 프로젝트',
      'INTERNSHIP' => '인턴십',
      'OPEN_SOURCE' => '오픈소스',
      _ => '프로젝트',
    };
  }

  Color _projectTypeColor(String? type) {
    return switch (type) {
      'PERSONAL' => const Color(0xFF61B099),
      'TEAM' => const Color(0xFF5B8DEF),
      'INTERNSHIP' => const Color(0xFFFF9F43),
      'OPEN_SOURCE' => const Color(0xFF9B59B6),
      _ => Colors.grey,
    };
  }
}
