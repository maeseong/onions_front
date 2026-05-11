import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/company_provider.dart';
import '../repositories/company_repository.dart';

class CompanyDetailScreen extends ConsumerWidget {
  final int companyId;
  final String companyName;

  const CompanyDetailScreen({
    super.key,
    required this.companyId,
    required this.companyName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final detailAsync = ref.watch(companyDetailProvider(companyId));
    final matchAsync = ref.watch(matchAnalysisProvider(companyId));

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(companyName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          // 스크랩 버튼
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () async {
              try {
                final repository = ref.read(companyRepositoryProvider);
                await repository.scrapCompany(companyId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('스크랩했어요!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('서버 연동 후 사용 가능해요!')),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 기업 상세 정보
            detailAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('기업 정보를 불러오지 못했어요')),
              data: (detail) => _buildDetailCard(context, detail, primaryColor),
            ),
            const SizedBox(height: 20),

            // 매칭 분석
            matchAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('매칭 분석을 불러오지 못했어요')),
              data: (match) => _buildMatchCard(context, match, primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(BuildContext context, Map<String, dynamic> detail, Color primaryColor) {
    final cultureTags = detail['culture_tags'] as List? ?? [];
    final hiringSchedule = detail['hiring_schedule'] as List? ?? [];

    return Column(
      children: [
        // 기업 기본 정보
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 기업명 + 타입
              Row(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        detail['company_name']?.substring(0, 1) ?? '?',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(detail['company_name'] ?? '', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        Text(
                          '${detail['company_type'] ?? ''} · ${detail['industry'] ?? ''}',
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 기업 설명
              Text(detail['description'] ?? '', style: const TextStyle(color: Colors.black54, height: 1.6)),
              const SizedBox(height: 20),

              // 위치
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                  const SizedBox(width: 4),
                  Text(detail['region'] ?? '-', style: const TextStyle(color: Colors.black54)),
                ],
              ),
              const SizedBox(height: 20),

              // 문화 태그
              if (cultureTags.isNotEmpty) ...[
                const Text('기업 문화', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cultureTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tag.toString(), style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),

        // 채용 일정
        if (hiringSchedule.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('채용 일정', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...hiringSchedule.map((schedule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            schedule['stage'] ?? '',
                            style: TextStyle(color: primaryColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(schedule['period'] ?? '', style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMatchCard(BuildContext context, Map<String, dynamic> match, Color primaryColor) {
    final matchRate = match['match_rate'] ?? 0;
    final gapAnalysis = match['gap_analysis'] as Map? ?? {};
    final priorityActions = match['priority_actions'] as List? ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 매칭률
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('매칭 분석', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('$matchRate%', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 갭 분석
          const Text('스펙 분석', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          ...gapAnalysis.entries.map((entry) {
            final key = entry.key;
            final value = entry.value as Map? ?? {};
            final status = value['status'] ?? 'same';
            final my = value['my'] ?? 0;
            final avg = value['avg'] ?? 0;

            Color statusColor;
            IconData statusIcon;
            switch (status) {
              case 'good':
                statusColor = Colors.green;
                statusIcon = Icons.arrow_upward;
                break;
              case 'lack':
                statusColor = Colors.orange;
                statusIcon = Icons.arrow_downward;
                break;
              case 'critical':
                statusColor = Colors.red;
                statusIcon = Icons.warning_outlined;
                break;
              default:
                statusColor = Colors.grey;
                statusIcon = Icons.remove;
            }

            final label = {
              'gpa': '학점',
              'toeic': '토익',
              'internship': '인턴',
              'certificate': '자격증',
              'project': '프로젝트',
            }[key] ?? key;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(width: 60, child: Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13))),
                  Expanded(
                    child: Row(
                      children: [
                        Text('나: $my', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(width: 8),
                        Text('평균: $avg', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(statusIcon, size: 16, color: statusColor),
                ],
              ),
            );
          }).toList(),

          // 우선 행동
          if (priorityActions.isNotEmpty) ...[
            const Divider(height: 32),
            const Text('우선 개선 항목', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ...priorityActions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          '${action['rank']}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(action['action'] ?? '', style: const TextStyle(fontWeight: FontWeight.w500))),
                    Text(action['effect'] ?? '', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }
}