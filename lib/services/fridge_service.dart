import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/ingredient.dart';

class FridgeService {
  Future<List<Ingredient>> loadIngredients() async {
    try {
      if (!SupabaseConfig.isConfigured) {
        return [];
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];

      final rows = await Supabase.instance.client
          .from('ingredients')
          .select()
          .eq('user_id', user.id)
          .order('expiration_date');
      return rows.map((item) => Ingredient.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (_) {
      // Keep list empty when loading fails.
    }
    return [];
  }

  Future<void> saveIngredient(Ingredient ingredient) async {
    if (!SupabaseConfig.isConfigured) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    await Supabase.instance.client.from('ingredients').upsert({
      ...ingredient.toJson(),
      'user_id': user.id,
    });
  }

  Future<void> deleteIngredient(String id) async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.instance.client.from('ingredients').delete().eq('id', id);
  }
}
