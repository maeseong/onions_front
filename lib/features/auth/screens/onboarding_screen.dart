import 'package:flutter/material.dart';
import '../../../shared/widgets/tech_stack_selector.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_provider.dart';
import '../../../core/constants/app_constants.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  int? _selectedGrade;
  String? _selectedJob;
  String? _selectedCompanyType;
  String? _selectedRegion;
  int? _selectedSalary;
  String? _selectedEmploymentPeriod;
  final TextEditingController _gpaController = TextEditingController();
  final TextEditingController _toeicController = TextEditingController();
  final TextEditingController _certController = TextEditingController();
  final TextEditingController _projectController = TextEditingController();
  final TextEditingController _internController = TextEditingController();
  final TextEditingController _awardController = TextEditingController();
  List<String> _selectedTechStacks = [];
  bool _noToeic = false;
  bool _noCert = false;
  bool _noIntern = false;
  bool _noAward = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_updateState);
    _gpaController.addListener(_updateState);
    _toeicController.addListener(_updateState);
    _certController.addListener(_updateState);
    _projectController.addListener(_updateState);
    _internController.addListener(_updateState);
    _awardController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

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

  bool get _isNextButtonEnabled {
    if (_currentPage == 0) {
      return _nameController.text.trim().isNotEmpty && _selectedGrade != null;
    } else if (_currentPage == 1) {
      return _selectedJob != null && _selectedCompanyType != null;
    } else if (_currentPage == 2) {
      return _gpaController.text.trim().isNotEmpty &&
          (_noToeic || _toeicController.text.trim().isNotEmpty) &&
          (_noCert || _certController.text.trim().isNotEmpty) &&
          _projectController.text.trim().isNotEmpty &&
          (_noIntern || _internController.text.trim().isNotEmpty) &&
          (_noAward || _awardController.text.trim().isNotEmpty);
    }
    return true;
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
      const storage = FlutterSecureStorage();

      // 로그인 시 발급받은 토큰을 꺼내서 서버로 전송할 준비
      final token = await storage.read(key: AppConstants.accessTokenKey);

      await dio.post(
        '/api/users/onboarding',
        data: {
          'name': _nameController.text.trim(),
          'grade': _selectedGrade,
          'jobName': _selectedJob,
          'preferredCompanyType': _selectedCompanyType,
          'preferredRegion': _selectedRegion,
          'preferredSalary': _selectedSalary,
          'preferredEmploymentPeriod': _selectedEmploymentPeriod,
          'gpa': double.tryParse(_gpaController.text) ?? 0.0,
          'toeicScore': _noToeic ? 0 : int.tryParse(_toeicController.text) ?? 0,
          'certificateCount': _noCert ? 0 : int.tryParse(_certController.text) ?? 0,
          'projectCount': int.tryParse(_projectController.text) ?? 0,
          'internshipCount': _noIntern ? 0 : int.tryParse(_internController.text) ?? 0,
          'awardCount': _noAward ? 0 : int.tryParse(_awardController.text) ?? 0,
          'techStack': _selectedTechStacks.join(', '),
          'targetCompanyIds': [],
        },
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      await storage.write(key: 'isOnboarded', value: 'true');
      if (mounted) context.go('/home');
    } catch (e) {
      debugPrint('[온보딩 저장 실패 에러 로그] : $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장에 실패했어요. 에러: $e')));
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentPage > 0)
                    GestureDetector(
                      onTap: _prevPage,
                      child: const Icon(Icons.arrow_back_ios, size: 20),
                    ),
                  const SizedBox(height: 16),
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
                  Text('${_currentPage + 1} / 4', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
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
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: (_isLoading || !_isNextButtonEnabled) ? null : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey[300],
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                    _currentPage == 3 ? '시작하기 🌱' : '다음',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (_isLoading || !_isNextButtonEnabled) ? Colors.grey[500] : Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          const Text('이름', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '이름을 입력하세요',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true, fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 28),
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
                        style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
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
          const Text('희망 직무', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: ['개발자/SW엔지니어', '데이터/AI', '인프라/클라우드/보안', '임베디드/펌웨어', '반도체/제조IT', 'QA/테스트'].map((job) {
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
                  child: Text(job, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
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

          const SizedBox(height: 32),
          const Text('선호 근무 지역', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('통근 가능한 지역을 선택해주세요 (선택)', style: TextStyle(fontSize: 12, color: Colors.black45)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: ['서울', '판교/분당', '경기', '인천', '부산', '대전', '무관'].map((region) {
              final isSelected = _selectedRegion == region;
              return GestureDetector(
                onTap: () => setState(() => _selectedRegion = isSelected ? null : region),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey[200]!),
                  ),
                  child: Text(region, style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold, fontSize: 13,
                  )),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),
          const Text('희망 연봉', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('최소 희망 연봉을 선택해주세요 (선택)', style: TextStyle(fontSize: 12, color: Colors.black45)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: [
              {'label': '3,000만원 미만', 'value': 0},
              {'label': '3,000만원 이상', 'value': 3000},
              {'label': '4,000만원 이상', 'value': 4000},
              {'label': '5,000만원 이상', 'value': 5000},
              {'label': '6,000만원 이상', 'value': 6000},
            ].map((item) {
              final isSelected = _selectedSalary == item['value'] as int;
              return GestureDetector(
                onTap: () => setState(() => _selectedSalary = isSelected ? null : item['value'] as int),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey[200]!),
                  ),
                  child: Text(item['label'] as String, style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold, fontSize: 13,
                  )),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),
          const Text('취업 희망 시기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          const Text('언제쯤 취업을 목표로 하나요? (선택)', style: TextStyle(fontSize: 12, color: Colors.black45)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10, runSpacing: 10,
            children: _buildEmploymentPeriodOptions().map((item) {
              final isSelected = _selectedEmploymentPeriod == item['value'];
              return GestureDetector(
                onTap: () => setState(() =>
                    _selectedEmploymentPeriod = isSelected ? null : item['value'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryColor : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? primaryColor : Colors.grey[200]!),
                  ),
                  child: Text(item['label'] as String, style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.bold, fontSize: 13,
                  )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

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
          const Text('없는 항목은 "아직 없음"을 체크해주세요', style: TextStyle(fontSize: 15, color: Colors.black54)),
          const SizedBox(height: 40),
          _buildSpecInput('학점 (GPA)', '예: 3.8', _gpaController, '/ 4.5'),
          _buildSpecInputWithCheck('토익 (TOEIC)', '예: 820', _toeicController, '점', _noToeic, (v) => setState(() { _noToeic = v; if (v) _toeicController.clear(); })),
          _buildSpecInputWithCheck('자격증', '취득한 자격증 수', _certController, '개', _noCert, (v) => setState(() { _noCert = v; if (v) _certController.clear(); })),
          _buildSpecInput('프로젝트', '진행한 프로젝트 수', _projectController, '개'),
          _buildSpecInputWithCheck('인턴 경험', '인턴십 횟수', _internController, '회', _noIntern, (v) => setState(() { _noIntern = v; if (v) _internController.clear(); })),
          _buildSpecInputWithCheck('수상 경력', '수상 횟수', _awardController, '회', _noAward, (v) => setState(() { _noAward = v; if (v) _awardController.clear(); })),
          _buildTechStackInput(),
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
              filled: true, fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  /// 현재 날짜 기준으로 아직 지나지 않은 취업 희망 시기만 반환
  /// 상반기: 1~6월, 하반기: 7~12월
  List<Map<String, String>> _buildEmploymentPeriodOptions() {
    final now = DateTime.now();
    final year = now.year;
    final isSecondHalf = now.month >= 7; // 7월 이후면 하반기

    final options = <Map<String, String>>[];

    for (int y = year; y <= year + 1; y++) {
      // 상반기: 현재 연도 상반기는 7월 이전(1~6월)에만 포함
      if (y > year || !isSecondHalf) {
        options.add({'label': '$y 상반기', 'value': '${y}_first'});
      }
      // 하반기: 항상 포함
      options.add({'label': '$y 하반기', 'value': '${y}_second'});
    }

    options.add({'label': '즉시 가능', 'value': 'asap'});
    options.add({'label': '잘 모르겠어요', 'value': 'unknown'});
    return options;
  }

  Widget _buildSpecInputWithCheck(
    String label, String hint, TextEditingController controller,
    String suffix, bool isChecked, ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              GestureDetector(
                onTap: () => onChanged(!isChecked),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20, height: 20,
                      child: Checkbox(
                        value: isChecked,
                        onChanged: (v) => onChanged(v ?? false),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('아직 없음', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            enabled: !isChecked,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: isChecked ? '아직 없음' : hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              suffixText: isChecked ? null : suffix,
              filled: true,
              fillColor: isChecked ? Colors.grey[100] : Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechStackInput() {
    return TechStackSelector(
      selected: _selectedTechStacks,
      onChanged: (list) => setState(() => _selectedTechStacks = list),
    );
  }

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
                _buildSummaryRow('선호 지역', _selectedRegion ?? '-'),
                _buildSummaryRow('희망 연봉', _selectedSalary != null && _selectedSalary! > 0 ? '$_selectedSalary만원 이상' : '-'),
                _buildSummaryRow('취업 시기', _selectedEmploymentPeriod ?? '-'),
                const Divider(height: 32),
                _buildSummaryRow('학점', _gpaController.text.isEmpty ? '-' : '${_gpaController.text} / 4.5'),
                _buildSummaryRow('토익', _toeicController.text.isEmpty ? '-' : '${_toeicController.text}점'),
                _buildSummaryRow('자격증', _certController.text.isEmpty ? '-' : '${_certController.text}개'),
                _buildSummaryRow('프로젝트', _projectController.text.isEmpty ? '-' : '${_projectController.text}개'),
                _buildSummaryRow('인턴', _internController.text.isEmpty ? '-' : '${_internController.text}회'),
                _buildSummaryRow('수상', _awardController.text.isEmpty ? '-' : '${_awardController.text}회'),
                _buildSummaryRow('기술스택', _selectedTechStacks.isEmpty ? '-' : _selectedTechStacks.join(', ')),
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