import 'package:flutter/material.dart';

// 태그의 긍정(초록)/부정(빨강) 상태를 나누기 위한 모델
class TagModel {
  final String text;
  final bool isPositive;
  TagModel(this.text, {this.isPositive = true});
}

// 피그마 디자인에 맞춘 데이터 모델
class CompanyModel {
  final String logoText;
  final Color logoBgColor;
  final Color logoTextColor;
  final String name;
  final String description;
  final int matchRate;
  final List<TagModel> tags;

  CompanyModel({
    required this.logoText,
    required this.logoBgColor,
    required this.logoTextColor,
    required this.name,
    required this.description,
    required this.matchRate,
    required this.tags,
  });
}

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({super.key});

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  // 피그마 스크린샷과 100% 동일한 더미 데이터 리스트
  final List<CompanyModel> _companies = [
    CompanyModel(
      logoText: 'K',
      logoBgColor: const Color(0xFFFFF3C4),
      logoTextColor: const Color(0xFFC69A02),
      name: '카카오',
      description: '대기업 · 개발 · 플랫폼',
      matchRate: 92,
      tags: [TagModel('적합 직무'), TagModel('프로젝트 우수')],
    ),
    CompanyModel(
      logoText: 'N',
      logoBgColor: const Color(0xFFE0F5E6),
      logoTextColor: const Color(0xFF26A641),
      name: '네이버',
      description: '대기업 · 개발 · 포털',
      matchRate: 88,
      tags: [TagModel('적합 직무'), TagModel('학점 우수')],
    ),
    CompanyModel(
      logoText: 'T',
      logoBgColor: const Color(0xFFE5EFFF),
      logoTextColor: const Color(0xFF2D72F1),
      name: '토스',
      description: '스타트업 · 개발 · 핀테크',
      matchRate: 85,
      tags: [TagModel('프로젝트 우수'), TagModel('성장 가능성')],
    ),
    CompanyModel(
      logoText: 'C',
      logoBgColor: const Color(0xFFF3E5F5),
      logoTextColor: const Color(0xFF8E24AA),
      name: '쿠팡',
      description: '대기업 · 개발 · 이커머스',
      matchRate: 78,
      tags: [TagModel('적합 직무')],
    ),
    CompanyModel(
      logoText: 'L',
      logoBgColor: const Color(0xFFF0F4C3),
      logoTextColor: const Color(0xFFAFB42B),
      name: '라인',
      description: '중견 · 개발 · 메신저',
      matchRate: 72,
      tags: [TagModel('학점 우수'), TagModel('인턴 부족', isPositive: false)], // 부정 태그
    ),
    CompanyModel(
      logoText: '당',
      logoBgColor: const Color(0xFFFFE0B2),
      logoTextColor: const Color(0xFFF57C00),
      name: '당근',
      description: '스타트업 · 개발 · 커뮤니티',
      matchRate: 65,
      tags: [TagModel('성장 가능성'), TagModel('인턴 부족', isPositive: false)], // 부정 태그
    ),
  ];

  String _selectedFilter = '전체';
  final Color primaryColor = const Color(0xFF61B099); // 피그마 메인 초록색

  // 매칭률에 따라 색상을 반환하는 함수 (피그마 디자인 반영)
  Color _getMatchColor(int rate) {
    if (rate >= 80) return primaryColor; // 80% 이상: 초록
    if (rate >= 70) return const Color(0xFF42A5F5); // 70% 대: 파랑
    return const Color(0xFFF57C00); // 60% 대: 주황
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('기업 추천', style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. 필터 칩 영역 ---
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  _buildFilterChip('전체'),
                  const SizedBox(width: 8),
                  _buildFilterChip('대기업'),
                  const SizedBox(width: 8),
                  _buildFilterChip('중견'),
                  const SizedBox(width: 8),
                  _buildFilterChip('스타트업'),
                  const SizedBox(width: 8),
                  _buildFilterChip('개발'),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 2. ⭐️ 크기를 줄인 대시보드 카드 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16), // 상하 여백 축소
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('현재 내 스펙으로 매칭되는 기업', style: TextStyle(color: Colors.white, fontSize: 13)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: const [
                        Text('14', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)), // 폰트 크기 축소
                        SizedBox(width: 8),
                        Text('개 기업', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white30, thickness: 1, height: 1),
                    const SizedBox(height: 12),
                    // 3등분 통계
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('3', '대기업'),
                        Container(width: 1, height: 30, color: Colors.white30),
                        _buildStatItem('6', '중견'),
                        Container(width: 1, height: 30, color: Colors.white30),
                        _buildStatItem('5', '스타트업'),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- 3. 리스트 헤더 ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('매칭률 높은 기업', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Text('정렬', style: TextStyle(fontSize: 14, color: Colors.grey[800])),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey[800]),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // --- 4. 기업 카드 리스트 ---
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _companies.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                return _buildCompanyCard(_companies[index]);
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // 필터 칩 위젯
  Widget _buildFilterChip(String label) {
    bool isSelected = _selectedFilter == label;
    return ActionChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      backgroundColor: isSelected ? primaryColor : Colors.grey[100],
      side: const BorderSide(color: Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => setState(() => _selectedFilter = label),
    );
  }

  // 대시보드 내부의 통계 아이템
  Widget _buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(number, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  // ⭐️ 피그마와 레이아웃이 완벽하게 일치하는 개별 기업 카드
  Widget _buildCompanyCard(CompanyModel company) {
    final matchColor = _getMatchColor(company.matchRate); // 매칭률별 컬러 추출

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // 상단 정렬
        children: [
          // 좌측: 동그란 로고
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(color: company.logoBgColor, shape: BoxShape.circle),
            child: Center(
              child: Text(
                company.logoText,
                style: TextStyle(color: company.logoTextColor, fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 우측: 텍스트 및 프로그레스 바 영역 (로고 우측으로 들여쓰기 됨)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 이름과 우측 뱃지
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(company.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: matchColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: Text(
                        '${company.matchRate}%',
                        style: TextStyle(color: matchColor, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // 설명
                Text(company.description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 12),
                
                // 태그 리스트
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: company.tags.map((tag) {
                    // 태그의 긍정/부정 여부에 따라 색상 지정
                    final Color tagColor = tag.isPositive ? primaryColor : Colors.redAccent;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: tagColor.withOpacity(0.3)),
                      ),
                      child: Text(tag.text, style: TextStyle(color: tagColor, fontSize: 12, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 하단 매칭률 텍스트 & 바
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('매칭률', style: TextStyle(fontSize: 12, color: Colors.grey[700], fontWeight: FontWeight.bold)),
                    Text('${company.matchRate}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: company.matchRate / 100,
                    backgroundColor: Colors.grey[200],
                    color: matchColor, // 💡 매칭률에 따라 초록/파랑/주황색으로 변함
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}