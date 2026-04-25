class AiRecipeRequest {
  AiRecipeRequest({
    required this.ingredients,
    required this.budget,
    required this.allergies,
    required this.dietaryPreferences,
    required this.cookingTimeMinutes,
    required this.mood,
    required this.effortLevel,
    required this.dishCountPreference,
    required this.maxExtraCost,
  });

  final List<Map<String, dynamic>> ingredients;
  final double budget;
  final List<String> allergies;
  final List<String> dietaryPreferences;
  final int cookingTimeMinutes;
  final String mood;
  final String effortLevel;
  final String dishCountPreference;
  final double maxExtraCost;

  Map<String, dynamic> toJson() {
    return {
      'ingredients': ingredients,
      'budget': budget,
      'allergies': allergies,
      'dietaryPreferences': dietaryPreferences,
      'cookingTimeMinutes': cookingTimeMinutes,
      'mood': mood,
      'effortLevel': effortLevel,
      'dishCountPreference': dishCountPreference,
      'maxExtraCost': maxExtraCost,
    };
  }
}
