import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_provider.dart';
import '../../../core/constants/app_constants.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PortfolioRepository(apiClient.dio, const FlutterSecureStorage());
});

class PortfolioRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  PortfolioRepository(this._dio, this._storage);

  Future<Options> _getHeaders() async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return Options(headers: {
      if (token != null) 'Authorization': 'Bearer $token',
    });
  }

  // 포트폴리오 목록 조회
  Future<List<Map<String, dynamic>>> getPortfolios() async {
    final response = await _dio.get('/api/portfolio', options: await _getHeaders());
    final data = response.data['data'];
    return List<Map<String, dynamic>>.from(data['portfolios'] ?? []);
  }

  // 포트폴리오 등록
  Future<Map<String, dynamic>> createPortfolio(Map<String, dynamic> body) async {
    final response = await _dio.post('/api/portfolio', data: body, options: await _getHeaders());
    return response.data['data'];
  }

  // 포트폴리오 수정
  Future<Map<String, dynamic>> updatePortfolio(int id, Map<String, dynamic> body) async {
    final response = await _dio.patch('/api/portfolio/$id', data: body, options: await _getHeaders());
    return response.data['data'];
  }

  // 포트폴리오 삭제
  Future<void> deletePortfolio(int id) async {
    await _dio.delete('/api/portfolio/$id', options: await _getHeaders());
  }

  // 단건 AI 피드백 (SSE 스트리밍)
  Stream<String> getAiFeedback(int portfolioId) async* {
    final controller = StreamController<String>();
    final token = await _storage.read(key: AppConstants.accessTokenKey);

    _dio
        .get(
      '/api/portfolio/$portfolioId/feedback',
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
          if (token != null) 'Authorization': 'Bearer $token',
        },
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
            controller.add(payload);
          }
        }
        buffer.clear();
        if (lines.isNotEmpty) buffer.write(lines.last);
      }
      controller.close();
    }).catchError((e) {
      controller.addError(e);
      controller.close();
    });

    yield* controller.stream;
  }

  // 전체 종합 AI 분석 (SSE 스트리밍)
  Stream<String> getOverallFeedback() async* {
    final controller = StreamController<String>();
    final token = await _storage.read(key: AppConstants.accessTokenKey);

    _dio
        .get(
      '/api/portfolio/feedback/overall',
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
          if (token != null) 'Authorization': 'Bearer $token',
        },
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
            controller.add(payload);
          }
        }
        buffer.clear();
        if (lines.isNotEmpty) buffer.write(lines.last);
      }
      controller.close();
    }).catchError((e) {
      controller.addError(e);
      controller.close();
    });

    yield* controller.stream;
  }
}
