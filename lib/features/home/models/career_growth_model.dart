class CareerGrowthModel {
  final int growthRate;
  final int level;
  final int totalExp;
  final int nextLevelExp;
  final int streakDays;

  CareerGrowthModel({
    required this.growthRate,
    required this.level,
    required this.totalExp,
    required this.nextLevelExp,
    required this.streakDays,
  });

  // 백엔드 JSON 데이터를 플러터 객체로 변환
  factory CareerGrowthModel.fromJson(Map<String, dynamic> json) {
    return CareerGrowthModel(
      growthRate: json['growth_rate'] ?? 0,
      level: json['level'] ?? 1,
      totalExp: json['total_exp'] ?? 0,
      nextLevelExp: json['next_level_exp'] ?? 100,
      streakDays: json['streak_days'] ?? 0,
    );
  }
}