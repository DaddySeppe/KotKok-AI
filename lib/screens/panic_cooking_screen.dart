import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../providers/fridge_provider.dart';
import '../providers/recipe_provider.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/recipe_card.dart';
import '../widgets/tag_chip.dart';
import 'recipe_detail_screen.dart';

class PanicCookingScreen extends StatefulWidget {
  const PanicCookingScreen({super.key});

  @override
  State<PanicCookingScreen> createState() => _PanicCookingScreenState();
}

class _PanicCookingScreenState extends State<PanicCookingScreen> {
  int _maxTime = 10;
  String _effort = AppConstants.effortLevels.first;
  String _dishes = AppConstants.dishLevels.first;
  String _budget = AppConstants.budgetLabels.first;

  double get _budgetLimit {
    switch (_budget) {
      case '€0 extra':
        return 0;
      case 'onder €3':
        return 3;
      default:
        return double.infinity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fridge = context.watch<FridgeProvider>();
    final recipes = context.watch<RecipeProvider>();
    final suggestions = recipes.panicSuggestions(fridge.ingredients)
        .where((recipe) => recipe.cookingTimeMinutes <= _maxTime && recipe.estimatedExtraCost <= _budgetLimit)
        .where((recipe) {
          if (_effort == 'bijna niks') return recipe.cookingTimeMinutes <= 10;
          if (_effort == 'oké vooruit') return recipe.cookingTimeMinutes <= 20;
          return true;
        })
        .where((recipe) {
          if (_dishes == 'geen afwas') return recipe.dishCount <= 1;
          if (_dishes == 'één pan') return recipe.dishCount <= 2;
          return true;
        })
        .take(3)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Geen zin om te koken?')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Kies hoe weinig moeite je wilt doen. KotKok AI regelt de rest.', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 18),
            _Selector(title: 'Maximale tijd', child: Wrap(spacing: 8, children: AppConstants.timeOptions.map((minutes) => ChoiceChip(label: Text('$minutes min'), selected: _maxTime == minutes, onSelected: (_) => setState(() => _maxTime = minutes))).toList())),
            const SizedBox(height: 12),
            _Selector(title: 'Effort level', child: Wrap(spacing: 8, children: AppConstants.effortLevels.map((value) => ChoiceChip(label: Text(value), selected: _effort == value, onSelected: (_) => setState(() => _effort = value))).toList())),
            const SizedBox(height: 12),
            _Selector(title: 'Afwas', child: Wrap(spacing: 8, children: AppConstants.dishLevels.map((value) => ChoiceChip(label: Text(value), selected: _dishes == value, onSelected: (_) => setState(() => _dishes = value))).toList())),
            const SizedBox(height: 12),
            _Selector(title: 'Budget', child: Wrap(spacing: 8, children: AppConstants.budgetLabels.map((value) => ChoiceChip(label: Text(value), selected: _budget == value, onSelected: (_) => setState(() => _budget = value))).toList())),
            const SizedBox(height: 18),
            if (suggestions.isEmpty)
              const DashboardCard(child: Text('Geen perfecte match, maar kijk in je recepten-tab voor de beste beschikbare optie.'))
            else
              ...suggestions.map((recipe) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: RecipeCard(recipe: recipe, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => RecipeDetailScreen(recipe: recipe)))),
                  )),
            const SizedBox(height: 6),
            Text('Waarom dit werkt', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                TagChip(label: 'snel'),
                TagChip(label: 'weinig afwas'),
                TagChip(label: 'goedkoop'),
                TagChip(label: 'restjes redden'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Selector extends StatelessWidget {
  const _Selector({required this.title, required this.child});

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
