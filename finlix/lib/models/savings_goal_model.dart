class SavingsGoalModel {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String emoji;
  final DateTime? targetDate;

  SavingsGoalModel({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    required this.emoji,
    this.targetDate,
  });

  double get progress => targetAmount == 0 ? 0 : (currentAmount / targetAmount).clamp(0.0, 1.0);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'target_amount': targetAmount,
      'current_amount': currentAmount,
      'emoji': emoji,
      'target_date': targetDate?.toIso8601String(),
    };
  }

  factory SavingsGoalModel.fromMap(Map<String, dynamic> map) {
    return SavingsGoalModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetAmount: (map['target_amount'] as num).toDouble(),
      currentAmount: (map['current_amount'] as num).toDouble(),
      emoji: map['emoji'] as String,
      targetDate: map['target_date'] != null ? DateTime.parse(map['target_date'] as String) : null,
    );
  }
}
