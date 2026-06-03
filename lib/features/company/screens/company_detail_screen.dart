import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/company_provider.dart';
import '../repositories/company_repository.dart';
import '../utils/company_logo.dart';

class CompanyDetailScreen extends ConsumerWidget {
  final int companyId;
  final String companyName;
  final String? careerUrl;

  const CompanyDetailScreen({
    super.key,
    required this.companyId,
    required this.companyName,
    this.careerUrl,
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
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          companyName,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_border, color: Colors.black),
            onPressed: () async {
              try {
                final repository = ref.read(companyRepositoryProvider);
                // 실제 스크랩 API 연동
                await repository.scrapCompany(companyId);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('기업을 성공적으로 스크랩했습니다!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('스크랩 처리에 실패했어요.')),
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
            detailAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('기업 정보를 불러오지 못했어요 😢'),
                ),
              ),
              data: (detail) => _buildDetailCard(context, detail, primaryColor),
            ),
            const SizedBox(height: 20),
            matchAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('매칭 분석을 불러오지 못했어요 😢'),
                ),
              ),
              data: (match) => _buildMatchCard(context, match, primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    Map<String, dynamic> detail,
    Color primaryColor,
  ) {
    final cultureTags =
        detail['cultureTags'] ?? detail['culture_tags'] as List? ?? [];
    final hiringSchedule =
        detail['hiringSchedule'] ?? detail['hiring_schedule'] as List? ?? [];
    final cName =
        detail['companyName'] ?? detail['company_name'] ?? companyName;
    final cType = detail['companyType'] ?? detail['company_type'] ?? '';
    final effectiveCareerUrl =
        _asNullableString(detail['careerUrl'] ?? detail['career_url']) ??
        careerUrl;
    final logoAsset = companyLogoAsset(cName);

    return Column(
      children: [
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
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: logoAsset != null
                          ? Image.asset(
                              logoAsset,
                              fit: BoxFit.cover, 
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildLogoFallback(cName, primaryColor),
                            )
                          : _buildLogoFallback(cName, primaryColor),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$cType · ${detail['industry'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                detail['description'] ?? '',
                style: const TextStyle(color: Colors.black54, height: 1.6),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: Colors.black54,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    detail['region'] ?? '-',
                    style: const TextStyle(color: Colors.black54),
                  ),
                ],
              ),
              if (effectiveCareerUrl != null) ...[
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _openCareerUrl(context, effectiveCareerUrl),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('채용 페이지 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              if (cultureTags.isNotEmpty) ...[
                const Text(
                  '기업 문화',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: cultureTags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        tag.toString(),
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
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
                const Text(
                  '채용 일정',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ...hiringSchedule.map((schedule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            schedule['stage'] ?? '',
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          schedule['period'] ?? '',
                          style: const TextStyle(color: Colors.black54),
                        ),
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

  Widget _buildMatchCard(
    BuildContext context,
    Map<String, dynamic> match,
    Color primaryColor,
  ) {
    final matchRate = match['matchRate'] ?? match['match_rate'] ?? 0;
    final gapAnalysis =
        match['gapAnalysis'] ?? match['gap_analysis'] as Map? ?? {};
    final priorityActions =
        match['priorityActions'] ?? match['priority_actions'] as List? ?? [];

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '매칭 분석',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                child: Text(
                  '$matchRate%',
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '스펙 분석',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
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
              case 'GOOD':
                statusColor = Colors.green;
                statusIcon = Icons.arrow_upward;
                break;
              case 'lack':
              case 'LACK':
                statusColor = Colors.orange;
                statusIcon = Icons.arrow_downward;
                break;
              case 'critical':
              case 'CRITICAL':
                statusColor = Colors.red;
                statusIcon = Icons.warning_outlined;
                break;
              default:
                statusColor = Colors.grey;
                statusIcon = Icons.remove;
            }

            final label =
                {
                  'gpa': '학점',
                  'toeic': '토익',
                  'internship': '인턴',
                  'certificate': '자격증',
                  'project': '프로젝트',
                }[key] ??
                key;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: 60,
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          '나: $my',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '평균: $avg',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(statusIcon, size: 16, color: statusColor),
                ],
              ),
            );
          }).toList(),
          if (priorityActions.isNotEmpty) ...[
            const Divider(height: 32),
            const Text(
              '우선 개선 항목',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...priorityActions.map((action) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: primaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${action['rank']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        action['action'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text(
                      action['effect'] ?? '',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildLogoFallback(String companyName, Color primaryColor) {
    return Center(
      child: Text(
        companyName.isNotEmpty ? companyName.substring(0, 1) : '?',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  String? _asNullableString(dynamic value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  Future<void> _openCareerUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    var didLaunch = false;

    if (uri != null) {
      try {
        didLaunch = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
        didLaunch = false;
      }
    }

    if (!didLaunch && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('채용 페이지를 열 수 없습니다.')));
    }
  }
}