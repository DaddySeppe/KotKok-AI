import 'package:flutter/material.dart';
import 'dart:async';

import '../models/ingredient.dart';
import '../models/waste_stats.dart';
import '../services/stats_service.dart';

class StatsProvider extends ChangeNotifier {
  final StatsService _service = StatsService();

  WasteStats _stats = WasteStats(
    id: 'local',
    userId: null,
    month: '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}',
    productsSaved: 0,
    estimatedMoneySaved: 0,
    mostWastedCategory: 'Overig',
    createdAt: DateTime.now(),
    mealsCooked: 0,
    aiRecipesGenerated: 0,
  );

  WasteStats get stats => _stats;
  int get productsSaved => _stats.productsSaved;
  double get moneySaved => _stats.estimatedMoneySaved;
  int get mealsCooked => _stats.mealsCooked;
  int get aiRecipesGenerated => _stats.aiRecipesGenerated;

  Future<void> bootstrap() async {
    notifyListeners();
  }

  void recompute({
    required List<Ingredient> ingredients,
    required int mealsCooked,
    required int aiRecipesGenerated,
    required double moneySaved,
    required int productsSaved,
    String mostWastedCategory = 'Overig',
  }) {
    _stats = _service.buildFromData(
      ingredients: ingredients,
      mealsCooked: mealsCooked,
      aiRecipesGenerated: aiRecipesGenerated,
      moneySaved: moneySaved,
      productsSaved: productsSaved,
      mostWastedCategory: mostWastedCategory,
    );
    unawaited(_service.saveStats(_stats));
    notifyListeners();
  }

  void addMealCooked() {
    _stats = _stats.copyWith(mealsCooked: _stats.mealsCooked + 1);
    unawaited(_service.saveStats(_stats));
    notifyListeners();
  }

  void addAiRecipeGenerated() {
    _stats = _stats.copyWith(aiRecipesGenerated: _stats.aiRecipesGenerated + 1);
    unawaited(_service.saveStats(_stats));
    notifyListeners();
  }

  void addMoneySaved(double value) {
    _stats = _stats.copyWith(estimatedMoneySaved: _stats.estimatedMoneySaved + value);
    unawaited(_service.saveStats(_stats));
    notifyListeners();
  }

  void addProductsSaved(int value) {
    _stats = _stats.copyWith(productsSaved: _stats.productsSaved + value);
    unawaited(_service.saveStats(_stats));
    notifyListeners();
  }
}
