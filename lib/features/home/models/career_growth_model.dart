class CareerGrowthModel {
  final int growthRate;
  final int level;
  final int totalExp;
  final int nextLevelExp;
  final int streakDays;
  final int completedQuests;
  final int totalQuests;

  CareerGrowthModel({
    required this.growthRate,
    required this.level,
    required this.totalExp,
    required this.nextLevelExp,
    required this.streakDays,
    required this.completedQuests,
    required this.totalQuests,
  });

  // 백엔드 JSON 데이터를 플러터 객체로 변환
  factory CareerGrowthModel.fromJson(Map<String, dynamic> json) {
    return CareerGrowthModel(
      growthRate: json['growthRate'] ?? 0,
      level: json['level'] ?? 1,
      totalExp: json['totalExp'] ?? 0,
      nextLevelExp: json['nextLevelExp'] ?? 1000,
      streakDays: json['streakDays'] ?? 0,
      completedQuests: json['completedQuests'] ?? 0,
      totalQuests: json['totalQuests'] ?? 20,
    );
  }
}
