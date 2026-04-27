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
import 'fridge_photo_scan_screen.dart';
import 'panic_cooking_screen.dart';
import 'recipe_detail_screen.dart';
import 'shopping_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fridge = context.watch<FridgeProvider>();
    final recipes = context.watch<RecipeProvider>();
    final stats = context.watch<StatsProvider>();
    final preferences = context.watch<PreferencesProvider>();

    final recommendationService = RecipeRecommendationService();
    final recommendationList = recommendationService.buildRecommendations(
      fridge.ingredients,
      recipes.savedRecipes,
    );
    final topRecipe =
        recommendationList.isNotEmpty ? recommendationList.first : null;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'KotKok AI',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Vandaag redden we eerst wat snel op moet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withValues(alpha: 0.64),
                        ),
                  ),
                  const SizedBox(height: 18),
                  _PriorityPanel(
                    riskScore: fridge.wasteRiskScore,
                    todayCount: fridge.expiringToday.length,
                    soonCount: fridge.expiringSoon.length,
                    budget: app_date_utils.DateUtils.formatMoney(
                      preferences.preferences.maxBudgetPerMeal,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
              children: [
                _MetricCard(
                  label: 'Bespaard',
                  value: app_date_utils.DateUtils.formatMoney(stats.moneySaved),
                  icon: Icons.savings_outlined,
                  color: AppConstants.successColor,
                ),
                _MetricCard(
                  label: 'Producten',
                  value: stats.productsSaved.toString(),
                  icon: Icons.inventory_2_outlined,
                  color: Colors.blueGrey,
                ),
              ],
            ),
          ),
          if (fridge.expiringToday.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              sliver: SliverToBoxAdapter(
                child: _Section(
                  title: 'Vandaag gebruiken',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: fridge.expiringToday
                        .take(6)
                        .map(
                          (item) => TagChip(
                            label: item.name,
                            color: AppConstants.dangerColor
                                .withValues(alpha: 0.12),
                            textColor: AppConstants.dangerColor,
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: SliverToBoxAdapter(
              child: _Section(
                title: 'Snelle acties',
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.24,
                  children: [
                    _QuickActionCard(
                      label: 'Koelkast scannen',
                      icon: Icons.camera_alt_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const FridgePhotoScanScreen()),
                      ),
                    ),
                    _QuickActionCard(
                      label: 'Vandaag koken',
                      icon: Icons.timer_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const PanicCookingScreen()),
                      ),
                    ),
                    _QuickActionCard(
                      label: 'AI recept',
                      icon: Icons.auto_awesome_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AiRecipeScreen()),
                      ),
                    ),
                    _QuickActionCard(
                      label: 'Boodschappen',
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ShoppingListScreen()),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (topRecipe != null)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              sliver: SliverToBoxAdapter(
                child: _Section(
                  title: 'Aanbevolen recept',
                  child: RecipeCard(
                    recipe: topRecipe,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) =>
                              RecipeDetailScreen(recipe: topRecipe)),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PriorityPanel extends StatelessWidget {
  const _PriorityPanel({
    required this.riskScore,
    required this.todayCount,
    required this.soonCount,
    required this.budget,
  });

  final int riskScore;
  final int todayCount;
  final int soonCount;
  final String budget;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          WasteScoreCircle(score: riskScore, label: 'Risico'),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              children: [
                _PriorityRow(
                    label: 'Vandaag',
                    value: todayCount.toString(),
                    color: AppConstants.dangerColor),
                const Divider(height: 22),
                _PriorityRow(
                    label: 'Binnen 3 dagen',
                    value: soonCount.toString(),
                    color: AppConstants.warningColor),
                const Divider(height: 22),
                _PriorityRow(
                    label: 'Budget/maaltijd',
                    value: budget,
                    color: AppConstants.successColor),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityRow extends StatelessWidget {
  const _PriorityRow(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withValues(alpha: 0.66),
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        child,
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard(
      {required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
