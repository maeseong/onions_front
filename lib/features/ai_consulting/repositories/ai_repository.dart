import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_provider.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AiRepository(apiClient.dio);
});

class AiRepository {
  final Dio _dio;

  AiRepository(this._dio);

  /// SSE 스트리밍 분석
  Stream<Map<String, dynamic>> analyzeSpec(String message, {int? companyId}) async* {
    final controller = StreamController<Map<String, dynamic>>();

    _dio
        .post(
      '/api/ai/analyze',
      data: {
        'message': message,
        if (companyId != null) 'company_id': companyId,
      },
      options: Options(
        responseType: ResponseType.stream,
        headers: {'Accept': 'text/event-stream'},
      ),
    )
        .then((response) async {
      final stream = response.data.stream as Stream<List<int>>;
      final buffer = StringBuffer();

      await for (final chunk in stream) {
        buffer.write(utf8.decode(chunk));
        final raw = buffer.toString();
        final lines = raw.split('\n');

        for (int i = 0; i < lines.length - 1; i++) {
          final line = lines[i].trim();
          if (line.startsWith('data: ')) {
            final payload = line.substring(6).trim();
            if (payload == '[DONE]') {
              controller.close();
              return;
            }
            try {
              controller.add(jsonDecode(payload));
            } catch (_) {}
          }
        }
        buffer.clear();
        if (lines.isNotEmpty) buffer.write(lines.last);
      }
      controller.close();
    })
        .catchError((e) {
      controller.addError(e);
      controller.close();
    });

    yield* controller.stream;
  }

  /// 갭 분석 조회
  Future<Map<String, dynamic>> getGapAnalysis() async {
    final response = await _dio.get('/api/ai/gap-analysis');
    return response.data;
  }

  /// 스펙 시뮬레이션
  Future<Map<String, dynamic>> simulate({
    required int companyId,
    required Map<String, dynamic> specChanges,
  }) async {
    final response = await _dio.post(
      '/api/ai/simulate',
      data: {'company_id': companyId, 'spec_changes': specChanges},
    );
    return response.data;
  }

  /// 합격확률 예측 (단일 기업)
  Future<Map<String, dynamic>> predictRate(int companyId) async {
    final response = await _dio.get('/api/ml/predict?company_id=$companyId');
    return response.data;
  }

  /// 전체 목표기업 합격확률 예측
  Future<Map<String, dynamic>> predictBulk() async {
    final response = await _dio.get('/api/ml/predict/bulk');
    return response.data;
  }
}