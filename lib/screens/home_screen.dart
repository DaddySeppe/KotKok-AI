import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../providers/fridge_provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/stats_provider.dart';
import '../services/recipe_recommendation_service.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../widgets/dashboard_card.dart';
import '../widgets/recipe_card.dart';
import '../widgets/tag_chip.dart';
import '../widgets/waste_score_circle.dart';
import 'ai_recipe_screen.dart';
import 'panic_cooking_screen.dart';
import 'shopping_list_screen.dart';
import 'recipe_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fridge = context.watch<FridgeProvider>();
    final recipes = context.watch<RecipeProvider>();
    final stats = context.watch<StatsProvider>();
    final preferences = context.watch<PreferencesProvider>();

    final recommendationService = RecipeRecommendationService();
    final recommendationList = recommendationService.buildRecommendations(fridge.ingredients, recipes.savedRecipes);
    final topRecipe = recommendationList.isNotEmpty ? recommendationList.first : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hey, wat gaan we redden vandaag?', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text('Je budget per maaltijd: ${app_date_utils.DateUtils.formatMoney(preferences.preferences.maxBudgetPerMeal)}'),
            const SizedBox(height: 18),
            Center(child: WasteScoreCircle(score: fridge.wasteRiskScore, label: 'Fridge Risk')),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'Vandaag', value: fridge.expiringToday.length.toString(), color: AppConstants.dangerColor)),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(label: 'Binnen 3 dagen', value: fridge.expiringSoon.length.toString(), color: AppConstants.warningColor)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _MetricCard(label: 'Bespaard', value: app_date_utils.DateUtils.formatMoney(stats.moneySaved), color: AppConstants.successColor)),
                const SizedBox(width: 12),
                Expanded(child: _MetricCard(label: 'Producten', value: stats.productsSaved.toString(), color: Colors.blueGrey)),
              ],
            ),
            const SizedBox(height: 18),
            if (fridge.expiringToday.isNotEmpty) ...[
              Text('Ingrediënten voor vandaag', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fridge.expiringToday.take(4).map((item) => TagChip(label: item.name, color: AppConstants.dangerColor.withValues(alpha: 0.12), textColor: AppConstants.dangerColor)).toList(),
              ),
              const SizedBox(height: 18),
            ],
            if (topRecipe != null) ...[
              Text('Top aanbevolen recept', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              RecipeCard(
                recipe: topRecipe,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: topRecipe))),
              ),
              const SizedBox(height: 18),
            ],
            Text('Snelle acties', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.35,
              children: [
                _QuickActionCard(label: 'Gebruik wat vandaag vervalt', icon: Icons.timer_rounded, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PanicCookingScreen()))),
                _QuickActionCard(label: 'Geen zin om te koken', icon: Icons.fastfood_rounded, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const PanicCookingScreen()))),
                _QuickActionCard(label: 'AI recept maken', icon: Icons.auto_awesome_rounded, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AiRecipeScreen()))),
                _QuickActionCard(label: 'Boodschappenlijst', icon: Icons.shopping_bag_rounded, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ShoppingListScreen()))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w700),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
