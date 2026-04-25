import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fridge_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/stats_provider.dart';
import '../services/recipe_recommendation_service.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../widgets/dashboard_card.dart';
import '../widgets/recipe_card.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final stats = context.watch<StatsProvider>();
    final fridge = context.watch<FridgeProvider>();
    final recipes = context.watch<RecipeProvider>();
    final recommendations = RecipeRecommendationService().buildRecommendations(fridge.ingredients, recipes.savedRecipes);
    final topRecipe = recommendations.isNotEmpty ? recommendations.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistieken')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _BigStatCard(label: 'Je hebt deze maand al', value: '${app_date_utils.DateUtils.formatMoney(stats.moneySaved)} bespaard.'),
            const SizedBox(height: 12),
            _BigStatCard(label: 'Producten gered', value: '${stats.productsSaved} producten van de vuilbak gered.'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MiniStat(label: 'Waste risk', value: fridge.wasteRiskScore.toString())),
                const SizedBox(width: 12),
                Expanded(child: _MiniStat(label: 'Maaltijden', value: stats.mealsCooked.toString())),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MiniStat(label: 'AI recepten', value: stats.aiRecipesGenerated.toString())),
                const SizedBox(width: 12),
                Expanded(child: _MiniStat(label: 'Meest verspild', value: stats.stats.mostWastedCategory)),
              ],
            ),
            const SizedBox(height: 18),
            if (topRecipe != null) ...[
              Text('Best student score recipe', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              RecipeCard(recipe: topRecipe),
            ],
            const SizedBox(height: 12),
            Text('Sterk bezig, je koelkast is onder controle.', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  const _BigStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
