class CareerGrowthModel {
  final int growthRate;
  final int level;
  final int totalExp;
  final int nextLevelExp;
  final int streakDays;
  final int completedQuests;
  final int totalQuests;
  final int remainingQuests;
  final double? fieldProgressRate;
  final int plantedTreeCount;
  final int maxTreeCount;

  CareerGrowthModel({
    required this.growthRate,
    required this.level,
    required this.totalExp,
    required this.nextLevelExp,
    required this.streakDays,
    required this.completedQuests,
    required this.totalQuests,
    required this.remainingQuests,
    required this.fieldProgressRate,
    required this.plantedTreeCount,
    required this.maxTreeCount,
  });

  // 백엔드 JSON 데이터를 플러터 객체로 변환
  factory CareerGrowthModel.fromJson(Map<String, dynamic> json) {
    return CareerGrowthModel(
      growthRate: json['growthRate'] ?? json['growth_rate'] ?? 0,
      level: json['level'] ?? 1,
      totalExp: json['totalExp'] ?? json['total_exp'] ?? 0,
      nextLevelExp: json['nextLevelExp'] ?? json['next_level_exp'] ?? 1000,
      streakDays: json['streakDays'] ?? json['streak_days'] ?? 0,
      completedQuests: _readInt(json, 'completedQuests', 'completed_quests'),
      totalQuests: _readInt(json, 'totalQuests', 'total_quests', fallback: 20),
      remainingQuests: _readInt(json, 'remainingQuests', 'remaining_quests'),
      fieldProgressRate: _readNullableDouble(
        json,
        'fieldProgressRate',
        'field_progress_rate',
      ),
      plantedTreeCount: _readInt(
        json,
        'plantedTreeCount',
        'planted_tree_count',
      ),
      maxTreeCount: _readInt(
        json,
        'maxTreeCount',
        'max_tree_count',
        fallback: 50,
      ),
    );
  }

  double get fieldProgressValue {
    if (fieldProgressRate != null) {
      return (fieldProgressRate! / 100).clamp(0.0, 1.0);
    }
    if (totalQuests <= 0) return 0;
    return (completedQuests / totalQuests).clamp(0.0, 1.0);
  }

  static int _readInt(
    Map<String, dynamic> json,
    String camelKey,
    String snakeKey, {
    int fallback = 0,
  }) {
    final value = json[camelKey] ?? json[snakeKey];
    if (value is int) return value;
    if (value is num) return value.toInt();
    return fallback;
  }

  static double? _readNullableDouble(
    Map<String, dynamic> json,
    String camelKey,
    String snakeKey,
  ) {
    final value = json[camelKey] ?? json[snakeKey];
    if (value is num) return value.toDouble();
    return null;
  }
}
