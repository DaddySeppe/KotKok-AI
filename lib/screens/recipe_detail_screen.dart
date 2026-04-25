import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe.dart';
import '../providers/fridge_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/tag_chip.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key, required this.recipe});

  final Recipe recipe;

  Future<void> _cookRecipe(BuildContext context) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Kook dit recept?'),
            content: Text('Wil je ${recipe.title} vandaag koken en de gebruikte ingrediënten afboeken?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuleer')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ja, koken')),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final fridge = context.read<FridgeProvider>();
    final shopping = context.read<ShoppingListProvider>();
    final stats = context.read<StatsProvider>();

    await fridge.consumeIngredients(recipe.usesExpiringIngredients);
    await shopping.addItemsFromRecipe(recipe.missingIngredients);
    stats.addMealCooked();
    stats.addProductsSaved(recipe.usesExpiringIngredients.isEmpty ? 1 : recipe.usesExpiringIngredients.length);
    stats.addMoneySaved(recipe.estimatedExtraCost + 1.20);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recept gekookt en koelkast bijgewerkt')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final fridge = context.watch<FridgeProvider>();
    final recipeProvider = context.watch<RecipeProvider>();
    final usedFromFridge = recipe.requiredIngredients
        .where((ingredient) => fridge.ingredients.any((item) => item.name.toLowerCase() == ingredient.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(recipe.description, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            Text(recipe.reason.isNotEmpty ? recipe.reason : 'KotKok AI raadt dit aan omdat het goedkoop, simpel en waste-friendly is.'),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                TagChip(label: '${recipe.cookingTimeMinutes} min'),
                TagChip(label: recipe.difficulty),
                TagChip(label: '€${recipe.estimatedExtraCost.toStringAsFixed(2)} extra'),
                TagChip(label: '${recipe.dishCount} bord${recipe.dishCount == 1 ? '' : 'en'}'),
              ],
            ),
            const SizedBox(height: 18),
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ingrediënten uit je koelkast', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  if (usedFromFridge.isEmpty)
                    const Text('Geen directe matches gevonden, maar het recept blijft goedkoop en simpel.')
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: usedFromFridge.map((ingredient) => TagChip(label: ingredient)).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ontbrekende ingrediënten', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  recipe.missingIngredients.isEmpty
                      ? const Text('Niks extra nodig. Mooi.')
                      : Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: recipe.missingIngredients.map((ingredient) => TagChip(label: ingredient)).toList(),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            DashboardCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Stappen', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  ...recipe.steps.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text('${entry.key + 1}. ${entry.value}'),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _StatCard(label: 'Student', value: recipe.studentScore.toString())),
                const SizedBox(width: 12),
                Expanded(child: _StatCard(label: 'Waste', value: recipe.wasteSavingScore.toString())),
              ],
            ),
            const SizedBox(height: 16),
            AppButton(label: 'Kook dit', onPressed: () => _cookRecipe(context), icon: Icons.restaurant_rounded),
            const SizedBox(height: 10),
            AppButton(
              label: 'Voeg ontbrekende ingrediënten toe',
              onPressed: () async {
                await context.read<ShoppingListProvider>().addItemsFromRecipe(recipe.missingIngredients);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ontbrekende ingrediënten toegevoegd')));
                }
              },
              icon: Icons.shopping_cart_checkout_rounded,
            ),
            const SizedBox(height: 10),
            AppButton(
              label: 'Bewaar recept',
              onPressed: () {
                recipeProvider.saveRecipe(recipe);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recept opgeslagen')));
              },
              icon: Icons.bookmark_add_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        children: [
          Text(label),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
