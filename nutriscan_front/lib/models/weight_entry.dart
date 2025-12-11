class WeightEntry {
  final int? id;
  final double weight;
  final DateTime date;
  final double? bmi;
  final String? notes;

  WeightEntry({
    this.id,
    required this.weight,
    required this.date,
    this.bmi,
    this.notes,
  });

  factory WeightEntry.fromJson(Map<String, dynamic> json) {
    return WeightEntry(
      id: json['id'] as int?,
      weight: (json['weightKg'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      bmi: (json['bmi'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'weightKg': weight,
      'date': date.toIso8601String().split('T')[0],
      if (notes != null) 'notes': notes,
    };
  }
}

