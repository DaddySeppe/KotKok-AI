import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/fridge_provider.dart';
import '../providers/recipe_provider.dart';
import '../services/recipe_recommendation_service.dart';
import '../widgets/empty_state.dart';
import '../widgets/recipe_card.dart';
import 'recipe_detail_screen.dart';

class RecipeRecommendationsScreen extends StatelessWidget {
  const RecipeRecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fridge = context.watch<FridgeProvider>();
    final recipes = context.watch<RecipeProvider>();
    final service = RecipeRecommendationService();
    final recommendations = service.buildRecommendations(fridge.ingredients, recipes.savedRecipes);

    return Scaffold(
      appBar: AppBar(title: const Text('Recepten')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Slimme aanbevelingen', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (recommendations.isEmpty)
              const EmptyState(title: 'Geen recepten gevonden', subtitle: 'Voeg ingrediënten toe zodat KotKok AI iets slims kan voorstellen.')
            else
              ...recommendations.map(
                (recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: RecipeCard(
                    recipe: recipe,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text('Opgeslagen AI recepten', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            if (recipes.savedRecipes.isEmpty)
              const EmptyState(title: 'Nog geen AI recepten', subtitle: 'Maak een slim AI-recept aan voor een gepersonaliseerde suggestie.')
            else
              ...recipes.savedRecipes.take(5).map(
                (recipe) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: RecipeCard(
                    recipe: recipe,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe))),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
