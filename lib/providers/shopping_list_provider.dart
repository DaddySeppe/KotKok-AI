import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/shopping_item.dart';
import '../services/shopping_list_service.dart';

class ShoppingListProvider extends ChangeNotifier {
  final ShoppingListService _service = ShoppingListService();

  List<ShoppingItem> _items = [];

  List<ShoppingItem> get items => List.unmodifiable(_items);
  List<ShoppingItem> get pendingItems => _items.where((item) => !item.isBought).toList();
  List<ShoppingItem> get boughtItems => _items.where((item) => item.isBought).toList();
  double get totalEstimatedCost => _items.fold(0, (sum, item) => sum + item.estimatedPrice);

  Future<void> bootstrap() async {
    _items = await _service.loadItems();
    notifyListeners();
  }

  Future<void> addItem(String name, {double estimatedPrice = 0}) async {
    final item = ShoppingItem(
      id: const Uuid().v4(),
      userId: null,
      name: name,
      estimatedPrice: estimatedPrice,
      isBought: false,
      createdAt: DateTime.now(),
    );
    _items = [item, ..._items];
    notifyListeners();
    await _service.saveItem(item);
  }

  Future<void> toggleBought(String id) async {
    _items = _items
        .map((item) => item.id == id ? item.copyWith(isBought: !item.isBought) : item)
        .toList();
    notifyListeners();
    final item = _items.firstWhere((element) => element.id == id);
    await _service.saveItem(item);
  }

  Future<void> deleteItem(String id) async {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
    await _service.deleteItem(id);
  }

  Future<void> clearBoughtItems() async {
    final boughtIds = boughtItems.map((item) => item.id).toList();
    _items.removeWhere((item) => item.isBought);
    notifyListeners();
    for (final id in boughtIds) {
      await _service.deleteItem(id);
    }
  }

  Future<void> addItemsFromRecipe(List<String> missingIngredients) async {
    for (final ingredient in missingIngredients) {
      if (_items.any((item) => item.name.toLowerCase() == ingredient.toLowerCase())) continue;
      await addItem(ingredient);
    }
  }
}
