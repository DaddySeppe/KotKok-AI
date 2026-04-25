import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/ai_recipe_request.dart';
import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../config/supabase_config.dart';
import '../services/ai_recipe_service.dart';
import '../services/recipe_recommendation_service.dart';
import '../utils/recipe_scoring.dart';

class RecipeProvider extends ChangeNotifier {
  final RecipeRecommendationService _recommendationService = RecipeRecommendationService();
  final AiRecipeService _aiRecipeService = AiRecipeService();

  List<Recipe> _savedRecipes = [];
  List<Recipe> _recommendations = [];
  bool _isGenerating = false;
  String? _errorMessage;

  List<Recipe> get savedRecipes => List.unmodifiable(_savedRecipes);
  List<Recipe> get recommendations => List.unmodifiable(_recommendations);
  bool get isGenerating => _isGenerating;
  String? get errorMessage => _errorMessage;

  void bootstrap() {
    _recommendations = RecipeScoring.sortRecipes([]);
    _loadSavedRecipes();
    notifyListeners();
  }

  Future<void> _loadSavedRecipes() async {
    if (!SupabaseConfig.isConfigured) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      final rows = await Supabase.instance.client
          .from('saved_recipes')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final remoteRecipes = rows.map((item) => Recipe.fromJson(Map<String, dynamic>.from(item))).toList();
      _savedRecipes = [
        ...remoteRecipes,
        ..._savedRecipes.where((item) => item.source != 'ai'),
      ];
      _recommendations = _recommendationService.buildRecommendations([], _savedRecipes);
      notifyListeners();
    } catch (_) {
      // Keep local recipes if remote loading fails.
    }
  }

  void refreshRecommendations(List<Ingredient> ingredients) {
    _recommendations = _recommendationService.buildRecommendations(ingredients, _savedRecipes);
    notifyListeners();
  }

  List<Recipe> panicSuggestions(List<Ingredient> ingredients) {
    return _recommendationService.buildPanicSuggestions(ingredients);
  }

  Future<Recipe?> generateAiRecipe({
    required List<Ingredient> ingredients,
    required double budget,
    required List<String> allergies,
    required List<String> dietaryPreferences,
    required int cookingTimeMinutes,
    required String mood,
    required String effortLevel,
    required String dishCountPreference,
  }) async {
    _isGenerating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final request = AiRecipeRequest(
        ingredients: ingredients.map((ingredient) => ingredient.toJson()).toList(),
        budget: budget,
        allergies: allergies,
        dietaryPreferences: dietaryPreferences,
        cookingTimeMinutes: cookingTimeMinutes,
        mood: mood,
        effortLevel: effortLevel,
        dishCountPreference: dishCountPreference,
        maxExtraCost: budget,
      );

      final response = await _aiRecipeService.generateRecipe(request);
      final recipe = _aiRecipeService.toRecipe(response);
      saveRecipe(recipe);
      notifyListeners();
      return recipe;
    } catch (error) {
      _errorMessage = 'Oeps, het slimme recept lukte niet. Probeer opnieuw of kies een lokaal recept.';
      notifyListeners();
      return null;
    } finally {
      _isGenerating = false;
      notifyListeners();
    }
  }

  void saveRecipe(Recipe recipe) {
    _savedRecipes = [recipe, ..._savedRecipes.where((item) => item.id != recipe.id)];
    _recommendations = [recipe, ..._recommendations.where((item) => item.id != recipe.id)];
    _persistRecipe(recipe);
    notifyListeners();
  }

  Future<void> _persistRecipe(Recipe recipe) async {
    if (!SupabaseConfig.isConfigured) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('saved_recipes').upsert({
        'id': recipe.id.isEmpty ? const Uuid().v4() : recipe.id,
        'user_id': user.id,
        'title': recipe.title,
        'description': recipe.description,
        'reason': recipe.reason,
        'ingredients_used': recipe.requiredIngredients,
        'missing_ingredients': recipe.missingIngredients,
        'steps': recipe.steps,
        'estimated_cost': recipe.estimatedExtraCost,
        'cooking_time_minutes': recipe.cookingTimeMinutes,
        'dish_count': recipe.dishCount,
        'waste_saving_score': recipe.wasteSavingScore,
        'student_score': recipe.studentScore,
      });
    } catch (_) {
      // Local state already updated.
    }
  }
}
