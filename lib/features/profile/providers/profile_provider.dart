import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../repositories/profile_repository.dart';

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return await repository.fetchProfile();
});

// 뱃지 데이터를 실시간으로 가져오기 위한 Provider
final badgesProvider = FutureProvider<List<dynamic>>((ref) async {
  try {
    final repository = ref.watch(profileRepositoryProvider);
    return await repository.fetchBadges();
  } catch (e) {
    if (e is DioException && e.response?.statusCode == 404) return [];
    rethrow;
  }
});