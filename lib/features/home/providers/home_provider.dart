import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/career_growth_model.dart';
import '../repositories/home_repository.dart';

final careerGrowthProvider = FutureProvider.autoDispose<CareerGrowthModel>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  // 저장소에 데이터 달라고 요청
  return await repository.getCareerGrowth();
});