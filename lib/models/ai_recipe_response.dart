class AiRecipeResponse {
  AiRecipeResponse({
    required this.title,
    required this.description,
    required this.reason,
    required this.ingredientsUsed,
    required this.missingIngredients,
    required this.steps,
    required this.estimatedCost,
    required this.cookingTimeMinutes,
    required this.dishCount,
    required this.wasteSavingScore,
    required this.studentScore,
    required this.tags,
  });

  final String title;
  final String description;
  final String reason;
  final List<String> ingredientsUsed;
  final List<String> missingIngredients;
  final List<String> steps;
  final double estimatedCost;
  final int cookingTimeMinutes;
  final int dishCount;
  final int wasteSavingScore;
  final int studentScore;
  final List<String> tags;

  factory AiRecipeResponse.fromJson(Map<String, dynamic> json) {
    List<String> toList(dynamic value) =>
        (value as List<dynamic>? ?? []).map((item) => item.toString()).toList();

    return AiRecipeResponse(
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      ingredientsUsed: toList(json['ingredientsUsed']),
      missingIngredients: toList(json['missingIngredients']),
      steps: toList(json['steps']),
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble() ?? 0,
      cookingTimeMinutes: (json['cookingTimeMinutes'] as num?)?.toInt() ?? 0,
      dishCount: (json['dishCount'] as num?)?.toInt() ?? 1,
      wasteSavingScore: (json['wasteSavingScore'] as num?)?.toInt() ?? 0,
      studentScore: (json['studentScore'] as num?)?.toInt() ?? 0,
      tags: toList(json['tags']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'reason': reason,
      'ingredientsUsed': ingredientsUsed,
      'missingIngredients': missingIngredients,
      'steps': steps,
      'estimatedCost': estimatedCost,
      'cookingTimeMinutes': cookingTimeMinutes,
      'dishCount': dishCount,
      'wasteSavingScore': wasteSavingScore,
      'studentScore': studentScore,
      'tags': tags,
    };
  }
}
