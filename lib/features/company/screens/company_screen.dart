import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/company_provider.dart';
import 'company_detail_screen.dart';

class CompanyScreen extends ConsumerWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final primaryColor = Theme.of(context).primaryColor;
    final companiesAsync = ref.watch(recommendedCompaniesProvider);
    final selectedFilter = ref.watch(companyFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        title: const Text('기업 추천', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black87), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // 필터 탭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [null, '대기업', '중견', '스타트업'].map((type) {
                  final isSelected = selectedFilter == type;
                  final label = type ?? '전체';
                  return GestureDetector(
                    onTap: () => ref.read(companyFilterProvider.notifier).set(type),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: isSelected ? primaryColor : Colors.grey[300]!),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 기업 목록
          Expanded(
            child: companiesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Center(child: Text('기업 목록을 불러오지 못했어요')),
              data: (data) {
                final companies = data['companies'] as List? ?? [];
                final total = data['total'] ?? 0;

                if (companies.isEmpty) {
                  return const Center(child: Text('추천 기업이 없어요'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: companies.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '총 $total개 기업이 추천됐어요',
                          style: const TextStyle(color: Colors.black54, fontSize: 13),
                        ),
                      );
                    }
                    final company = companies[index - 1];
                    return _buildCompanyCard(context, company, primaryColor);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(BuildContext context, Map<String, dynamic> company, Color primaryColor) {
    final matchRate = company['match_rate'] ?? 0;
    final reasons = company['recommendation_reasons'] as List? ?? [];
    final isScrapped = company['is_scrapped'] ?? false;

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompanyDetailScreen(
            companyId: company['company_id'],
            companyName: company['company_name'] ?? '',
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[200]!),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 기업 아이콘
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      (company['company_name'] ?? '?').substring(0, 1),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company['company_name'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        '${company['company_type'] ?? ''} · ${company['industry'] ?? ''}',
                        style: const TextStyle(color: Colors.black54, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // 매칭률
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$matchRate%',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 추천 이유
            if (reasons.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: reasons.map((reason) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(reason.toString(), style: const TextStyle(fontSize: 12, color: Colors.black54)),
                  );
                }).toList(),
              ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                    const SizedBox(width: 4),
                    Text(
                      company['hiring_season'] ?? '-',
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  '상세보기 >',
                  style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}