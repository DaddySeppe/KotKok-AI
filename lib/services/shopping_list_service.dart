import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_config.dart';
import '../models/shopping_item.dart';

class ShoppingListService {
  Future<List<ShoppingItem>> loadItems() async {
    try {
      if (!SupabaseConfig.isConfigured) {
        return [];
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return [];

      final rows = await Supabase.instance.client
          .from('shopping_items')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return rows.map((item) => ShoppingItem.fromJson(Map<String, dynamic>.from(item))).toList();
    } catch (_) {}
    return [];
  }

  Future<void> saveItem(ShoppingItem item) async {
    if (!SupabaseConfig.isConfigured) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    await Supabase.instance.client.from('shopping_items').upsert({
      ...item.toJson(),
      'user_id': user.id,
    });
  }

  Future<void> deleteItem(String id) async {
    if (!SupabaseConfig.isConfigured) return;
    await Supabase.instance.client.from('shopping_items').delete().eq('id', id);
  }
}
