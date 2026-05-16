import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  // 입력 데이터
  final TextEditingController _nameController = TextEditingController();
  int? _selectedGrade;
  String? _selectedJob;
  String? _selectedCompanyType;
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _toeicController = TextEditingController();
  final TextEditingController _certController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _internController = TextEditingController();
  final TextEditingController _awardController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _gpaController.dispose();
    _toeicController.dispose();
    _certController.dispose();
    _projectController.dispose();
    _internController.dispose();
    _awardController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage++);
    } else {
      _submitOnboarding();
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() => _currentPage--);
    }
  }

  Future<void> _submitOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(apiClientProvider).dio;
      await dio.post('/api/users/onboarding', data: {
        'name': _nameController.text.trim(),
        'grade': _selectedGrade,
        'jobName': _selectedJob,
        // 'preferred_company_type': _selectedCompanyType, (API 명세서에 없어서 우선 주석 처리)
        'gpa': double.tryParse(_gpaController.text) ?? 0,
        'toeicScore': int.tryParse(_toeicController.text) ?? 0,
        'certificateCount': int.tryParse(_certController.text) ?? 0,
        'projectCount': int.tryParse(_projectController.text) ?? 0,
        'internshipCount': int.tryParse(_internController.text) ?? 0,
        'awardCount': int.tryParse(_awardController.text) ?? 0,
        'techStack': "",
        'targetCompanyIds': [],
      });
      if (mounted) context.go('/home');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장에 실패했어요. 다시 시도해주세요.')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // 상단 진행바
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뒤로가기
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _prevPage,
                      child: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                  const SizedBox(height: 16),
                  // 진행바
                  Row(
                    children: List.generate(4, (i) {
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          height: 4,
                          decoration: BoxDecoration(
                            color: i <= _currentPage ? primaryColor : Colors.grey[200],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_currentPage + 1} / 4',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                  ),
                ],
              ),
            ),

            // 페이지 내용
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildPage1(primaryColor),
                  _buildPage2(primaryColor),
                  _buildPage3(primaryColor),
                  _buildPage4(primaryColor),
                ],
              ),
            ),

            // 다음 버튼
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    _currentPage == 3 ? '시작하기 🌱' : '다음',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1단계: 이름, 학년
  Widget _buildPage1(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.eco, size: 48, color: primaryColor),
          const SizedBox(height: 16),
          const Text('안녕하세요! 👋', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('이름과 학년을 알려주세요', style: TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 40),

          // 이름
          const Text('이름', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '이름을 입력하세요',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 28),

          // 학년
          const Text('학년', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Row(
            children: [1, 2, 3, 4].map((grade) {
              final isSelected = _selectedGrade == grade;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedGrade = grade),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? primaryColor : Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isSelected ? primaryColor : Colors.grey[200]!),
                    ),
                    child: Center(
                      child: Text(
                        '$grade학년',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 2단계: 희망 직무, 선호 기업 유형
  Widget _buildPage2(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.work_outline, size: 48, color: primaryColor),
          const SizedBox(height: 16),
          const Text('어떤 일을 하고 싶으세요?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('희망 직무와 선호 기업 유형을 선택해주세요', style: TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 40),

          // 희망 직무
          const Text('희망 직무', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: ['개발', '기획', '마케팅', '디자인', '데이터', '영업'].map((job) {
              final isSelected = _selectedJob == job;
              return GestureDetector(
                onTap: () => setState(() => _selectedJob = job),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey[200]!),
                  ),
                  child: Text(
                    job,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),

          // 선호 기업 유형
          const Text('선호 기업 유형', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Column(
            children: [
              {'type': '대기업', 'desc': '안정적인 대기업을 목표로 해요', 'icon': '🏢'},
              {'type': '중견', 'desc': '중견기업에서 성장하고 싶어요', 'icon': '🏗️'},
              {'type': '스타트업', 'desc': '빠르게 성장하는 스타트업이 좋아요', 'icon': '🚀'},
            ].map((item) {
              final isSelected = _selectedCompanyType == item['type'];
              return GestureDetector(
                onTap: () => setState(() => _selectedCompanyType = item['type'] as String),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor.withOpacity(0.05) : Colors.grey[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Text(item['icon'] as String, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['type'] as String, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? primaryColor : Colors.black87)),
                          Text(item['desc'] as String, style: const TextStyle(color: Colors.black54, fontSize: 13)),
                        ],
                      ),
                      const Spacer(),
                      if (isSelected) Icon(Icons.check_circle, color: primaryColor),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // 3단계: 스펙 입력
  Widget _buildPage3(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.bar_chart, size: 48, color: primaryColor),
          const SizedBox(height: 16),
          const Text('현재 스펙을 알려주세요', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('없거나 모르면 0으로 입력해도 괜찮아요', style: TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 40),

          _buildSpecInput('학점 (GPA)', '예: 3.8', _gpaController, '/ 4.5'),
          _buildSpecInput('토익 (TOEIC)', '예: 820', _toeicController, '점'),
          _buildSpecInput('자격증', '취득한 자격증 수', _certController, '개'),
          _buildSpecInput('프로젝트', '진행한 프로젝트 수', _projectController, '개'),
          _buildSpecInput('인턴 경험', '인턴십 횟수', _internController, '회'),
          _buildSpecInput('수상 경력', '수상 횟수', _awardController, '회'),
        ],
      ),
    );
  }

  Widget _buildSpecInput(String label, String hint, TextEditingController controller, String suffix) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              suffixText: suffix,
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  // 4단계: 완료
  Widget _buildPage4(Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline, size: 48, color: primaryColor),
          const SizedBox(height: 16),
          const Text('준비 완료! 🎉', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('입력하신 정보를 확인해주세요', style: TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 40),

          // 입력 정보 요약 카드
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              children: [
                _buildSummaryRow('이름', _nameController.text.isEmpty ? '-' : _nameController.text),
                _buildSummaryRow('학년', _selectedGrade != null ? '$_selectedGrade학년' : '-'),
                _buildSummaryRow('희망 직무', _selectedJob ?? '-'),
                _buildSummaryRow('선호 기업', _selectedCompanyType ?? '-'),
                const Divider(height: 32),
                _buildSummaryRow('학점', _gpaController.text.isEmpty ? '-' : '${_gpaController.text} / 4.5'),
                _buildSummaryRow('토익', _toeicController.text.isEmpty ? '-' : '${_toeicController.text}점'),
                _buildSummaryRow('자격증', _certController.text.isEmpty ? '-' : '${_certController.text}개'),
                _buildSummaryRow('프로젝트', _projectController.text.isEmpty ? '-' : '${_projectController.text}개'),
                _buildSummaryRow('인턴', _internController.text.isEmpty ? '-' : '${_internController.text}회'),
                _buildSummaryRow('수상', _awardController.text.isEmpty ? '-' : '${_awardController.text}회'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              '시작하기를 누르면 맞춤 퀘스트와\n로드맵이 생성돼요! 🌱',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}