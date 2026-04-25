import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../config/supabase_config.dart';
import '../models/ai_recipe_request.dart';
import '../models/ai_recipe_response.dart';
import '../models/recipe.dart';

class AiRecipeService {
  Future<AiRecipeResponse> generateRecipe(AiRecipeRequest request) async {
    if (!SupabaseConfig.isConfigured) {
      return _localFallback(request);
    }

    final response = await Supabase.instance.client.functions.invoke(
      'generate-recipe',
      body: request.toJson(),
    );

    if (response.data is Map<String, dynamic>) {
      return AiRecipeResponse.fromJson(Map<String, dynamic>.from(response.data as Map));
    }

    if (response.data is String) {
      final decoded = jsonDecode(response.data as String) as Map<String, dynamic>;
      return AiRecipeResponse.fromJson(decoded);
    }

    throw Exception('Oeps, het slimme recept lukte niet. Probeer opnieuw of kies een lokaal recept.');
  }

  Recipe toRecipe(AiRecipeResponse response) {
    return Recipe(
      id: const Uuid().v4(),
      title: response.title,
      description: response.description,
      cookingTimeMinutes: response.cookingTimeMinutes,
      difficulty: 'Easy',
      estimatedExtraCost: response.estimatedCost,
      requiredIngredients: response.ingredientsUsed,
      missingIngredients: response.missingIngredients,
      usesExpiringIngredients: response.ingredientsUsed,
      dishCount: response.dishCount,
      studentScore: response.studentScore,
      wasteSavingScore: response.wasteSavingScore,
      tags: response.tags,
      steps: response.steps,
      reason: response.reason,
      isAiGenerated: true,
      source: 'ai',
    );
  }

  AiRecipeResponse _localFallback(AiRecipeRequest request) {
    final used = request.ingredients.take(4).map((item) => item['name'].toString()).toList();
    return AiRecipeResponse(
      title: 'Slim lokaal recept',
      description: 'Een offline fallback op basis van je koelkast.',
      reason: 'AI is niet geconfigureerd, dus KotKok AI gebruikt een lokale fallback.',
      ingredientsUsed: used,
      missingIngredients: const ['olijfolie'],
      steps: const [
        'Pak je meest verse ingrediënten.',
        'Meng of bak ze simpel samen.',
        'Serveer direct en geniet van minder waste.',
      ],
      estimatedCost: 0.90,
      cookingTimeMinutes: request.cookingTimeMinutes,
      dishCount: 1,
      wasteSavingScore: 70,
      studentScore: 78,
      tags: const ['offline', 'fallback', 'budget'],
    );
  }
}
