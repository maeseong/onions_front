// import 'dart:async';
// import 'dart:convert';
// import 'package:dio/dio.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import '../../../core/network/api_provider.dart';
// import '../../../core/constants/app_constants.dart';

// final aiRepositoryProvider = Provider<AiRepository>((ref) {
//   final apiClient = ref.watch(apiClientProvider);
//   return AiRepository(apiClient.dio, const FlutterSecureStorage());
// });

// class AiRepository {
//   final Dio _dio;
//   final FlutterSecureStorage _storage;

//   AiRepository(this._dio, this._storage);

//   // API 요청 헤더에 토큰 달아주는 헬퍼
//   Future<Options> _getHeaders({String? contentType}) async {
//     final token = await _storage.read(key: AppConstants.accessTokenKey);
//     return Options(
//       contentType: contentType,
//       headers: {
//         if (token != null) 'Authorization': 'Bearer $token',
//       },
//     );
//   }

//   // 1. SSE 스트리밍 분석 API 연동
//   Stream<Map<String, dynamic>> analyzeSpec(String message, {int? companyId}) async* {
//     final controller = StreamController<Map<String, dynamic>>();
//     final token = await _storage.read(key: AppConstants.accessTokenKey);

//     _dio
//         .post(
//       '/api/ai/analyze',
//       data: {
//         'message': message,
//         if (companyId != null) 'company_id': companyId,
//       },
//       options: Options(
//         responseType: ResponseType.stream,
//         headers: {
//           'Accept': 'text/event-stream',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//       ),
//     )
//         .then((response) async {
//       final stream = response.data.stream as Stream<List<int>>;
//       final buffer = StringBuffer();

//       await for (final chunk in stream) {
//         buffer.write(utf8.decode(chunk));
//         final raw = buffer.toString();
//         final lines = raw.split('\n');

//         for (int i = 0; i < lines.length - 1; i++) {
//           final line = lines[i].trim();
//           if (line.startsWith('data: ')) {
//             final payload = line.substring(6).trim();
//             if (payload == '[DONE]') {
//               controller.close();
//               return;
//             }
//             try {
//               controller.add(jsonDecode(payload));
//             } catch (_) {}
//           }
//         }
//         buffer.clear();
//         if (lines.isNotEmpty) buffer.write(lines.last);
//       }
//       controller.close();
//     })
//         .catchError((e) {
//       controller.addError(e);
//       controller.close();
//     });

//     yield* controller.stream;
//   }

//   // 2. 갭 분석 조회 API 연동
//   Future<Map<String, dynamic>> getGapAnalysis() async {
//     final response = await _dio.get(
//       '/api/ai/gap-analysis',
//       options: await _getHeaders(),
//     );
//     return response.data;
//   }

//   // 3. 스펙 시뮬레이션 API 연동
//   Future<Map<String, dynamic>> simulate({
//     required int companyId,
//     required Map<String, dynamic> specChanges,
//   }) async {
//     final response = await _dio.post(
//       '/api/ai/simulate',
//       data: {'company_id': companyId, 'spec_changes': specChanges},
//       options: await _getHeaders(),
//     );
//     return response.data;
//   }

//   // 4. 합격확률 예측 (단일 기업)
//   Future<Map<String, dynamic>> predictRate(int companyId) async {
//     final response = await _dio.get(
//       '/api/ml/predict?company_id=$companyId',
//       options: await _getHeaders(),
//     );
//     return response.data;
//   }

//   // 5. 전체 목표기업 합격확률 예측
//   Future<Map<String, dynamic>> predictBulk() async {
//     final response = await _dio.get(
//       '/api/ml/predict/bulk',
//       options: await _getHeaders(),
//     );
//     return response.data;
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/api_provider.dart';
import '../../../core/constants/app_constants.dart';

final aiRepositoryProvider = Provider<AiRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AiRepository(apiClient.dio, const FlutterSecureStorage());
});

class AiRepository {
  final Dio _dio;
  final FlutterSecureStorage _storage;

  AiRepository(this._dio, this._storage);

  Future<Options> _getHeaders({String? contentType}) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    return Options(
      contentType: contentType,
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  Stream<Map<String, dynamic>> _sseStream(Future<Response> request) async* {
    final controller = StreamController<Map<String, dynamic>>();

    request.then((response) async {
      final stream = response.data.stream as Stream<List<int>>;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk, allowMalformed: true);

        while (buffer.contains('\n\n')) {
          final eventBlockEnd = buffer.indexOf('\n\n');
          final eventBlock = buffer.substring(0, eventBlockEnd);
          buffer = buffer.substring(eventBlockEnd + 2);

          final dataLines = eventBlock
              .split('\n')
              .where((line) => line.startsWith('data:'))
              .map((line) {
                var value = line.substring(5);
                if (value.startsWith(' ')) value = value.substring(1);
                return value;
              })
              .toList();

          if (dataLines.isEmpty) continue;

          final payload = dataLines.join('\n');

          if (payload == '[DONE]') {
            controller.close();
            return;
          }

          if (payload.isNotEmpty) {
            try {
              controller.add(jsonDecode(payload));
            } catch (_) {
              controller.add({'type': 'text', 'content': payload});
            }
          }
        }
      }

      controller.close();
    }).catchError((e) {
      debugPrint('[SSE] 에러: $e');
      controller.addError(e);
      controller.close();
    });

    yield* controller.stream;
  }

  Stream<Map<String, dynamic>> analyzeSpec(String message, {int? companyId}) async* {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    yield* _sseStream(_dio.post(
      '/api/ai/analyze',
      data: {
        'message': message,
        if (companyId != null) 'company_id': companyId,
      },
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    ));
  }

  Stream<Map<String, dynamic>> chat(String message) async* {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    yield* _sseStream(_dio.post(
      '/api/ai/chat',
      data: {'message': message},
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    ));
  }

  Future<Map<String, dynamic>> gapAnalysis({String? companyName}) async {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    final response = await _dio.get(
      '/api/ai/gap-analysis',
      queryParameters: companyName != null ? {'company': companyName} : null,
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    );
    return response.data['data'] ?? response.data;
  }

  Stream<Map<String, dynamic>> simulateStream({
    required Map<String, dynamic> specChanges,
    String? companyName,
  }) async* {
    final token = await _storage.read(key: AppConstants.accessTokenKey);
    yield* _sseStream(_dio.post(
      '/api/ai/simulate',
      data: {
        'specChanges': specChanges,  // spec_changes → specChanges
        if (companyName != null) 'companyName': companyName,
      },
      options: Options(
        responseType: ResponseType.stream,
        headers: {
          'Accept': 'text/event-stream',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ),
    ));
  }

  Future<Map<String, dynamic>> predictRate(int companyId) async {
    final response = await _dio.get(
      '/api/ml/predict?company_id=$companyId',
      options: await _getHeaders(),
    );
    return response.data;
  }

  Future<Map<String, dynamic>> predictBulk() async {
    final response = await _dio.get(
      '/api/ml/predict/bulk',
      options: await _getHeaders(),
    );
    return response.data;
  }
}
