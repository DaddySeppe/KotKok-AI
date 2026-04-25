class WasteStats {
  WasteStats({
    required this.id,
    required this.userId,
    required this.month,
    required this.productsSaved,
    required this.estimatedMoneySaved,
    required this.mostWastedCategory,
    required this.createdAt,
    this.mealsCooked = 0,
    this.aiRecipesGenerated = 0,
  });

  final String id;
  final String? userId;
  final String month;
  final int productsSaved;
  final double estimatedMoneySaved;
  final String mostWastedCategory;
  final DateTime createdAt;
  final int mealsCooked;
  final int aiRecipesGenerated;

  WasteStats copyWith({
    String? id,
    String? userId,
    String? month,
    int? productsSaved,
    double? estimatedMoneySaved,
    String? mostWastedCategory,
    DateTime? createdAt,
    int? mealsCooked,
    int? aiRecipesGenerated,
  }) {
    return WasteStats(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      productsSaved: productsSaved ?? this.productsSaved,
      estimatedMoneySaved: estimatedMoneySaved ?? this.estimatedMoneySaved,
      mostWastedCategory: mostWastedCategory ?? this.mostWastedCategory,
      createdAt: createdAt ?? this.createdAt,
      mealsCooked: mealsCooked ?? this.mealsCooked,
      aiRecipesGenerated: aiRecipesGenerated ?? this.aiRecipesGenerated,
    );
  }

  factory WasteStats.fromJson(Map<String, dynamic> json) {
    return WasteStats(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString(),
      month: json['month']?.toString() ?? '',
      productsSaved: (json['products_saved'] as num?)?.toInt() ?? 0,
      estimatedMoneySaved:
          (json['estimated_money_saved'] as num?)?.toDouble() ?? 0,
      mostWastedCategory: json['most_wasted_category']?.toString() ?? '',
      createdAt: json['created_at'] == null
          ? DateTime.now()
          : DateTime.parse(json['created_at'].toString()),
      mealsCooked: (json['meals_cooked'] as num?)?.toInt() ?? 0,
      aiRecipesGenerated: (json['ai_recipes_generated'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'month': month,
      'products_saved': productsSaved,
      'estimated_money_saved': estimatedMoneySaved,
      'most_wasted_category': mostWastedCategory,
      'created_at': createdAt.toIso8601String(),
      'meals_cooked': mealsCooked,
      'ai_recipes_generated': aiRecipesGenerated,
    };
  }
}
