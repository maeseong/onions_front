import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  bool _showNameInput = false;
  bool _hasSeenPage2Intro = false;
  bool _hasSeenPage3Intro = false;
  bool _hasSeenPage4Intro = false;

  int _page2AnimState = 0;
  int _page3AnimState = 0;
  int _page4AnimState = 0;

  final TextEditingController _nameController = TextEditingController();
  int? _selectedGrade;
  String? _selectedJob;
  String? _selectedCompanyType;

  final TextEditingController _gpaController = TextEditingController();
  final FocusNode _gpaFocus = FocusNode();

  final TextEditingController _toeicController = TextEditingController();
  final FocusNode _toeicFocus = FocusNode();
  bool _noToeic = false;

  final TextEditingController _certController = TextEditingController();
  final FocusNode _certFocus = FocusNode();
  bool _noCert = false;

  final TextEditingController _projectController = TextEditingController();
  final FocusNode _projectFocus = FocusNode();
  bool _noProject = false;

  final TextEditingController _internController = TextEditingController();
  final FocusNode _internFocus = FocusNode();
  bool _noIntern = false;

  final TextEditingController _awardController = TextEditingController();
  final FocusNode _awardFocus = FocusNode();
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

    _gpaFocus.addListener(() {
      if (!_gpaFocus.hasFocus && _gpaController.text.trim().isNotEmpty) {
        final val = double.tryParse(_gpaController.text.trim());
        if (val != null && val > 4.5) {
          _gpaController.text = '4.5';
        }
      }
      _updateState();
    });

    _toeicFocus.addListener(() {
      if (!_toeicFocus.hasFocus && _toeicController.text.trim().isNotEmpty) {
        final val = int.tryParse(_toeicController.text.trim());
        if (val != null) {
          if (val > 990) {
            _toeicController.text = '990';
          } else if (val == 0) {
            setState(() {
              _toeicController.clear();
              _noToeic = true;
            });
          }
        }
      }
      _updateState();
    });

    _setupZeroToNoneFocus(_certFocus, _certController, () {
      setState(() {
        _certController.clear();
        _noCert = true;
      });
    });
    _setupZeroToNoneFocus(_projectFocus, _projectController, () {
      setState(() {
        _projectController.clear();
        _noProject = true;
      });
    });
    _setupZeroToNoneFocus(_internFocus, _internController, () {
      setState(() {
        _internController.clear();
        _noIntern = true;
      });
    });
    _setupZeroToNoneFocus(_awardFocus, _awardController, () {
      setState(() {
        _awardController.clear();
        _noAward = true;
      });
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() => _showNameInput = true);
      }
    });
  }

  void _setupZeroToNoneFocus(FocusNode focus, TextEditingController controller, VoidCallback onZeroEntered) {
    focus.addListener(() {
      if (!focus.hasFocus && controller.text.trim().isNotEmpty) {
        final val = int.tryParse(controller.text.trim());
        if (val == 0) {
          onZeroEntered();
        }
      }
      _updateState();
    });
  }

  void _updateState() {
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _gpaController.dispose();
    _gpaFocus.dispose();
    _toeicController.dispose();
    _toeicFocus.dispose();
    _certController.dispose();
    _certFocus.dispose();
    _projectController.dispose();
    _projectFocus.dispose();
    _internController.dispose();
    _internFocus.dispose();
    _awardController.dispose();
    _awardFocus.dispose();
    super.dispose();
  }

  bool _isFieldValid(TextEditingController controller, bool isNoneChecked) {
    return isNoneChecked || controller.text.trim().isNotEmpty;
  }

  bool get _isNextButtonEnabled {
    if (_currentPage == 0) {
      return _nameController.text.trim().isNotEmpty && _selectedGrade != null;
    } else if (_currentPage == 1) {
      return _selectedJob != null && _selectedCompanyType != null;
    } else if (_currentPage == 2) {
      return _gpaController.text.trim().isNotEmpty &&
          _isFieldValid(_toeicController, _noToeic) &&
          _isFieldValid(_certController, _noCert) &&
          _isFieldValid(_projectController, _noProject) &&
          _isFieldValid(_internController, _noIntern) &&
          _isFieldValid(_awardController, _noAward);
    }
    return true;
  }

  bool get _isMainUiVisible {
    if (_currentPage == 0) return _showNameInput;
    if (_currentPage == 1) return _page2AnimState == 4;
    if (_currentPage == 2) return _page3AnimState == 4;
    if (_currentPage == 3) return _page4AnimState == 4;
    return true;
  }

  void _runPage2Animation() {
    _hasSeenPage2Intro = true;
    setState(() => _page2AnimState = 1);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _page2AnimState == 1) setState(() => _page2AnimState = 2);
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _page2AnimState == 2) setState(() => _page2AnimState = 3);
    });
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted && _page2AnimState == 3) setState(() => _page2AnimState = 4);
    });
  }

  void _runPage3Animation() {
    _hasSeenPage3Intro = true;
    setState(() => _page3AnimState = 1);

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted && _page3AnimState == 1) setState(() => _page3AnimState = 2);
    });
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _page3AnimState == 2) setState(() => _page3AnimState = 3);
    });
    Future.delayed(const Duration(milliseconds: 4500), () {
      if (mounted && _page3AnimState == 3) setState(() => _page3AnimState = 4);
    });
  }

  void _runPage4Animation() {
    _hasSeenPage4Intro = true;
    setState(() => _page4AnimState = 1); 

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _page4AnimState = 4);
    });
  }

  void _nextPage() {
    FocusScope.of(context).unfocus();

    if (_currentPage == 0) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage = 1);

      if (!_hasSeenPage2Intro) {
        _runPage2Animation();
      } else {
        setState(() => _page2AnimState = 4);
      }
    } else if (_currentPage == 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage = 2);

      if (!_hasSeenPage3Intro) {
        _runPage3Animation();
      } else {
        setState(() => _page3AnimState = 4);
      }
    } else if (_currentPage == 2) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage = 3);

      if (!_hasSeenPage4Intro) {
        _runPage4Animation();
      } else {
        setState(() => _page4AnimState = 4);
      }
    } else {
      _submitOnboarding();
    }
  }

  void _prevPage() {
    FocusScope.of(context).unfocus();
    if (_currentPage > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      setState(() => _currentPage--);
    }
  }

  Future<void> _submitOnboarding() async {
    setState(() => _isLoading = true);
    try {
      final dio = ref.read(apiClientProvider).dio;
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: AppConstants.accessTokenKey);

      await dio.post(
        '/api/users/onboarding',
        data: {
          'name': _nameController.text.trim(),
          'grade': _selectedGrade,
          'jobName': _selectedJob,
          'preferredCompanyType': _selectedCompanyType,
          'gpa': double.tryParse(_gpaController.text) ?? 0.0,
          'toeicScore': _noToeic ? 0 : (int.tryParse(_toeicController.text) ?? 0),
          'certificateCount': _noCert ? 0 : (int.tryParse(_certController.text) ?? 0),
          'projectCount': _noProject ? 0 : (int.tryParse(_projectController.text) ?? 0),
          'internshipCount': _noIntern ? 0 : (int.tryParse(_internController.text) ?? 0),
          'awardCount': _noAward ? 0 : (int.tryParse(_awardController.text) ?? 0),
          'techStack': "",
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

  Widget _buildAnimatedSection({required bool isVisible, required Widget child}) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      child: AnimatedOpacity(
        opacity: isVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: isVisible ? child : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildConfettiEffect() {
    final colors = [
      Colors.pinkAccent,
      Colors.tealAccent,
      Colors.purpleAccent,
      Colors.amber,
      Colors.cyan,
      Colors.lightGreenAccent
    ];
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: List.generate(16, (index) {
            final angle = (index * 360 / 16) * math.pi / 180;
            final radius = 130.0 * value;
            final opacity = 1.0 - value;
            return Transform.translate(
              offset: Offset(math.cos(angle) * radius, math.sin(angle) * radius),
              child: Opacity(
                opacity: opacity,
                child: Container(
                  width: index % 2 == 0 ? 8 : 12,
                  height: index % 2 == 0 ? 8 : 12,
                  decoration: BoxDecoration(
                    color: colors[index % colors.length],
                    shape: index % 3 == 0 ? BoxShape.rectangle : BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              IgnorePointer(
                ignoring: !_isMainUiVisible,
                child: Opacity(
                  opacity: _isMainUiVisible ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
              IgnorePointer(
                ignoring: !_isMainUiVisible,
                child: Opacity(
                  opacity: _isMainUiVisible ? 1.0 : 0.0,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      height: 56,
                      child: _currentPage == 0
                          ? ElevatedButton(
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
                                      '다음',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: (_isLoading || !_isNextButtonEnabled)
                                            ? Colors.grey[500]
                                            : Colors.white,
                                      ),
                                    ),
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _prevPage,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        side: BorderSide(color: Colors.grey[300]!),
                                      ),
                                    ),
                                    child: const Text(
                                      '이전',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
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
                                        : Center(
                                            child: Text(
                                              _currentPage == 3 ? '시작하기' : '다음',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                height: 1.2,
                                                color: (_isLoading || !_isNextButtonEnabled)
                                                    ? Colors.grey[500]
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1 페이지
  Widget _buildPage1(Color primaryColor) {
    final isNameEntered = _nameController.text.trim().isNotEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOutCubic,
            margin: EdgeInsets.only(
              top: _showNameInput ? 0 : MediaQuery.of(context).size.height * 0.22,
            ),
            alignment: _showNameInput ? Alignment.topLeft : Alignment.center,
            child: Row(
              mainAxisAlignment: _showNameInput ? MainAxisAlignment.start : MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOutCubic,
                  style: TextStyle(
                    fontSize: _showNameInput ? 28 : 38,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  child: const Text('만나서 반가워요 '),
                ),
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  builder: (context, value, child) {
                    return Transform.rotate(
                      angle: math.sin(value * math.pi * 5) * 0.3,
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeInOutCubic,
                        style: TextStyle(fontSize: _showNameInput ? 28 : 38),
                        child: const Text('👋'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),

          _buildAnimatedSection(
            isVisible: _showNameInput,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '먼저 이름을 입력해주세요',
                  style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: '이름을 입력하세요',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          
          _buildAnimatedSection(
            isVisible: isNameEntered,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '다음은 현재 재학 중인 학년을 선택해주세요',
                  style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
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
                            border: Border.all(color: isSelected ? primaryColor : Colors.transparent),
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
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 2 페이지
  Widget _buildPage2(Color primaryColor) {
    final isReady = _page2AnimState == 4;
    final isJobSelected = _selectedJob != null;

    return Stack(
      children: [
        if (_page2AnimState == 1 || _page2AnimState == 2)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_page2AnimState == 1) _buildConfettiEffect(),
                AnimatedOpacity(
                  opacity: _page2AnimState == 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: const Text(
                    '좋아요 🎉',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

        if (_page2AnimState >= 2)
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOutCubic,
                  margin: EdgeInsets.only(
                    top: isReady ? 0 : MediaQuery.of(context).size.height * 0.22,
                  ),
                  alignment: isReady ? Alignment.topLeft : Alignment.center,
                  child: AnimatedOpacity(
                    opacity: _page2AnimState >= 3 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1200),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _nameController.text,
                            style: TextStyle(color: primaryColor),
                          ),
                          TextSpan(
                            text: isReady ? '님에 대해 좀 더 알려 주세요' : '님에 대해\n좀 더 알려 주세요',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      textAlign: isReady ? TextAlign.left : TextAlign.center,
                      style: TextStyle(
                        fontSize: isReady ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                _buildAnimatedSection(
                  isVisible: isReady,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Text(
                        '희망하시는 직무를 선택해주세요',
                        style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 16),
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
                      
                      _buildAnimatedSection(
                        isVisible: isJobSelected,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '선호하시는 기업 유형을 선택해주세요',
                              style: TextStyle(fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
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
                                      border: Border.all(color: isSelected ? primaryColor : Colors.transparent),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(item['icon'] as String, style: const TextStyle(fontSize: 24)),
                                        const SizedBox(width: 16),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              item['type'] as String,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? primaryColor : Colors.black87,
                                              ),
                                            ),
                                            Text(
                                              item['desc'] as String,
                                              style: const TextStyle(color: Colors.black54, fontSize: 13),
                                            ),
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
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // 3 페이지
  Widget _buildPage3(Color primaryColor) {
    final isReady = _page3AnimState == 4;
    final isGpaEntered = _gpaController.text.trim().isNotEmpty;
    final isToeicEntered = _isFieldValid(_toeicController, _noToeic);
    final isCertEntered = _isFieldValid(_certController, _noCert);
    final isProjectEntered = _isFieldValid(_projectController, _noProject);
    final isInternEntered = _isFieldValid(_internController, _noIntern);

    return Stack(
      children: [
        if (_page3AnimState == 1 || _page3AnimState == 2)
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (_page3AnimState == 1) _buildConfettiEffect(),
                AnimatedOpacity(
                  opacity: _page3AnimState == 1 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 800),
                  child: const Text(
                    '거의 다 왔어요 👏',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),

        if (_page3AnimState >= 2)
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeInOutCubic,
                  margin: EdgeInsets.only(
                    top: isReady ? 0 : MediaQuery.of(context).size.height * 0.22,
                  ),
                  alignment: isReady ? Alignment.topLeft : Alignment.center,
                  child: AnimatedOpacity(
                    opacity: _page3AnimState >= 3 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 1200),
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: _nameController.text,
                            style: TextStyle(color: primaryColor),
                          ),
                          TextSpan(
                            text: isReady ? '님의 스펙을 알려주세요' : '님의\n스펙을 알려주세요',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                      textAlign: isReady ? TextAlign.left : TextAlign.center,
                      style: TextStyle(
                        fontSize: isReady ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),

                _buildAnimatedSection(
                  isVisible: isReady,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        '순서대로 차근차근 입력해볼까요?',
                        style: TextStyle(fontSize: 15, color: Colors.black54),
                      ),
                      const SizedBox(height: 32),
                      
                      _buildGpaInput(primaryColor),
                      
                      _buildAnimatedSection(
                        isVisible: isGpaEntered,
                        child: _buildOptionalSpecInput(
                          label: '토익 점수',
                          icon: Icons.language,
                          hint: '예: 820',
                          controller: _toeicController,
                          focusNode: _toeicFocus,
                          isChecked: _noToeic,
                          primaryColor: primaryColor,
                          onCheckChanged: (val) {
                            setState(() {
                              _noToeic = val ?? false;
                              if (_noToeic) _toeicController.clear();
                            });
                          }
                        ),
                      ),

                      _buildAnimatedSection(
                        isVisible: isGpaEntered && isToeicEntered,
                        child: _buildOptionalSpecInput(
                          label: '자격증',
                          icon: Icons.workspace_premium,
                          hint: '취득한 자격증 수',
                          controller: _certController,
                          focusNode: _certFocus,
                          isChecked: _noCert,
                          primaryColor: primaryColor,
                          onCheckChanged: (val) {
                            setState(() {
                              _noCert = val ?? false;
                              if (_noCert) _certController.clear();
                            });
                          }
                        ),
                      ),

                      _buildAnimatedSection(
                        isVisible: isGpaEntered && isToeicEntered && isCertEntered,
                        child: _buildOptionalSpecInput(
                          label: '프로젝트 경험',
                          icon: Icons.computer,
                          hint: '진행한 프로젝트 수',
                          controller: _projectController,
                          focusNode: _projectFocus,
                          isChecked: _noProject,
                          primaryColor: primaryColor,
                          onCheckChanged: (val) {
                            setState(() {
                              _noProject = val ?? false;
                              if (_noProject) _projectController.clear();
                            });
                          }
                        ),
                      ),

                      _buildAnimatedSection(
                        isVisible: isGpaEntered && isToeicEntered && isCertEntered && isProjectEntered,
                        child: _buildOptionalSpecInput(
                          label: '인턴 경험',
                          icon: Icons.business_center_outlined,
                          hint: '인턴십 횟수',
                          controller: _internController,
                          focusNode: _internFocus,
                          isChecked: _noIntern,
                          primaryColor: primaryColor,
                          onCheckChanged: (val) {
                            setState(() {
                              _noIntern = val ?? false;
                              if (_noIntern) _internController.clear();
                            });
                          }
                        ),
                      ),

                      _buildAnimatedSection(
                        isVisible: isGpaEntered && isToeicEntered && isCertEntered && isProjectEntered && isInternEntered,
                        child: _buildOptionalSpecInput(
                          label: '수상 경력',
                          icon: Icons.emoji_events_outlined,
                          hint: '수상 횟수',
                          controller: _awardController,
                          focusNode: _awardFocus,
                          isChecked: _noAward,
                          primaryColor: primaryColor,
                          onCheckChanged: (val) {
                            setState(() {
                              _noAward = val ?? false;
                              if (_noAward) _awardController.clear();
                            });
                          }
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildGpaInput(Color primaryColor) {
    final isFocused = _gpaFocus.hasFocus;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isFocused ? primaryColor : Colors.grey[200]!,
          width: isFocused ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school_outlined, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text(
                '평점',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _gpaController,
            focusNode: _gpaFocus,
            style: const TextStyle(color: Colors.black87),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            decoration: InputDecoration(
              hintText: '예: 3.8',
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionalSpecInput({
    required String label,
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    required bool isChecked,
    required Color primaryColor,
    required ValueChanged<bool?> onCheckChanged,
  }) {
    final isFocused = focusNode.hasFocus;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isChecked ? Colors.grey[200]! : (isFocused ? primaryColor : Colors.grey[200]!),
          width: isFocused ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: isChecked ? Colors.grey[400] : Colors.grey[700]),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isChecked ? Colors.grey[400] : Colors.black87,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => onCheckChanged(!isChecked),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isChecked ? primaryColor.withOpacity(0.1) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isChecked ? primaryColor.withOpacity(0.3) : Colors.transparent,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check, size: 14, color: isChecked ? primaryColor : Colors.grey[500]),
                      const SizedBox(width: 4),
                      Text(
                        '없음',
                        style: TextStyle(
                          color: isChecked ? primaryColor : Colors.grey[600],
                          fontSize: 13,
                          fontWeight: isChecked ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(color: Colors.black87),
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: !isChecked,
            decoration: InputDecoration(
              hintText: isChecked ? '해당 없음' : hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: isChecked ? Colors.grey[100] : Colors.grey[50],
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }

  // 4 페이지
  Widget _buildPage4(Color primaryColor) {
    final isReady = _page4AnimState == 4;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOutCubic,
                margin: EdgeInsets.only(
                  top: isReady ? 0 : MediaQuery.of(context).size.height * 0.22,
                ),
                alignment: isReady ? Alignment.topLeft : Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (_page4AnimState == 1) _buildConfettiEffect(),
                    
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeInOutCubic,
                      style: TextStyle(
                        fontSize: isReady ? 28 : 38,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      child: const Text('모두 완료됐어요 🎉'),
                    ),
                  ],
                ),
              ),

              _buildAnimatedSection(
                isVisible: isReady,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Text(
                      '입력하신 정보를 확인해주세요',
                      style: TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          _buildSummaryRow('이름', _nameController.text.isEmpty ? '-' : _nameController.text),
                          _buildSummaryRow('학년', _selectedGrade != null ? '$_selectedGrade학년' : '-'),
                          _buildSummaryRow('희망 직무', _selectedJob ?? '-'),
                          _buildSummaryRow('선호 기업', _selectedCompanyType ?? '-'),
                          Divider(height: 32, color: Colors.grey[300]),
                          
                          _buildSummaryRow('학점', '${_gpaController.text} / 4.5'),
                          _buildSummaryRow('토익', _noToeic ? '없음' : '${_toeicController.text}점'),
                          _buildSummaryRow('자격증', _noCert ? '없음' : '${_certController.text}개'),
                          _buildSummaryRow('프로젝트', _noProject ? '없음' : '${_projectController.text}개'),
                          _buildSummaryRow('인턴', _noIntern ? '없음' : '${_internController.text}회'),
                          _buildSummaryRow('수상', _noAward ? '없음' : '${_awardController.text}회'),
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54, fontSize: 14)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        ],
      ),
    );
  }
}