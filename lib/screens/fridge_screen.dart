import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_constants.dart';
import '../models/ingredient.dart';
import '../providers/fridge_provider.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/ingredient_card.dart';
import 'add_ingredient_screen.dart';

class FridgeScreen extends StatelessWidget {
  const FridgeScreen({super.key});

  Future<void> _openEditor(BuildContext context, {Ingredient? ingredient}) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => AddIngredientScreen(existingIngredient: ingredient)));
  }

  @override
  Widget build(BuildContext context) {
    final fridge = context.watch<FridgeProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Fridge')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Toevoegen'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AppTextField(
                label: 'Zoek ingrediënten',
                prefixIcon: Icons.search_rounded,
                onChanged: fridge.setSearchQuery,
              ),
              const SizedBox(height: 10),
              _FilterRow(
                label: 'Locatie',
                options: const ['all', 'fridge', 'freezer', 'pantry'],
                value: fridge.storageFilter,
                onChanged: fridge.setStorageFilter,
              ),
              const SizedBox(height: 8),
              _FilterRow(
                label: 'Status',
                options: const ['all', AppConstants.statusExpired, AppConstants.statusToday, AppConstants.statusSoon, AppConstants.statusOkay, AppConstants.statusLong],
                value: fridge.statusFilter,
                onChanged: fridge.setStatusFilter,
              ),
              const SizedBox(height: 14),
              Expanded(
                child: fridge.filteredIngredients.isEmpty
                    ? EmptyState(
                        title: 'Nog geen ingrediënten',
                        subtitle: 'Voeg je eerste producten toe en KotKok AI gaat ze slim gebruiken.',
                        actionLabel: 'Ingrediënt toevoegen',
                        onAction: () => _openEditor(context),
                      )
                    : ListView.builder(
                        itemCount: fridge.filteredIngredients.length,
                        itemBuilder: (context, index) {
                          final ingredient = fridge.filteredIngredients[index];
                          return IngredientCard(
                            ingredient: ingredient,
                            onEdit: () => _openEditor(context, ingredient: ingredient),
                            onDelete: () async {
                              final confirmed = await showDialog<bool>(
                                    context: context,
                                    builder: (_) => AlertDialog(
                                      title: const Text('Ingrediënt verwijderen?'),
                                      content: Text('${ingredient.name} verwijderen uit je koelkast?'),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuleer')),
                                        FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Verwijder')),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (confirmed) {
                                await context.read<FridgeProvider>().deleteIngredient(ingredient.id);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.label, required this.options, required this.value, required this.onChanged});

  final String label;
  final List<String> options;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: options.map((option) {
              final selected = value == option;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(option),
                  selected: selected,
                  onSelected: (_) => onChanged(option),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
