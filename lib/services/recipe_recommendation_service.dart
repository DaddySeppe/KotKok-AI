import '../models/ingredient.dart';
import '../models/recipe.dart';
import '../utils/date_utils.dart';
import '../utils/recipe_scoring.dart';

class RecipeRecommendationService {
  List<Recipe> buildRecommendations(List<Ingredient> ingredients, List<Recipe> savedRecipes) {
    final allRecipes = <Recipe>[...savedRecipes];

    final enriched = allRecipes.map((recipe) {
      final ingredientsUsed = recipe.requiredIngredients
          .where((requiredIngredient) => ingredients.any((ingredient) => ingredient.name.toLowerCase() == requiredIngredient.toLowerCase()))
          .toList();

      final expiringUsed = ingredientsUsed.where((ingredientName) {
        final ingredient = ingredients.firstWhere((item) => item.name.toLowerCase() == ingredientName.toLowerCase());
        return DateUtils.isToday(ingredient) || DateUtils.isSoon(ingredient) || DateUtils.isExpired(ingredient);
      }).toList();

      return recipe.copyWith(
        usesExpiringIngredients: expiringUsed,
        missingIngredients: recipe.requiredIngredients
            .where((requiredIngredient) => !ingredients.any((ingredient) => ingredient.name.toLowerCase() == requiredIngredient.toLowerCase()))
            .toList(),
        studentScore: RecipeScoring.calculateStudentScore(recipe),
        wasteSavingScore: RecipeScoring.calculateWasteSavingScore(recipe, ingredients),
      );
    }).toList();

    return RecipeScoring.sortRecipes(enriched);
  }

  List<Recipe> buildPanicSuggestions(List<Ingredient> ingredients) {
    final options = buildRecommendations(ingredients, []);
    return options.where((recipe) => recipe.cookingTimeMinutes <= 20).take(3).toList();
  }
}
