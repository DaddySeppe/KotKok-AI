import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../models/recipe.dart';
import '../providers/fridge_provider.dart';
import '../providers/preferences_provider.dart';
import '../providers/recipe_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/app_button.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/tag_chip.dart';
import 'recipe_detail_screen.dart';

class AiRecipeScreen extends StatefulWidget {
  const AiRecipeScreen({super.key});

  @override
  State<AiRecipeScreen> createState() => _AiRecipeScreenState();
}

class _AiRecipeScreenState extends State<AiRecipeScreen> {
  String _mood = AppConstants.moods.first;
  String _dietaryPreference = AppConstants.dietaryPreferences.first;
  String _effortLevel = AppConstants.effortLevels.first;
  String _dishPreference = AppConstants.dishLevels.first;
  int _time = 15;
  double _budget = 4.5;
  final Set<String> _selectedAllergies = {};
  Recipe? _generatedRecipe;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final preferences = context.read<PreferencesProvider>().preferences;
    _time = preferences.defaultCookingTime;
    _budget = preferences.maxBudgetPerMeal;
    _initialized = true;
  }

  Future<void> _generate() async {
    final fridge = context.read<FridgeProvider>();
    final recipes = context.read<RecipeProvider>();
    final stats = context.read<StatsProvider>();

    final result = await recipes.generateAiRecipe(
      ingredients: fridge.ingredients,
      budget: _budget,
      allergies: _selectedAllergies.toList(),
      dietaryPreferences: [_dietaryPreference],
      cookingTimeMinutes: _time,
      mood: _mood,
      effortLevel: _effortLevel,
      dishCountPreference: _dishPreference,
    );

    if (!mounted) return;
    setState(() => _generatedRecipe = result);
    if (result != null) {
      stats.addAiRecipeGenerated();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI recept gegenereerd')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipes = context.watch<RecipeProvider>();
    if (recipes.isGenerating) {
      return Scaffold(
        appBar: AppBar(title: const Text('Maak een slim AI-recept')),
        body: const LoadingView(message: 'KotKok AI denkt slim voor je...'),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Maak een slim AI-recept')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Een recept dat past bij je koelkast, budget, tijd en mood.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 18),
            _Section(title: 'Mood', child: Wrap(spacing: 8, runSpacing: 8, children: AppConstants.moods.map((mood) => ChoiceChip(label: Text(mood), selected: _mood == mood, onSelected: (_) => setState(() => _mood = mood))).toList())),
            const SizedBox(height: 12),
            _Section(title: 'Kooktijd: $_time min', child: Slider(value: _time.toDouble(), min: 5, max: 30, divisions: 5, label: '$_time min', onChanged: (value) => setState(() => _time = value.round()))),
            const SizedBox(height: 12),
            _Section(title: 'Budget: €${_budget.toStringAsFixed(2)}', child: Slider(value: _budget, min: 0, max: 10, divisions: 20, label: '€${_budget.toStringAsFixed(2)}', onChanged: (value) => setState(() => _budget = value))),
            const SizedBox(height: 12),
            _Section(title: 'Dieet', child: Wrap(spacing: 8, runSpacing: 8, children: AppConstants.dietaryPreferences.map((value) => ChoiceChip(label: Text(value), selected: _dietaryPreference == value, onSelected: (_) => setState(() => _dietaryPreference = value))).toList())),
            const SizedBox(height: 12),
            _Section(
              title: 'Allergieën',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppConstants.allergies.map((allergy) {
                  final selected = _selectedAllergies.contains(allergy);
                  return FilterChip(
                    label: Text(allergy),
                    selected: selected,
                    onSelected: (_) {
                      setState(() {
                        if (selected) {
                          _selectedAllergies.remove(allergy);
                        } else {
                          _selectedAllergies.add(allergy);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),
            _Section(title: 'Effort level', child: Wrap(spacing: 8, runSpacing: 8, children: AppConstants.effortLevels.map((value) => ChoiceChip(label: Text(value), selected: _effortLevel == value, onSelected: (_) => setState(() => _effortLevel = value))).toList())),
            const SizedBox(height: 12),
            _Section(title: 'Afwas', child: Wrap(spacing: 8, runSpacing: 8, children: AppConstants.dishLevels.map((value) => ChoiceChip(label: Text(value), selected: _dishPreference == value, onSelected: (_) => setState(() => _dishPreference = value))).toList())),
            const SizedBox(height: 12),
            AppButton(label: 'Genereer AI recept', onPressed: _generate, icon: Icons.auto_awesome_rounded),
            const SizedBox(height: 16),
            if (recipes.errorMessage != null) ...[
              ErrorView(message: recipes.errorMessage!, onRetry: _generate),
              const SizedBox(height: 12),
            ],
            if (_generatedRecipe != null) ...[
              DashboardCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_generatedRecipe!.title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text(_generatedRecipe!.description),
                    const SizedBox(height: 8),
                    Wrap(spacing: 8, runSpacing: 8, children: _generatedRecipe!.tags.map((tag) => TagChip(label: tag)).toList()),
                    const SizedBox(height: 10),
                    Text(_generatedRecipe!.reason),
                    const SizedBox(height: 10),
                    AppButton(label: 'Bewaar recept', onPressed: () {
                      context.read<RecipeProvider>().saveRecipe(_generatedRecipe!);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI recept opgeslagen')));
                    }, icon: Icons.bookmark_rounded),
                    const SizedBox(height: 8),
                    AppButton(label: 'Open detail', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: _generatedRecipe!))), icon: Icons.open_in_new_rounded),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
