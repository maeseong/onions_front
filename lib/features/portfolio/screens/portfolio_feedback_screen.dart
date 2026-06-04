import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/portfolio_repository.dart';

class PortfolioFeedbackScreen extends ConsumerStatefulWidget {
  final int? portfolioId;
  final String? portfolioTitle;
  final bool isOverall;

  const PortfolioFeedbackScreen({
    super.key,
    this.portfolioId,
    this.portfolioTitle,
    this.isOverall = false,
  });

  @override
  ConsumerState<PortfolioFeedbackScreen> createState() => _PortfolioFeedbackScreenState();
}

class _PortfolioFeedbackScreenState extends ConsumerState<PortfolioFeedbackScreen> {
  static const _primaryColor = Color(0xFF61B099);
  final StringBuffer _buffer = StringBuffer();
  String _displayText = '';
  bool _isLoading = true;
  bool _isDone = false;

  @override
  void initState() {
    super.initState();
    _startFeedback();
  }

  void _startFeedback() {
    final repo = ref.read(portfolioRepositoryProvider);
    final stream = widget.isOverall
        ? repo.getOverallFeedback()
        : repo.getAiFeedback(widget.portfolioId!);

    stream.listen(
      (chunk) {
        setState(() {
          _buffer.write(chunk);
          _displayText = _buffer.toString();
          _isLoading = false;
        });
      },
      onDone: () => setState(() => _isDone = true),
      onError: (_) => setState(() {
        _isLoading = false;
        _isDone = true;
        _displayText = '피드백을 불러오는 중 오류가 발생했어요. 다시 시도해주세요.';
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isOverall ? '포트폴리오 종합 분석' : '${widget.portfolioTitle} 피드백';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: _primaryColor),
                  SizedBox(height: 16),
                  Text('AI가 분석 중이에요...', style: TextStyle(color: Colors.black54)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI 아이콘 + 설명
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _primaryColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: _primaryColor, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.isOverall
                                ? 'AI가 전체 포트폴리오를 종합적으로 분석했어요'
                                : 'AI가 이 프로젝트를 취업 관점에서 리뷰했어요',
                            style: const TextStyle(color: _primaryColor, fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 피드백 텍스트
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _displayText,
                          style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.7),
                        ),
                        if (!_isDone) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              SizedBox(
                                width: 16, height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey[400]),
                              ),
                              const SizedBox(width: 8),
                              Text('분석 중...', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
