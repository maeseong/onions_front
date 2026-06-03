import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/company_provider.dart';
import '../utils/company_logo.dart';
import 'ai_company_detail_screen.dart';
import 'company_detail_screen.dart';

class CompanyScreen extends ConsumerStatefulWidget {
  const CompanyScreen({super.key});

  @override
  ConsumerState<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends ConsumerState<CompanyScreen> {
  String _searchQuery = '';
  bool _showSearch = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final companiesAsync = ref.watch(recommendedCompaniesProvider);
    final selectedFilter = ref.watch(companyFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        surfaceTintColor: Colors.transparent, // 💡 스크롤 시 앱바 색상 변하는 현상 방지
        elevation: 0,
        titleSpacing: 20.0,
        centerTitle: false,
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: '기업명 검색',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  border: InputBorder.none,
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (v) => setState(() => _searchQuery = v),
              )
            : const Text(
                '기업 추천',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
        actions: [
          IconButton(
            icon: Icon(
              _showSearch ? Icons.close : Icons.search,
              color: Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _showSearch = !_showSearch;
                if (!_showSearch) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 필터 탭
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [null, '대기업', '중견', '스타트업'].asMap().entries.map((
                entry,
              ) {
                final index = entry.key;
                final type = entry.value;
                final isSelected = selectedFilter == type;
                final label = type ?? '전체';

                return Expanded(
                  child: GestureDetector(
                    onTap: () =>
                        ref.read(companyFilterProvider.notifier).set(type),
                    child: Container(
                      margin: EdgeInsets.only(right: index == 3 ? 0 : 8),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? primaryColor : Colors.grey[300]!,
                        ),
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
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // 기업 목록 영역
          Expanded(
            child: companiesAsync.when(
              loading: () => _buildSkeletonList(primaryColor),
              error: (e, _) => const Center(
                child: Text(
                  '기업 목록을 불러오지 못했어요 😢',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              data: (data) {
                final allCompanies = _asCompanyList(data['companies']);
                final companies = _searchQuery.isEmpty
                    ? allCompanies
                    : allCompanies.where((c) {
                        final name = (c['companyName'] ?? c['company_name'] ?? '')
                            .toString()
                            .toLowerCase();
                        return name.contains(_searchQuery.toLowerCase());
                      }).toList();
                final total = companies.length;

                if (companies.isEmpty) {
                  return const Center(
                    child: Text(
                      '조건에 맞는 추천 기업이 없어요 🏢',
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
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
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }
                    return _buildCompanyCard(
                      context,
                      companies[index - 1],
                      primaryColor,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyCard(
    BuildContext context,
    Map<String, dynamic> company,
    Color primaryColor,
  ) {
    final matchRate = company['matchRate'] ?? company['match_rate'] ?? 0;
    
    // 💡 매칭률(%)에 따라 뱃지 색상을 결정하는 로직 추가
    final int rateValue = int.tryParse(matchRate.toString()) ?? 0;
    Color badgeColor;
    if (rateValue >= 70) {
      badgeColor = primaryColor; // 70% 이상은 메인 컬러(초록색)
    } else if (rateValue >= 40) {
      badgeColor = Colors.orange; // 40% ~ 69%는 주황색(노란색 계열)
    } else {
      badgeColor = Colors.red; // 39% 이하는 빨간색
    }

    final reasons = _asStringList(
      company['recommendationReasons'] ?? company['recommendation_reasons'],
    );
    final cName =
        company['companyName'] ??
        company['company_name'] ??
        company['name'] ??
        '';
    final cType =
        company['companyType'] ??
        company['company_type'] ??
        company['type'] ??
        '';
    final careerUrl = _asNullableString(
      company['careerUrl'] ?? company['career_url'],
    );
    final logoAsset = companyLogoAsset(cName);

    final companyId = company['companyId'] ?? company['company_id'];
    final isAiOnly = companyId == null;

    return GestureDetector(
      onTap: isAiOnly
          ? () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AiCompanyDetailScreen(
                    companyName: cName,
                    companyType: cType,
                    industry: company['industry'] ?? '',
                    region: company['region'] ?? '',
                    matchRate: rateValue,
                    reasons: _asStringList(company['recommendationReasons'] ?? company['recommendation_reasons']),
                    careerUrl: careerUrl,
                  ),
                ),
              )
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CompanyDetailScreen(
                    companyId: companyId,
                    companyName: cName,
                    careerUrl: careerUrl,
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
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white, // 💡 배경을 흰색으로 변경
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!), // 💡 테두리 추가
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: logoAsset != null
                        ? Image.asset( // 💡 Padding 제거하고 꽉 차게 설정
                            logoAsset,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildLogoFallback(cName, primaryColor),
                          )
                        : _buildLogoFallback(cName, primaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              cName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (isAiOnly) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'AI 추천',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        '$cType · ${company['industry'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                // 💡 매칭률(%) 뱃지 영역 - 계산된 badgeColor를 사용
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$matchRate%',
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (reasons.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: reasons.map<Widget>((reason) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      reason.toString(),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  );
                }).toList(),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.black54,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      company['hiringSeason'] ??
                          company['hiring_season'] ??
                          '-',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                if (!isAiOnly)
                  Text(
                    '상세보기 >',
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            if (careerUrl != null) ...[
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _openCareerUrl(context, careerUrl),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('채용 페이지 보기'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(color: primaryColor.withOpacity(0.35)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _asCompanyList(dynamic value) {
    if (value is! List) return const [];

    return value
        .whereType<Map>()
        .map((company) => Map<String, dynamic>.from(company))
        .toList();
  }

  List<String> _asStringList(dynamic value) {
    if (value is! List) return const [];

    return value.map((item) => item.toString()).toList();
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

  Widget _buildLogoFallback(String companyName, Color primaryColor) {
    return Center(
      child: Text(
        companyName.isNotEmpty ? companyName.substring(0, 1) : '?',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
      ),
    );
  }

  Widget _buildSkeletonList(Color primaryColor) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: 5,
      itemBuilder: (context, index) => _buildSkeletonCard(),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _shimmerBox(width: 48, height: 48, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _shimmerBox(width: 120, height: 16, radius: 6),
                    const SizedBox(height: 6),
                    _shimmerBox(width: 80, height: 12, radius: 4),
                  ],
                ),
              ),
              _shimmerBox(width: 48, height: 28, radius: 14),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _shimmerBox(width: 80, height: 24, radius: 8),
              const SizedBox(width: 8),
              _shimmerBox(width: 100, height: 24, radius: 8),
            ],
          ),
          const SizedBox(height: 16),
          _shimmerBox(width: 60, height: 12, radius: 4),
        ],
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height, required double radius}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.4, end: 1.0),
      duration: const Duration(milliseconds: 800),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(radius),
            ),
          ),
        );
      },
      onEnd: () {},
    );
  }
}