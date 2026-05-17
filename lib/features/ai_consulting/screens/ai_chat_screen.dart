import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/network/api_client.dart';
import '../repositories/ai_repository.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _primaryColor = const Color(0xFF3CC8A1);
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();
  late final AiRepository _repo;

  // 채팅 메시지 목록
  final List<_ChatMessage> _messages = [];

  // 현재 활성 탭 (0=스펙분석, 1=갭분석, 2=시뮬레이션)
  int _activeTab = 0;

  // 로딩 상태
  bool _isLoading = false;

  // 결과 데이터
  Map<String, dynamic>? _analysisResult;   // 스펙 분석 결과
  Map<String, dynamic>? _gapResult;        // 갭 분석 결과
  Map<String, dynamic>? _simulateResult;   // 시뮬레이션 결과

  // 시뮬레이션용 슬라이더 값
  double _simGpa = 3.8;
  double _simToeic = 820;
  int _simInternship = 0;
  int _simContest = 0;

  @override
  void initState() {
    super.initState();
    _repo = AiRepository(ApiClient());
    _addBotMessage('반가워요! 입력하신 스펙을 바탕으로 진단을 시작할까요? 목표하시는 기업군이 있나요?');
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() => _messages.add(_ChatMessage(text: text, isUser: false)));
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() => _messages.add(_ChatMessage(text: text, isUser: true)));
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── 탭 버튼 클릭 ──────────────────────────────────────────────────────────

  Future<void> _onTabTap(int tab) async {
    setState(() => _activeTab = tab);

    if (tab == 0) await _runSpecAnalysis();
    if (tab == 1) await _runGapAnalysis();
    if (tab == 2) await _showSimulation();
  }

  // ── 스펙 분석 (SSE) ───────────────────────────────────────────────────────

  Future<void> _runSpecAnalysis() async {
    _addUserMessage('스펙 분석');
    setState(() => _isLoading = true);

    String botText = '';
    Map<String, dynamic>? cardData;

    try {
      await for (final event in _repo.analyzeSpec('현재 스펙을 분석해줘')) {
        final type = event['type'] as String?;
        if (type == 'text') {
          botText += (event['content'] as String? ?? '');
          setState(() {});
        } else if (type == 'result_card') {
          cardData = event['data'] as Map<String, dynamic>?;
        }
      }
    } catch (_) {
      // 백엔드 미연결 시 더미 데이터
      botText = '현재 스펙을 분석한 결과입니다.';
      cardData = {
        'radar': {'학점': 85, '어학': 82, '자격증': 70, '인턴': 0, '공모전': 40, '프로젝트': 75},
        'strengths': ['학점이 우수합니다 (3.8/4.5)', '정보처리기사 자격증을 보유하고 있습니다', '프로젝트 경험이 양호합니다'],
        'weaknesses': ['인턴 경험이 부족합니다 - 가장 시급히 보완이 필요합니다', '토익 점수를 850점 이상으로 올리는 것을 권장합니다', '공모전이나 해커톤 참여로 실전 경험을 쌓아보세요'],
      };
    }

    setState(() {
      _isLoading = false;
      _analysisResult = cardData;
    });
    if (botText.isNotEmpty) _addBotMessage(botText);
  }

  // ── 갭 분석 ───────────────────────────────────────────────────────────────

  Future<void> _runGapAnalysis() async {
    _addUserMessage('갭 분석');
    setState(() => _isLoading = true);

    try {
      final res = await _repo.getGapAnalysis();
      setState(() {
        _isLoading = false;
        _gapResult = res['data'] ?? res;
      });
      _addBotMessage('목표 기업과의 갭 분석 결과입니다.');
    } catch (_) {
      // 더미
      setState(() {
        _isLoading = false;
        _gapResult = {
          'predictions': [
            {'company_name': '카카오', 'predicted_rate': 47},
            {'company_name': '네이버', 'predicted_rate': 61},
          ],
          'gap_items': [
            {'label': '학점', 'mine': 0.84, 'avg': 0.90},
            {'label': '어학', 'mine': 0.82, 'avg': 0.88},
            {'label': '자격증', 'mine': 0.70, 'avg': 0.72},
            {'label': '인턴', 'mine': 0.0, 'avg': 0.65},
            {'label': '공모전', 'mine': 0.40, 'avg': 0.55},
          ],
        };
      });
      _addBotMessage('목표 기업과의 갭 분석 결과입니다.');
    }
  }

  // ── 시뮬레이션 ────────────────────────────────────────────────────────────

  Future<void> _showSimulation() async {
    _addUserMessage('시뮬레이션');
    setState(() { _simulateResult = null; });
    _addBotMessage('스펙을 조정하여 합격률 변화를 확인해보세요!');
  }

  Future<void> _runSimulate() async {
    setState(() => _isLoading = true);
    try {
      final res = await _repo.simulate(
        companyId: 1,
        specChanges: {
          'gpa': _simGpa,
          'toeic_score': _simToeic.round(),
          'internship_count': _simInternship,
          'contest_count': _simContest,
        },
      );
      setState(() {
        _isLoading = false;
        _simulateResult = res['data'] ?? res;
      });
      _addBotMessage('시뮬레이션 결과입니다.');
    } catch (_) {
      setState(() {
        _isLoading = false;
        _simulateResult = {
          'kakao': 95,
          'naver': 95,
          'message': '인턴 $_simInternship회 추가로 카카오 합격률이 상승했어요!',
        };
      });
      _addBotMessage('시뮬레이션 결과입니다.');
    }
  }

  // ── 텍스트 전송 ───────────────────────────────────────────────────────────

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    _addUserMessage(text);
    setState(() => _isLoading = true);

    String reply = '';
    try {
      await for (final event in _repo.analyzeSpec(text)) {
        if (event['type'] == 'text') reply += (event['content'] ?? '');
      }
    } catch (_) {
      reply = '죄송해요, 잠시 후 다시 시도해주세요.';
    }

    setState(() => _isLoading = false);
    _addBotMessage(reply.isEmpty ? '네, 알겠습니다!' : reply);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI 스펙 상담', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
            Text('궁금한 점을 물어보세요', style: TextStyle(color: Colors.black54, fontSize: 12)),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── 채팅 + 결과 카드 영역 ──
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ..._messages.map(_buildChatBubble),
                if (_isLoading) _buildTypingIndicator(),
                if (_activeTab == 0 && _analysisResult != null) _buildSpecAnalysisCard(),
                if (_activeTab == 1 && _gapResult != null) _buildGapCard(),
                if (_activeTab == 2) _buildSimulationCard(),
                const SizedBox(height: 12),
              ],
            ),
          ),

          // ── 하단 탭 + 입력창 ──
          _buildBottomBar(),
        ],
      ),
    );
  }

  // ── 채팅 버블 ─────────────────────────────────────────────────────────────

  Widget _buildChatBubble(_ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(backgroundColor: _primaryColor, radius: 16, child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? _primaryColor : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)],
              ),
              child: Text(msg.text, style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Row(
      children: [
        CircleAvatar(backgroundColor: _primaryColor, radius: 16, child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: const SizedBox(width: 40, height: 14, child: _DotsIndicator()),
        ),
      ],
    );
  }

  // ── 스펙 분석 카드 ────────────────────────────────────────────────────────

  Widget _buildSpecAnalysisCard() {
    final data = _analysisResult!;
    final radar = (data['radar'] as Map?)?.cast<String, dynamic>() ?? {};
    final strengths = (data['strengths'] as List?)?.cast<String>() ?? [];
    final weaknesses = (data['weaknesses'] as List?)?.cast<String>() ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('스펙 분석 차트', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          if (radar.isNotEmpty) SizedBox(height: 220, child: _buildRadarChart(radar)),
          const SizedBox(height: 16),
          _buildResultSection('강점', strengths, isStrength: true),
          const SizedBox(height: 12),
          _buildResultSection('보완이 필요한 점', weaknesses, isStrength: false),
        ],
      ),
    );
  }

  Widget _buildRadarChart(Map<String, dynamic> radar) {
    final labels = radar.keys.toList();
    final values = radar.values.map((v) => (v as num).toDouble()).toList();
    final maxVal = 100.0;

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 4,
        ticksTextStyle: const TextStyle(fontSize: 0),
        gridBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
        radarBorderData: BorderSide(color: Colors.grey[300]!, width: 1),
        titleTextStyle: const TextStyle(color: Colors.black54, fontSize: 12),
        titlePositionPercentageOffset: 0.2,
        getTitle: (index, angle) => RadarChartTitle(text: labels[index]),
        dataSets: [
          RadarDataSet(
            fillColor: const Color(0xFF3CC8A1).withOpacity(0.3),
            borderColor: const Color(0xFF3CC8A1),
            borderWidth: 2,
            entryRadius: 3,
            dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultSection(String title, List<String> items, {required bool isStrength}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isStrength ? const Color(0xFFF0FFF8) : const Color(0xFFFFFBF0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(isStrength ? Icons.trending_up : Icons.info_outline,
                color: isStrength ? _primaryColor : Colors.orange, size: 18),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isStrength ? _primaryColor : Colors.orange)),
          ]),
          const SizedBox(height: 8),
          ...items.map((s) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(isStrength ? Icons.check : Icons.priority_high,
                  size: 14, color: isStrength ? _primaryColor : Colors.orange),
              const SizedBox(width: 6),
              Flexible(child: Text(s, style: const TextStyle(fontSize: 13, color: Colors.black87))),
            ]),
          )),
        ],
      ),
    );
  }

  // ── 갭 분석 카드 ──────────────────────────────────────────────────────────

  Widget _buildGapCard() {
    final data = _gapResult!;
    final predictions = (data['predictions'] as List?)?.cast<Map>() ?? [];
    final gapItems = (data['gap_items'] as List?)?.cast<Map>() ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('합격 예측 분석', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          // 합격률 카드들
          Row(children: predictions.map((p) => Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                Text(p['company_name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${p['predicted_rate']}%',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _primaryColor)),
              ]),
            ),
          )).toList()),
          const SizedBox(height: 16),
          const Row(children: [
            Icon(Icons.bolt, color: Colors.orange, size: 18),
            SizedBox(width: 4),
            Text('합격자 평균과의 갭 분석', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 12),
          ...gapItems.map((item) => _buildGapBar(
            label: item['label']?.toString() ?? '',
            mine: (item['mine'] as num?)?.toDouble() ?? 0,
            avg: (item['avg'] as num?)?.toDouble() ?? 0,
          )),
          const SizedBox(height: 8),
          Row(children: [
            _legendDot(Colors.grey[400]!, '내 스펙'),
            const SizedBox(width: 12),
            _legendDot(_primaryColor, '합격자 평균'),
          ]),
        ],
      ),
    );
  }

  Widget _buildGapBar({required String label, required double mine, required double avg}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
        const SizedBox(height: 4),
        Stack(children: [
          // 합격자 평균
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: avg, minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
          // 내 스펙
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: mine, minHeight: 10,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(children: [
      Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ]);
  }

  // ── 시뮬레이션 카드 ───────────────────────────────────────────────────────

  Widget _buildSimulationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.tune, size: 18),
            const SizedBox(width: 6),
            const Text('스펙 시뮬레이션', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ]),
          const SizedBox(height: 16),
          _buildSlider('학점', _simGpa, 0, 4.5, (v) => setState(() => _simGpa = v), decimals: 1),
          _buildSlider('어학', _simToeic, 0, 990, (v) => setState(() => _simToeic = v)),
          _buildCounter('자격증', '정보처리기사'),
          _buildStepper('인턴십', _simInternship, (v) => setState(() => _simInternship = v)),
          _buildStepper('공모전', _simContest, (v) => setState(() => _simContest = v)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _runSimulate,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('이 스펙으로 시뮬레이션하기', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
          ),
          if (_simulateResult != null) ...[
            const SizedBox(height: 16),
            const Text('시뮬레이션 결과', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: _buildResultRateCard('카카오', _simulateResult!['kakao'] ?? 0)),
              const SizedBox(width: 12),
              Expanded(child: _buildResultRateCard('네이버', _simulateResult!['naver'] ?? 0)),
            ]),
            if (_simulateResult!['message'] != null) ...[
              const SizedBox(height: 10),
              Text(_simulateResult!['message'], style: TextStyle(fontSize: 13, color: Colors.grey[600])),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildSlider(String label, double value, double min, double max, ValueChanged<double> onChanged, {int decimals = 0}) {
    final display = decimals > 0 ? value.toStringAsFixed(decimals) : value.round().toString();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        Text(display, style: TextStyle(fontWeight: FontWeight.bold, color: _primaryColor, fontSize: 18)),
      ]),
      SliderTheme(
        data: SliderThemeData(activeTrackColor: _primaryColor, thumbColor: _primaryColor, inactiveTrackColor: Colors.grey[200]),
        child: Slider(value: value, min: min, max: max, onChanged: onChanged),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [Text('$min', style: _smallGrey), Text('$max', style: _smallGrey)]),
      const SizedBox(height: 12),
    ]);
  }

  Widget _buildCounter(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildStepper(String label, int value, ValueChanged<int> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
        Row(children: [
          _stepBtn(Icons.remove, () { if (value > 0) onChanged(value - 1); }),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('$value회', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
          _stepBtn(Icons.add, () => onChanged(value + 1)),
        ]),
      ]),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32, height: 32,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, size: 16),
      ),
    );
  }

  Widget _buildResultRateCard(String company, dynamic rate) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(14)),
      child: Column(children: [
        Text(company, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('$rate%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: _primaryColor)),
      ]),
    );
  }

  // ── 하단 탭 + 입력창 ──────────────────────────────────────────────────────

  Widget _buildBottomBar() {
    final tabs = ['스펙 분석', '갭 분석', '시뮬레이션'];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: List.generate(tabs.length, (i) {
          final selected = _activeTab == i;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => _onTabTap(i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _primaryColor : Colors.grey[100],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(tabs[i],
                    style: TextStyle(color: selected ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
          );
        })),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(24)),
              child: TextField(
                controller: _msgController,
                decoration: const InputDecoration(
                  hintText: '메시지를 입력하세요...',
                  hintStyle: TextStyle(color: Colors.black38, fontSize: 14),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _sendMessage,
            child: CircleAvatar(backgroundColor: _primaryColor, radius: 22,
                child: const Icon(Icons.send, color: Colors.white, size: 18)),
          ),
        ]),
      ]),
    );
  }

  static const _smallGrey = TextStyle(fontSize: 11, color: Colors.black38);
}

// ── 데이터 모델 ───────────────────────────────────────────────────────────────

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}

// ── 점 로딩 애니메이션 ────────────────────────────────────────────────────────

class _DotsIndicator extends StatefulWidget {
  const _DotsIndicator();
  @override
  State<_DotsIndicator> createState() => _DotsIndicatorState();
}

class _DotsIndicatorState extends State<_DotsIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _anim = Tween<double>(begin: 0, end: 1).animate(_ctrl);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final phase = ((_anim.value * 3) - i).clamp(0.0, 1.0);
            final opacity = (phase < 0.5 ? phase : 1 - phase) * 2;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 6, height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(opacity.clamp(0.2, 1.0)),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}