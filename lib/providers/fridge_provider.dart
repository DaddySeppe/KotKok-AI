import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/ingredient.dart';
import '../services/fridge_service.dart';
import '../services/stats_service.dart';
import '../utils/date_utils.dart' as app_date;

class FridgeProvider extends ChangeNotifier {
  final FridgeService _service = FridgeService();
  final StatsService _statsService = StatsService();

  List<Ingredient> _ingredients = [];
  String _searchQuery = '';
  String _storageFilter = 'all';
  String _statusFilter = 'all';

  List<Ingredient> get ingredients => List.unmodifiable(_ingredients);
  String get searchQuery => _searchQuery;
  String get storageFilter => _storageFilter;
  String get statusFilter => _statusFilter;

  List<Ingredient> get filteredIngredients {
    return _ingredients.where((ingredient) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          ingredient.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          ingredient.category.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStorage =
          _storageFilter == 'all' || ingredient.storageLocation == _storageFilter;

      final status = app_date.DateUtils.ingredientStatusLabel(ingredient);

      final matchesStatus = _statusFilter == 'all' || status == _statusFilter;

      return matchesSearch && matchesStorage && matchesStatus;
    }).toList();
  }

  List<Ingredient> get expiringToday =>
      _ingredients.where(app_date.DateUtils.isToday).toList();

  List<Ingredient> get expiringSoon =>
      _ingredients.where(app_date.DateUtils.isSoon).toList();

  List<Ingredient> get expiredIngredients =>
      _ingredients.where(app_date.DateUtils.isExpired).toList();

  int get wasteRiskScore => _statsService.calculateWasteRiskScore(_ingredients);

  Future<void> bootstrap() async {
    _ingredients = await _service.loadIngredients();
    notifyListeners();
  }

  void setSearchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  void setStorageFilter(String value) {
    _storageFilter = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    _statusFilter = value;
    notifyListeners();
  }

  Future<void> addIngredient(Ingredient ingredient) async {
    final item =
        ingredient.id.isEmpty ? ingredient.copyWith(id: const Uuid().v4()) : ingredient;

    _ingredients = [item, ..._ingredients];
    notifyListeners();

    await _service.saveIngredient(item);
  }

  Future<void> updateIngredient(Ingredient ingredient) async {
    _ingredients = _ingredients
        .map((item) => item.id == ingredient.id ? ingredient : item)
        .toList();

    notifyListeners();

    await _service.saveIngredient(ingredient);
  }

  Future<void> deleteIngredient(String id) async {
    _ingredients.removeWhere((ingredient) => ingredient.id == id);
    notifyListeners();

    await _service.deleteIngredient(id);
  }

  Future<void> consumeIngredients(List<String> names) async {
    _ingredients = _ingredients.where((ingredient) {
      return !names.any(
        (name) => name.toLowerCase() == ingredient.name.toLowerCase(),
      );
    }).toList();

    notifyListeners();
  }
}