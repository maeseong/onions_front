import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/company_provider.dart';
import '../repositories/company_repository.dart';
import '../utils/company_logo.dart';

// 갭 분석 별도 로딩 — String 키로 캐싱 (Map은 reference equality라 매번 재호출됨)
final aiGapAnalysisProvider = FutureProvider.family<Map<String, dynamic>, String>(
  (ref, key) async {
    // key 형식: "companyName|type|industry|region|matchRate"
    final parts = key.split('|');
    try {
      final repository = ref.watch(companyRepositoryProvider);
      return await repository.fetchAiCompanyDetail(
        name: parts[0],
        type: parts.length > 1 ? parts[1] : '',
        industry: parts.length > 2 ? parts[2] : '',
        region: parts.length > 3 ? parts[3] : '',
        matchRate: parts.length > 4 ? int.tryParse(parts[4]) ?? 0 : 0,
      );
    } catch (_) {
      return {};
    }
  },
);

class AiCompanyDetailScreen extends ConsumerStatefulWidget {
  final String companyName;
  final String companyType;
  final String industry;
  final String region;
  final int matchRate;
  final List<String> reasons;
  final String? careerUrl;

  const AiCompanyDetailScreen({
    super.key,
    required this.companyName,
    required this.companyType,
    required this.industry,
    required this.region,
    required this.matchRate,
    required this.reasons,
    this.careerUrl,
  });

  @override
  ConsumerState<AiCompanyDetailScreen> createState() => _AiCompanyDetailScreenState();
}

