class DailyLog {
  final int? id;
  final String date;
  final int waterMl;
  final double? weightKg;
  final String? notes;
  final String? createdAt;

  const DailyLog({
    this.id,
    required this.date,
    required this.waterMl,
    this.weightKg,
    this.notes,
    this.createdAt,
  });

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      id: json['id'] as int?,
      date: json['date'] as String,
      waterMl: json['water_ml'] as int,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'water_ml': waterMl,
      'weight_kg': weightKg,
      'notes': notes,
    };
  }
}