import '../models/ingredient.dart';
import '../models/recipe.dart';
import 'date_utils.dart';

class RecipeScoring {
  static int calculateStudentScore(Recipe recipe) {
    final score = 100 -
        (recipe.estimatedExtraCost * 10).round() -
        (recipe.cookingTimeMinutes * 0.8).round() -
        (recipe.dishCount * 5) -
        (recipe.missingIngredients.length * 6) +
        (recipe.usesExpiringIngredients.length * 15);
    return score.clamp(0, 100);
  }

  static int calculateWasteSavingScore(Recipe recipe, List<Ingredient> ingredients) {
    int score = 20;

    for (final ingredientName in recipe.usesExpiringIngredients) {
      final ingredient = ingredients.where((item) => item.name.toLowerCase() == ingredientName.toLowerCase()).toList();
      if (ingredient.isNotEmpty) {
        final days = DateUtils.daysUntil(ingredient.first.expirationDate);
        if (days < 0) {
          score += 0;
        } else if (days == 0) {
          score += 25;
        } else if (days <= 3) {
          score += 18;
        } else {
          score += 10;
        }
      } else {
        score += 5;
      }
    }

    if (recipe.missingIngredients.isEmpty) {
      score += 10;
    }

    return score.clamp(0, 100);
  }

  static int calculateFridgeWasteRiskScore(List<Ingredient> ingredients) {
    if (ingredients.isEmpty) return 0;

    final expired = ingredients.where(DateUtils.isExpired).length;
    final today = ingredients.where(DateUtils.isToday).length;
    final soon = ingredients.where(DateUtils.isSoon).length;
    final total = ingredients.length;

    final rawScore = (expired * 30) + (today * 22) + (soon * 12) + ((total - expired - today - soon) * 1.5);
    return rawScore.round().clamp(0, 100);
  }

  static List<Recipe> sortRecipes(List<Recipe> recipes) {
    final sorted = [...recipes];
    sorted.sort((left, right) {
      int compareListLength(List<String> value1, List<String> value2) => value1.length.compareTo(value2.length);

      final leftUsesToday = left.usesExpiringIngredients.length;
      final rightUsesToday = right.usesExpiringIngredients.length;
      if (leftUsesToday != rightUsesToday) return rightUsesToday.compareTo(leftUsesToday);

      if (left.estimatedExtraCost != right.estimatedExtraCost) {
        return left.estimatedExtraCost.compareTo(right.estimatedExtraCost);
      }

      if (left.cookingTimeMinutes != right.cookingTimeMinutes) {
        return left.cookingTimeMinutes.compareTo(right.cookingTimeMinutes);
      }

      if (left.dishCount != right.dishCount) {
        return left.dishCount.compareTo(right.dishCount);
      }

      if (left.studentScore != right.studentScore) {
        return right.studentScore.compareTo(left.studentScore);
      }

      return compareListLength(left.steps, right.steps);
    });
    return sorted;
  }
}
