import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/profile_provider.dart';
import '../../home/providers/home_provider.dart';
import '../../../shared/widgets/tech_stack_selector.dart';
import 'ai_chat_screen.dart';

class AiScreen extends ConsumerStatefulWidget {
  const AiScreen({super.key});

  @override
  ConsumerState<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends ConsumerState<AiScreen> {
  Map<String, dynamic> _tempSpec = {};
  bool _tempSpecSet = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        titleSpacing: 20.0,
        centerTitle: false,
        title: const Text('AI 스펙진단', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24)),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('스펙 정보를 불러오지 못했어요 😢', style: TextStyle(color: Colors.black54))),
        data: (profile) {
          final dbSpec = profile['spec'] ?? {};

          // 처음 프로필 로드 시 _tempSpec 초기화 (한 번만)
          if (!_tempSpecSet) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              setState(() {
                _tempSpec = Map<String, dynamic>.from(dbSpec);
                _tempSpecSet = true;
              });
            });
          }

          final spec = _tempSpec.isNotEmpty ? _tempSpec : dbSpec;
          final String userName = profile['name'] ?? profile['user_name'] ?? '사용자';

          final double gpa = (spec['gpa'] as num?)?.toDouble() ?? 0.0;
          final int toeic = (spec['toeicScore'] ?? spec['toeic_score'] as num?)?.toInt() ?? 0;
          final int certificate = (spec['certificateCount'] ?? spec['certificate_count'] as num?)?.toInt() ?? 0;
          final int internship = (spec['internshipCount'] ?? spec['internship_count'] as num?)?.toInt() ?? 0;

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('$userName님의 스펙을 AI와 함께 분석할 수 있어요', style: const TextStyle(color: Colors.black54, fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),

                // 현재 스펙 영역
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('나의 스펙', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          GestureDetector(
                            onTap: () => _showEditSpecDialog(context, spec, primaryColor),
                            child: Text(
                              '스펙 수정', 
                              style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14)
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 실시간 온보딩/수정 데이터 바인딩 그리드
                      Row(
                        children: [
                          Expanded(child: _buildSpecItem('🎓', '학점', '$gpa/4.5', gpa < 3.0)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSpecItem('🌐', '어학 성적', toeic > 0 ? 'TOEIC $toeic' : '기록 없음', toeic == 0)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(child: _buildSpecItem('📜', '자격증', '$certificate개 보유', false)),
                          const SizedBox(width: 12),
                          Expanded(child: _buildSpecItem('💼', '인턴십', internship > 0 ? '$internship회 경험' : '경험 없음', internship == 0)),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 챗봇 진입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => AiChatScreen(
                          tempSpec: _tempSpec.isNotEmpty ? _tempSpec : Map<String, dynamic>.from(dbSpec),
                        )),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: const Text('AI와 스펙 진단하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // 스펙 수정 모달 바텀 시트 (세션 중에만 적용 — DB 저장 없음)
  void _showEditSpecDialog(BuildContext context, Map<String, dynamic> currentSpec, Color primaryColor) {
    final gpaCtrl = TextEditingController(text: currentSpec['gpa']?.toString() ?? '');
    final toeicCtrl = TextEditingController(text: (currentSpec['toeicScore'] ?? currentSpec['toeic_score'])?.toString() ?? '');
    final certCtrl = TextEditingController(text: (currentSpec['certificateCount'] ?? currentSpec['certificate_count'])?.toString() ?? '');
    final internCtrl = TextEditingController(text: (currentSpec['internshipCount'] ?? currentSpec['internship_count'])?.toString() ?? '');
    final currentTechStack = (currentSpec['techStack'] ?? currentSpec['tech_stack'] ?? '').toString();
    List<String> selectedTechStacks = currentTechStack.isEmpty
        ? []
        : currentTechStack.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.85,
              maxChildSize: 0.95,
              minChildSize: 0.5,
              expand: false,
              builder: (context, scrollController) {
                return Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(24, 16, 8, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('내 스펙 수정하기', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.black54),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.only(
                          left: 24, right: 24, top: 20,
                          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildEditField('학점 (GPA)', gpaCtrl, TextInputType.number),
                            _buildEditField('토익 점수', toeicCtrl, TextInputType.number),
                            _buildEditField('자격증 개수', certCtrl, TextInputType.number),
                            _buildEditField('인턴십 경험 횟수', internCtrl, TextInputType.number),
                            const SizedBox(height: 8),
                            TechStackSelector(
                              selected: selectedTechStacks,
                              onChanged: (list) => setModalState(() => selectedTechStacks = list),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity, height: 56,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  // DB 저장 없이 로컬 상태(_tempSpec)만 업데이트
                                  setState(() {
                                    _tempSpec = {
                                      ..._tempSpec,
                                      'gpa': double.tryParse(gpaCtrl.text) ?? currentSpec['gpa'] ?? 0.0,
                                      'toeicScore': int.tryParse(toeicCtrl.text) ?? currentSpec['toeicScore'] ?? 0,
                                      'certificateCount': int.tryParse(certCtrl.text) ?? currentSpec['certificateCount'] ?? 0,
                                      'internshipCount': int.tryParse(internCtrl.text) ?? currentSpec['internshipCount'] ?? 0,
                                      'techStack': selectedTechStacks.join(', '),
                                    };
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('스펙이 이 세션에만 임시 적용됩니다.')),
                                  );
                                },
                                child: const Text('적용하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEditField(String label, TextEditingController controller, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          filled: true, fillColor: Colors.grey[50],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSpecItem(String icon, String title, String value, bool isWarning) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isWarning ? const Color(0xFFFFF0F0) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isWarning ? Colors.red[200]! : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(title, style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.redAccent : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