class _AiCompanyDetailScreenState extends ConsumerState<AiCompanyDetailScreen> {
  int? _companyId;
  bool _scrapped = false;
  bool _scrapLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCompanyId();
  }

  Future<void> _loadCompanyId() async {
    final id = await ref.read(companyRepositoryProvider).getCompanyIdByName(widget.companyName);
    if (!mounted) return;
    setState(() => _companyId = id);
    if (id != null) {
      final list = await ref.read(companyRepositoryProvider).getScrappedCompanies();
      if (!mounted) return;
      setState(() {
        _scrapped = list.any((c) =>
            (c['companyId'] ?? c['company_id'])?.toString() == id.toString());
      });
    }
  }

  Future<void> _toggleScrap() async {
    if (_companyId == null || _scrapLoading) return;
    setState(() => _scrapLoading = true);
    try {
      final repo = ref.read(companyRepositoryProvider);
      if (_scrapped) {
        await repo.unscrapCompany(_companyId!);
        setState(() => _scrapped = false);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스크랩이 해제됐어요')),
        );
      } else {
        await repo.scrapCompany(_companyId!);
        setState(() => _scrapped = true);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('스크랩했어요! 기업추천 > 스크랩에서 확인하세요 🔖')),
        );
      }
      ref.invalidate(scrappedCompaniesProvider);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('스크랩 처리에 실패했어요.')),
      );
    } finally {
      setState(() => _scrapLoading = false);
    }
  }

  String get _typeLabel => switch (widget.companyType.toLowerCase()) {
    'large' => '대기업',
    'mid' => '중견기업',
    'startup' => '스타트업',
    _ => widget.companyType,
  };

  String get _description =>
      '${widget.companyName}은 ${widget.industry.isEmpty ? "IT" : widget.industry} 분야의 $_typeLabel입니다.\n'
      'AI가 유저의 스펙과 선호 조건을 분석하여 선정한 추천 기업입니다.';

  List<String> get _cultureTags {
    final tags = <String>[];
    final t = widget.companyType.toLowerCase();
    final ind = widget.industry.toLowerCase();

    if (t == 'startup') {
      tags.addAll(['수평적 문화', '빠른 성장', '자율 근무']);
    } else if (t == 'large') {
      tags.addAll(['체계적 교육', '안정적 복지', '글로벌 환경']);
    } else {
      tags.addAll(['워라밸', '성과 중심']);
    }

    if (ind.contains('핀테크') || ind.contains('금융')) tags.add('금융 혁신');
    else if (ind.contains('게임')) tags.add('창의적 문화');
    else if (ind.contains('커머스')) tags.add('데이터 중심');
    else if (ind.contains('it') || ind.contains('소프트웨어')) tags.add('기술 중심');

    return tags.toSet().take(4).toList();
  }

  String get _effectiveCareerUrl =>
      widget.careerUrl ??
      'https://www.saramin.co.kr/zf_user/search?searchword=${Uri.encodeComponent(widget.companyName)}';

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final logoAsset = companyLogoAsset(widget.companyName);
    final gapAsync = ref.watch(
      aiGapAnalysisProvider('${widget.companyName}|${widget.companyType}|${widget.industry}|${widget.region}|${widget.matchRate}'),
    );

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
        title: Text(widget.companyName,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('AI 추천',
                style: TextStyle(fontSize: 12, color: Colors.purple, fontWeight: FontWeight.bold)),
          ),
          _scrapLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
                )
              : IconButton(
                  icon: Icon(
                    _scrapped ? Icons.bookmark : Icons.bookmark_border,
                    color: _scrapped ? Colors.amber[600] : Colors.black,
                  ),
                  onPressed: _companyId != null ? _toggleScrap : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('DB에 등록되지 않은 기업은 스크랩할 수 없어요')),
                    );
                  },
                ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 기업 정보 카드
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
                        width: 56, height: 56,
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
                                  errorBuilder: (_, __, ___) => _logoFallback(primaryColor)
                                )
                              : _logoFallback(primaryColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.companyName,
                                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            Text('$_typeLabel · ${widget.industry.isEmpty ? "-" : widget.industry}',
                                style: const TextStyle(color: Colors.black54, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(_description,
                      style: const TextStyle(color: Colors.black54, height: 1.6)),
                  if (widget.region.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(widget.region, style: const TextStyle(color: Colors.black54)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _openUrl(context, _effectiveCareerUrl),
                      icon: const Icon(Icons.open_in_new, size: 18),
                      label: const Text('채용 페이지 보기'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('기업 문화',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8, runSpacing: 8,
                    children: _cultureTags.map((tag) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(tag,
                          style: TextStyle(color: primaryColor, fontSize: 13, fontWeight: FontWeight.w500)),
                    )).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // AI 추천 이유 카드
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('AI 추천 이유',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${widget.matchRate}%',
                            style: TextStyle(
                                color: primaryColor, fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (widget.reasons.isEmpty)
                    Text('스펙 및 선호 조건 분석 기반 추천',
                        style: TextStyle(color: Colors.grey[600]))
                  else
                    ...widget.reasons.map((reason) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 5),
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                                color: primaryColor, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(reason,
                                style: const TextStyle(fontSize: 14, height: 1.4)),
                          ),
                        ],
                      ),
                    )).toList(),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 스펙 분석 카드 (별도 로딩)
            gapAsync.when(
              loading: () => Container(
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
                    const Text('스펙 분석', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    const Center(child: CircularProgressIndicator()),
                    const SizedBox(height: 8),
                    Center(child: Text('스펙 분석 중...', style: TextStyle(color: Colors.grey[500], fontSize: 13))),
                  ],
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (data) {
                final gapAnalysis = data['gapAnalysis'] as Map? ?? {};
                final priorityActions = (data['priorityActions'] as List?) ?? [];
                if (gapAnalysis.isEmpty) return const SizedBox.shrink();
                return _buildMatchCard(context, gapAnalysis, priorityActions, primaryColor);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _logoFallback(Color primaryColor) {
    return Center(
      child: Text(
        widget.companyName.isNotEmpty ? widget.companyName.substring(0, 1) : '?',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor),
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Map gapAnalysis,
      List priorityActions, Color primaryColor) {
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
          const Text('스펙 분석', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...gapAnalysis.entries.map((entry) {
            final key = entry.key as String;
            final value = entry.value as Map? ?? {};
            final status = value['status'] ?? 'same';
            final my = value['my'] ?? 0;
            final avg = value['avg'] ?? 0;

            Color statusColor;
            IconData statusIcon;
            switch (status) {
              case 'good': statusColor = Colors.green; statusIcon = Icons.arrow_upward; break;
              case 'lack': statusColor = Colors.orange; statusIcon = Icons.arrow_downward; break;
              case 'critical': statusColor = Colors.red; statusIcon = Icons.warning_outlined; break;
              default: statusColor = Colors.grey; statusIcon = Icons.remove;
            }
            final label = {'gpa': '학점', 'toeic': '토익', 'internship': '인턴',
                           'certificate': '자격증', 'project': '프로젝트'}[key] ?? key;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  SizedBox(width: 60, child: Text(label,
                      style: const TextStyle(color: Colors.black54, fontSize: 13))),
                  Expanded(child: Row(children: [
                    Text('나: $my', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Text('평균: $avg', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                  ])),
                  Icon(statusIcon, size: 16, color: statusColor),
                ],
              ),
            );
          }).toList(),
          if (priorityActions.isNotEmpty) ...[
            const Divider(height: 32),
            const Text('우선 개선 항목',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 12),
            ...priorityActions.map((action) {
              final a = action as Map? ?? {};
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 24, height: 24,
                      decoration: BoxDecoration(color: primaryColor, shape: BoxShape.circle),
                      child: Center(child: Text('${a['rank']}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Text(a['action'] ?? '',
                        style: const TextStyle(fontWeight: FontWeight.w500))),
                    Text(a['effect'] ?? '',
                        style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return;
      } catch (_) {}
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('채용 페이지를 열 수 없습니다.')));
    }
  }
}