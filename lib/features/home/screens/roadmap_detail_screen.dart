import 'package:flutter/material.dart';

class RoadmapDetailScreen extends StatelessWidget {
  final Map<String, dynamic> stage;

  const RoadmapDetailScreen({super.key, required this.stage});

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final isCompleted = stage['is_completed'] ?? false;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          stage['stage_name'] ?? '',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 완료 여부 뱃지
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green.withOpacity(0.1) : primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                    size: 16,
                    color: isCompleted ? Colors.green : primaryColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isCompleted ? '완료' : '진행중',
                    style: TextStyle(
                      color: isCompleted ? Colors.green : primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 단계 이름
            Text(
              stage['stage_name'] ?? '',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // 설명
            Text(
              stage['description'] ?? '',
              style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.6),
            ),
            const SizedBox(height: 32),

            // 단계 정보 카드
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
                  const Text('단계 정보', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _buildInfoRow('단계', '${stage['stage_order'] ?? '-'}단계'),
                  _buildInfoRow('상태', isCompleted ? '✅ 완료' : '🔄 진행중'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 완료 버튼
            if (!isCompleted)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('백엔드 연동 후 사용 가능해요!')),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('완료하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}