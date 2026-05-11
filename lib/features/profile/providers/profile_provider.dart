import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';

final profileProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  return repository.fetchProfile();
});