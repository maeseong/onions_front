import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../repositories/ai_repository.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/foundation.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic> tempSpec;
  const AiChatScreen({super.key, required this.tempSpec});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _primaryColor = const Color(0xFF3CC8A1);
  final _msgController = TextEditingController();
  final _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [];
  int _activeTab = 0;
  bool _isLoading = false;

  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? _gapResult;
  Map<String, dynamic>? _simulateResult;

  bool _gapAdviceExpanded = false;

  double _simGpa = 0.0;
  double _simToeic = 0;
  int _simInternship = 0;
  int _simContest = 0;

  String? _simulationCompany;
  int _simCert = 0;
  int _simProject = 0;
  // bool _waitingForCompany = false;
  // int _pendingTab = -1;

  @override
  void initState() {
    super.initState();
    final spec = widget.tempSpec;
    _simGpa = (spec['gpa'] as num?)?.toDouble() ?? 0.0;
    _simToeic = ((spec['toeicScore'] ?? spec['toeic_score']) as num?)?.toDouble() ?? 0;
    _simCert = ((spec['certificateCount'] ?? spec['certificate_count']) as num?)?.toInt() ?? 0;
    _simProject = ((spec['projectCount'] ?? spec['project_count']) as num?)?.toInt() ?? 0;
    _simInternship = ((spec['internshipCount'] ?? spec['internship_count']) as num?)?.toInt() ?? 0;
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

  Future<void> _onTabTap(int tab) async {
    if (_isLoading) return;
    setState(() => _activeTab = tab);
    if (tab == 0) await _runSpecAnalysis();
    if (tab == 1) await _runGapAnalysis();
    if (tab == 2) await _showSimulation();
  }

  // 1. 스펙 분석
  Future<void> _runSpecAnalysis() async {
    final isRerun = _messages.any((m) => m.cardType == _CardType.specAnalysis);
    if (!isRerun) _addUserMessage('스펙 분석');
    setState(() {
      _isLoading = true;
      _analysisResult = null;
    });

    String botText = '';

    try {
      final spec = widget.tempSpec;
      final specText = spec.isEmpty ? '' :
          ' (분석 기준 스펙 - 학점 ${spec['gpa']}, 토익 ${spec['toeicScore'] ?? spec['toeic_score']}, '
          '자격증 ${spec['certificateCount'] ?? spec['certificate_count']}개, '
          '인턴 ${spec['internshipCount'] ?? spec['internship_count']}회, '
          '기술스택 ${(spec['techStack'] ?? spec['tech_stack'] ?? '').toString().isNotEmpty ? spec['techStack'] ?? spec['tech_stack'] : '없음'})';

      await for (final event in ref.read(aiRepositoryProvider).analyzeSpec('현재 스펙을 분석해줘$specText')) {
        final type = event['type'] as String?;
        if (type == 'text') {
          botText += (event['content'] as String? ?? '');
          setState(() {});
        }
      }

      // tempSpec으로 레이더 데이터 구성
      final double gpa = (spec['gpa'] as num?)?.toDouble() ?? 0.0;
      final double toeic = ((spec['toeicScore'] ?? spec['toeic_score']) as num?)?.toDouble() ?? 0;
      final int cert = ((spec['certificateCount'] ?? spec['certificate_count']) as num?)?.toInt() ?? 0;
      final int intern = ((spec['internshipCount'] ?? spec['internship_count']) as num?)?.toInt() ?? 0;
      final int project = ((spec['projectCount'] ?? spec['project_count']) as num?)?.toInt() ?? 0;

      final radar = {
        '학점': (gpa / 4.5 * 100).clamp(0, 100).toDouble(),
        '어학': (toeic / 990 * 100).clamp(0, 100).toDouble(),
        '자격증': (cert / 5 * 100).clamp(0, 100).toDouble(),
        '인턴': (intern / 3 * 100).clamp(0, 100).toDouble(),
        '프로젝트': (project / 5 * 100).clamp(0, 100).toDouble(),
      };

      // AI 텍스트에서 강점 / 보완 / 조언 섹션 파싱
      final strengths = _parseSection(botText, ['✅ 강점', '강점']);
      final weaknesses = _parseSection(botText, ['⚠️ 보완 필요', '보완 필요', '약점']);
      final advice = _parseSection(botText, ['🎯 핵심 조언', '핵심 조언', '조언']);

      final alreadyHasCard = _messages.any((m) => m.cardType == _CardType.specAnalysis);
      setState(() {
        _isLoading = false;
        _analysisResult = {
          'radar': radar,
          'strengths': strengths,
          'weaknesses': [...weaknesses, ...advice],
        };
        if (!alreadyHasCard) {
          _messages.add(_ChatMessage(text: '', isUser: false, cardType: _CardType.specAnalysis));
        }
      });

    } catch (e) {
      setState(() => _isLoading = false);
      _addBotMessage('스펙 분석 중 통신 오류가 발생했어요. 백엔드 서버 상태를 확인한 후 다시 시도해 주세요.\n(에러: $e)');
    }
  }

  // 마크다운 섹션에서 bullet 항목 추출
  List<String> _parseSection(String text, List<String> headings) {
    for (final heading in headings) {
      final pattern = RegExp('(?:###?\\s*)?(?:[^\\w]*)$heading[^\\n]*\\n((?:[-•*]\\s*.+\\n?)+)', multiLine: true);
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(1)!
            .split('\n')
            .map((l) => l.replaceAll(RegExp(r'^[-•*]\s*'), '').trim())
            .map((l) => l.replaceAll('**', ''))  // ** 마크다운 제거
            .where((l) => l.isNotEmpty)
            .toList();
      }
    }
    return [];
  }

  Future<String?> _askCompanyName() async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('목표 기업 입력'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: '기업명을 입력하세요 (예: 삼성전자)',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(context, v),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  // 2. 갭 분석
  Future<void> _runGapAnalysis() async {
    final companyName = await _askCompanyName();
    if (companyName == null || companyName.isEmpty) return;

    final isRerun = _messages.any((m) => m.cardType == _CardType.gap);
    if (!isRerun) _addUserMessage('갭 분석 - $companyName');
    setState(() {
      _isLoading = true;
      _gapResult = null;
    });

    try {
      final res = await ref.read(aiRepositoryProvider).gapAnalysis(companyName: companyName);
      final alreadyHasCard = _messages.any((m) => m.cardType == _CardType.gap);
      setState(() {
        _isLoading = false;
        _gapResult = res;
        _gapAdviceExpanded = false;
        if (!alreadyHasCard) {
          _messages.add(_ChatMessage(text: '$companyName 기업과의 갭 분석 결과예요!', isUser: false));
          _messages.add(_ChatMessage(text: '', isUser: false, cardType: _CardType.gap));
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _addBotMessage('갭 분석 중 오류가 발생했어요.\n(에러: $e)');
    }
  }

  Future<void> _showSimulation() async {
    final companyName = await _askCompanyName();
    if (companyName == null || companyName.isEmpty) return;

    _addUserMessage('시뮬레이션 - $companyName');
    setState(() {
      _simulateResult = null;
      _simulationCompany = companyName;
    });
    _addBotMessage('$companyName 기업 기준으로 스펙을 조정하여 합격률 변화를 확인해보세요!');
  }

  Future<void> _runSimulate() async {
    setState(() {
      _isLoading = true;
      _simulateResult = null;
    });
    String botText = '';
    try {
      await for (final event in ref.read(aiRepositoryProvider).simulateStream(
        specChanges: {
          'gpa': _simGpa,
          'toeic_score': _simToeic.round(),
          'internship_count': _simInternship,
          'certificate_count': _simCert,
          'project_count': _simProject,
        },
        companyName: _simulationCompany,
      )) {
        final content = event['content'] ?? event['text'] ?? '';
        if (content.isNotEmpty && content != '[DONE]') {
          botText += content;
        }
      }

      // AI 텍스트에서 합격 가능성 퍼센트 파싱
      final matches = RegExp(r'(\d+)%').allMatches(botText).toList();
      final before = matches.isNotEmpty ? int.tryParse(matches[0].group(1)!) ?? 0 : 0;
      final after = matches.length > 1 ? int.tryParse(matches[1].group(1)!) ?? 0 : 0;

      setState(() {
        _isLoading = false;
        _simulateResult = {
          'before': before,
          'after': after,
          'botText': botText,
          'gpa': _simGpa,
          'toeic': _simToeic,
          'cert': _simCert,
          'project': _simProject,
          'intern': _simInternship,
        };
        _messages.add(_ChatMessage(text: '', isUser: false, cardType: _CardType.simulation));
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _addBotMessage('시뮬레이션 실행에 실패했어요.\n(에러: $e)');
    }
  }

  // 4. 일반 텍스트 전송
  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    _addUserMessage(text);
    setState(() => _isLoading = true);

    String reply = '';
    try {
      await for (final event in ref.read(aiRepositoryProvider).chat(text)) {
        final content = event['content'] ?? event['text'] ?? '';
        if (content.isNotEmpty && content != '[DONE]') reply += content;
      }
      setState(() => _isLoading = false);
      _addBotMessage(reply.isEmpty ? '죄송해요, 다시 시도해주세요.' : reply);
    } catch (e) {
      setState(() => _isLoading = false);
      _addBotMessage('메시지 전송에 실패했어요. 잠시 후 다시 시도해 주세요.');
    }
  }

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
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                ..._messages.map(_buildChatBubble),
                if (_isLoading) _buildTypingIndicator(),
                if (_activeTab == 2 && _simulationCompany != null && _simulateResult == null) _buildSimulationCard(),
                const SizedBox(height: 12),
              ],
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(_ChatMessage msg) {
    // 카드 타입 메시지는 해당 카드 위젯으로 렌더링
    if (msg.cardType == _CardType.specAnalysis && _analysisResult != null) {
      return _buildSpecAnalysisCard();
    }
    if (msg.cardType == _CardType.gap && _gapResult != null) {
      return _buildGapCard();
    }
    if (msg.cardType == _CardType.simulation && _simulateResult != null) {
      return _buildSimulationResultCard();
    }

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
              child: isUser
              ? Text(msg.text, style: const TextStyle(color: Colors.white, fontSize: 14))
              : MarkdownBody(
                data: msg.text,
                softLineBreak: true,  // 추가
                styleSheet: MarkdownStyleSheet(
                  p: const TextStyle(color: Colors.black87, fontSize: 14),
                  h2: const TextStyle(color: Colors.black87, fontSize: 16, fontWeight: FontWeight.bold),
                  h3: const TextStyle(color: Colors.black87, fontSize: 14, fontWeight: FontWeight.bold),
                  listBullet: const TextStyle(color: Colors.black87, fontSize: 14),
                ),
              ),
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
          if (strengths.isNotEmpty) _buildResultSection('강점', strengths, isStrength: true),
          if (strengths.isNotEmpty && weaknesses.isNotEmpty) const SizedBox(height: 12),
          if (weaknesses.isNotEmpty) _buildResultSection('보완이 필요한 점', weaknesses, isStrength: false),
        ],
      ),
    );
  }

  Widget _buildRadarChart(Map<String, dynamic> radar) {
    final labels = radar.keys.toList();
    final values = radar.values.map((v) => (v as num).toDouble()).toList();

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 4,
        ticksTextStyle: const TextStyle(fontSize: 0),
        gridBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
        tickBorderData: BorderSide(color: Colors.grey[200]!, width: 1),
        radarBorderData: const BorderSide(color: Colors.transparent, width: 0),
        borderData: FlBorderData(show: false),
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
    final color = isStrength ? _primaryColor : Colors.orange;
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
            Icon(isStrength ? Icons.trending_up : Icons.info_outline, color: color, size: 18),
            const SizedBox(width: 6),
            Text(title, style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: color, letterSpacing: 0.3)),
          ]),
          const SizedBox(height: 10),
          ...items.map((s) {
            // "항목명: 설명" 형태면 항목명을 굵게 분리
            final colonIdx = s.indexOf(':');
            final hasColon = colonIdx > 0 && colonIdx < s.length - 1;
            final label = hasColon ? s.substring(0, colonIdx).trim() : null;
            final desc  = hasColon ? s.substring(colonIdx + 1).trim() : s;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Icon(isStrength ? Icons.check_circle_outline : Icons.error_outline,
                      size: 15, color: color),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                      children: [
                        if (label != null) ...[
                          TextSpan(text: '$label  ', style: TextStyle(fontWeight: FontWeight.w700, color: color)),
                        ],
                        TextSpan(text: desc),
                      ],
                    ),
                  ),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGapCard() {
    final data = _gapResult!;
    final items = (data['items'] as List?)?.map((e) => Map<String, dynamic>.from(e as Map)).toList() ?? [];
    final advice = data['advice'] is String 
      ? data['advice'] as String 
      : (data['advice'] as List?)?.join(', ') ?? '';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('📊 갭 분석 결과', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 16),
          ...items.map((item) {
            final mine = (item['mine'] as num?)?.toDouble() ?? 0;
            final avg = (item['avg'] as num?)?.toDouble() ?? 0;
            final label = item['label'] as String? ?? '';
            final unit = item['unit'] as String? ?? '';
            final maxVal = [mine, avg].reduce((a, b) => a > b ? a : b) * 1.2;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const SizedBox(width: 4),
                    const Text('나', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: maxVal > 0 ? mine / maxVal : 0,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$mine$unit', style: TextStyle(fontSize: 12, color: _primaryColor, fontWeight: FontWeight.bold)),
                  ]),
                  const SizedBox(height: 4),
                  Row(children: [
                    const SizedBox(width: 4),
                    const Text('평균', style: TextStyle(fontSize: 12, color: Colors.black54)),
                    const SizedBox(width: 4),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: maxVal > 0 ? avg / maxVal : 0,
                          minHeight: 12,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text('$avg$unit', style: const TextStyle(fontSize: 12, color: Colors.orange, fontWeight: FontWeight.bold)),
                  ]),
                ],
              ),
            );
          }),
          if (advice.isNotEmpty) ...[
            const Divider(),
            const SizedBox(height: 10),
            const Text('💡 핵심 조언', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
            const SizedBox(height: 8),
            ...() {
              final allLines = advice.split('\n')
                  .map((l) => l.trim())
                  .map((l) => l.replaceAll(RegExp(r'^[①②③④⑤]\s*[-]?\s*'), '').trim())
                  .map((l) => l.replaceAll(RegExp(r'^[-•]\s*'), '').trim())
                  .where((l) => l.isNotEmpty)
                  .toList();

              // 앞 3줄은 핵심 조언, 나머지는 더보기
              final coreLines = allLines.take(3).toList();
              final extraLines = allLines.skip(3).toList();

              Widget buildLine(String line) {
                final colonIdx = line.indexOf(':');
                final hasColon = colonIdx > 0;
                final label = hasColon ? line.substring(0, colonIdx).trim() : null;
                final desc  = hasColon ? line.substring(colonIdx + 1).trim() : line;

                // 설명 없이 레이블만 있으면 소제목으로 렌더링
                if (label != null && desc.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.amber[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Icon(Icons.lightbulb_outline, size: 15, color: Colors.amber[700]),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.5),
                            children: [
                              if (label != null)
                                TextSpan(text: '$label  ', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.amber[800])),
                              TextSpan(text: desc),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return [
                ...coreLines.map(buildLine),
                if (extraLines.isNotEmpty) ...[
                  GestureDetector(
                    onTap: () => setState(() => _gapAdviceExpanded = !_gapAdviceExpanded),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2, bottom: 6),
                      child: Row(children: [
                        Text(
                          _gapAdviceExpanded ? '접기' : '더보기 (${extraLines.length}개)',
                          style: TextStyle(fontSize: 12, color: _primaryColor, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 4),
                        Icon(_gapAdviceExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                            size: 16, color: _primaryColor),
                      ]),
                    ),
                  ),
                  if (_gapAdviceExpanded) ...extraLines.map(buildLine),
                ],
              ];
            }(),
          ],
          const SizedBox(height: 8),
          Row(children: [
            _legendDot(_primaryColor, '내 스펙'),
            const SizedBox(width: 12),
            _legendDot(Colors.orange, '합격자 평균'),
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
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: avg, minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
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
          _buildStepper('자격증', _simCert, (v) => setState(() => _simCert = v)),
          _buildStepper('프로젝트', _simProject, (v) => setState(() => _simProject = v)),
          _buildStepper('인턴십', _simInternship, (v) => setState(() => _simInternship = v)),
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
        ],
      ),
    );
  }

  Widget _buildSimulationResultCard() {
    final data = _simulateResult!;
    final int before = data['before'] as int? ?? 0;
    final int after = data['after'] as int? ?? 0;
    final double gpa = (data['gpa'] as num?)?.toDouble() ?? 0;
    final double toeic = (data['toeic'] as num?)?.toDouble() ?? 0;
    final int cert = data['cert'] as int? ?? 0;
    final int project = data['project'] as int? ?? 0;
    final int intern = data['intern'] as int? ?? 0;
    final String botText = data['botText'] as String? ?? '';
    final bool improved = after > before;
    final Color afterColor = improved ? _primaryColor : Colors.redAccent;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Text('🔮', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(
                  '시뮬레이션 결과 · ${_simulationCompany ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 합격 가능성 게이지
                if (before > 0 || after > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildGauge('현재', before, Colors.grey),
                      Column(
                        children: [
                          Icon(
                            improved ? Icons.arrow_forward : Icons.arrow_forward,
                            color: improved ? _primaryColor : Colors.redAccent,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            improved ? '+${after - before}%' : '${after - before}%',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: improved ? _primaryColor : Colors.redAccent,
                            ),
                          ),
                        ],
                      ),
                      _buildGauge('변경 후', after, afterColor),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                ],

                // 스펙 바
                const Text('변경된 스펙', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),
                _buildSpecBar('학점', gpa, 4.5, '${gpa.toStringAsFixed(1)} / 4.5'),
                _buildSpecBar('토익', toeic, 990, '${toeic.round()} / 990'),
                _buildSpecBar('자격증', cert.toDouble(), 5, '$cert개', maxLabel: '5+'),
                _buildSpecBar('프로젝트', project.toDouble(), 5, '$project개', maxLabel: '5+'),
                _buildSpecBar('인턴십', intern.toDouble(), 3, '$intern회', maxLabel: '3+'),

                // AI 분석 텍스트
                if (botText.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  const Text('💡 AI 분석', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  MarkdownBody(
                    data: botText,
                    softLineBreak: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(color: Colors.black87, fontSize: 13),
                      h2: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      h3: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      listBullet: const TextStyle(color: Colors.black87, fontSize: 13),
                      tableBody: const TextStyle(fontSize: 12),
                      tableHead: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGauge(String label, int percent, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.black54, fontSize: 12)),
        const SizedBox(height: 8),
        SizedBox(
          width: 90,
          height: 90,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: CircularProgressIndicator(
                  value: (percent / 100).clamp(0.0, 1.0),
                  strokeWidth: 9,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecBar(String label, double value, double max, String displayValue, {String? maxLabel}) {
    final ratio = (value / max).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              Text(displayValue, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _primaryColor)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
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

enum _CardType { specAnalysis, gap, simulation }

class _ChatMessage {
  final String text;
  final bool isUser;
  final _CardType? cardType;
  _ChatMessage({required this.text, required this.isUser, this.cardType});
}

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
