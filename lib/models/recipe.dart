class Recipe {
  Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.cookingTimeMinutes,
    required this.difficulty,
    required this.estimatedExtraCost,
    required this.requiredIngredients,
    required this.missingIngredients,
    required this.usesExpiringIngredients,
    required this.dishCount,
    required this.studentScore,
    required this.wasteSavingScore,
    required this.tags,
    required this.steps,
    this.reason = '',
    this.isAiGenerated = false,
    this.source = 'local',
  });

  final String id;
  final String title;
  final String description;
  final int cookingTimeMinutes;
  final String difficulty;
  final double estimatedExtraCost;
  final List<String> requiredIngredients;
  final List<String> missingIngredients;
  final List<String> usesExpiringIngredients;
  final int dishCount;
  final int studentScore;
  final int wasteSavingScore;
  final List<String> tags;
  final List<String> steps;
  final String reason;
  final bool isAiGenerated;
  final String source;

  double get estimatedCost => estimatedExtraCost;

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    int? cookingTimeMinutes,
    String? difficulty,
    double? estimatedExtraCost,
    List<String>? requiredIngredients,
    List<String>? missingIngredients,
    List<String>? usesExpiringIngredients,
    int? dishCount,
    int? studentScore,
    int? wasteSavingScore,
    List<String>? tags,
    List<String>? steps,
    String? reason,
    bool? isAiGenerated,
    String? source,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cookingTimeMinutes: cookingTimeMinutes ?? this.cookingTimeMinutes,
      difficulty: difficulty ?? this.difficulty,
      estimatedExtraCost: estimatedExtraCost ?? this.estimatedExtraCost,
      requiredIngredients: requiredIngredients ?? this.requiredIngredients,
      missingIngredients: missingIngredients ?? this.missingIngredients,
      usesExpiringIngredients: usesExpiringIngredients ?? this.usesExpiringIngredients,
      dishCount: dishCount ?? this.dishCount,
      studentScore: studentScore ?? this.studentScore,
      wasteSavingScore: wasteSavingScore ?? this.wasteSavingScore,
      tags: tags ?? this.tags,
      steps: steps ?? this.steps,
      reason: reason ?? this.reason,
      isAiGenerated: isAiGenerated ?? this.isAiGenerated,
      source: source ?? this.source,
    );
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    List<String> toList(dynamic value) =>
        (value as List<dynamic>? ?? []).map((item) => item.toString()).toList();

    return Recipe(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      cookingTimeMinutes: (json['cooking_time_minutes'] as num?)?.toInt() ?? 0,
      difficulty: json['difficulty']?.toString() ?? 'Easy',
      estimatedExtraCost: (json['estimated_extra_cost'] as num?)?.toDouble() ??
          (json['estimated_cost'] as num?)?.toDouble() ??
          (json['estimatedCost'] as num?)?.toDouble() ??
          0,
      requiredIngredients: toList(json['required_ingredients']),
      missingIngredients: toList(json['missing_ingredients']),
      usesExpiringIngredients: toList(json['uses_expiring_ingredients']),
      dishCount: (json['dish_count'] as num?)?.toInt() ?? 1,
      studentScore: (json['student_score'] as num?)?.toInt() ?? 0,
      wasteSavingScore: (json['waste_saving_score'] as num?)?.toInt() ?? 0,
      tags: toList(json['tags']),
      steps: toList(json['steps']),
      reason: json['reason']?.toString() ?? '',
      isAiGenerated: json['is_ai_generated'] == true,
      source: json['source']?.toString() ?? 'local',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cooking_time_minutes': cookingTimeMinutes,
      'difficulty': difficulty,
      'estimated_extra_cost': estimatedExtraCost,
      'required_ingredients': requiredIngredients,
      'missing_ingredients': missingIngredients,
      'uses_expiring_ingredients': usesExpiringIngredients,
      'dish_count': dishCount,
      'student_score': studentScore,
      'waste_saving_score': wasteSavingScore,
      'tags': tags,
      'steps': steps,
      'reason': reason,
      'is_ai_generated': isAiGenerated,
      'source': source,
    };
  }
}
