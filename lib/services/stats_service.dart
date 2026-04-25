import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/ingredient.dart';
import '../models/waste_stats.dart';
import '../utils/recipe_scoring.dart';

class StatsService {
  WasteStats buildFromData({
    required List<Ingredient> ingredients,
    required int mealsCooked,
    required int aiRecipesGenerated,
    required double moneySaved,
    required int productsSaved,
    String mostWastedCategory = 'Overig',
  }) {
    final month = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}';
    return WasteStats(
      id: 'local-$month',
      userId: SupabaseConfig.isConfigured ? Supabase.instance.client.auth.currentUser?.id : null,
      month: month,
      productsSaved: productsSaved,
      estimatedMoneySaved: moneySaved,
      mostWastedCategory: mostWastedCategory,
      createdAt: DateTime.now(),
      mealsCooked: mealsCooked,
      aiRecipesGenerated: aiRecipesGenerated,
    );
  }

  int calculateWasteRiskScore(List<Ingredient> ingredients) {
    return RecipeScoring.calculateFridgeWasteRiskScore(ingredients);
  }

  Future<void> saveStats(WasteStats stats) async {
    if (!SupabaseConfig.isConfigured) return;
    final userId = stats.userId ?? Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    final payload = stats.toJson();
    payload['user_id'] = userId;
    await Supabase.instance.client.from('waste_stats').upsert(payload);
  }
}
