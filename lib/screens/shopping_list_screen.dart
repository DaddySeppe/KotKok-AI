import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../models/ingredient.dart';
import '../providers/fridge_provider.dart';
import '../providers/shopping_list_provider.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../utils/validators.dart';
import '../widgets/app_text_field.dart';
import '../widgets/empty_state.dart';
import '../widgets/shopping_item_tile.dart';

class ShoppingListScreen extends StatelessWidget {
  const ShoppingListScreen({super.key});

  Future<void> _addItem(BuildContext context) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Item toevoegen'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(label: 'Naam', controller: nameController, validator: (value) => Validators.requiredField(value, label: 'Naam')),
              const SizedBox(height: 12),
              AppTextField(label: 'Geschatte prijs', controller: priceController, validator: Validators.price, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Annuleer')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Voeg toe')),
        ],
      ),
    );

    if (result != true) return;
    await context.read<ShoppingListProvider>().addItem(
          nameController.text.trim(),
          estimatedPrice: double.tryParse(priceController.text.replaceAll(',', '.')) ?? 0,
        );
  }

  Future<void> _toggleBought(BuildContext context, String id, bool newValue, String name, double price) async {
    await context.read<ShoppingListProvider>().toggleBought(id);
    if (!newValue) return;

    final addToFridge = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Toevoegen aan koelkast?'),
            content: Text('Wil je $name ook toevoegen aan je koelkastinventaris?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Nee')),
              FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ja')),
            ],
          ),
        ) ??
        false;

    if (!addToFridge) return;

    await context.read<FridgeProvider>().addIngredient(
          Ingredient(
            id: const Uuid().v4(),
            userId: null,
            name: name,
            category: 'Overig',
            quantity: '1 stuk',
            expirationDate: DateTime.now().add(const Duration(days: 5)),
            estimatedPrice: price,
            isOpened: false,
            storageLocation: 'fridge',
            createdAt: DateTime.now(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final shopping = context.watch<ShoppingListProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Boodschappen'),
        actions: [
          TextButton(
            onPressed: shopping.boughtItems.isEmpty ? null : () => shopping.clearBoughtItems(),
            child: const Text('Wis gekocht'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addItem(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Toevoegen'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Geschatte totale kost: ${app_date_utils.DateUtils.formatMoney(shopping.totalEstimatedCost)}'),
            const SizedBox(height: 14),
            if (shopping.items.isEmpty)
              const EmptyState(title: 'Lege boodschappenlijst', subtitle: 'Voeg ontbrekende ingrediënten toe vanuit een recept of handmatig.')
            else
              ...shopping.items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ShoppingItemTile(
                    item: item,
                    onChanged: (value) => _toggleBought(context, item.id, value, item.name, item.estimatedPrice),
                    onDelete: () => shopping.deleteItem(item.id),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
