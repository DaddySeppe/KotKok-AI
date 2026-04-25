import '../models/ingredient.dart';

class MockIngredients {
  static final items = <Ingredient>[
    Ingredient(id: 'ing-1', userId: null, name: 'kipfilet', category: 'Vlees', quantity: '2 filets', expirationDate: DateTime.now().add(const Duration(days: 1)), estimatedPrice: 5.50, isOpened: false, storageLocation: 'fridge', createdAt: DateTime.now()),
    Ingredient(id: 'ing-2', userId: null, name: 'paprika', category: 'Groenten', quantity: '2 stuks', expirationDate: DateTime.now().add(const Duration(days: 2)), estimatedPrice: 1.80, isOpened: true, storageLocation: 'fridge', createdAt: DateTime.now()),
    Ingredient(id: 'ing-3', userId: null, name: 'pasta', category: 'Granen', quantity: '500 g', expirationDate: DateTime.now().add(const Duration(days: 120)), estimatedPrice: 1.20, isOpened: false, storageLocation: 'pantry', createdAt: DateTime.now()),
    Ingredient(id: 'ing-4', userId: null, name: 'kaas', category: 'Zuivel', quantity: '200 g', expirationDate: DateTime.now().add(const Duration(days: 4)), estimatedPrice: 2.90, isOpened: true, storageLocation: 'fridge', createdAt: DateTime.now()),
    Ingredient(id: 'ing-5', userId: null, name: 'eieren', category: 'Zuivel', quantity: '6 stuks', expirationDate: DateTime.now().add(const Duration(days: 3)), estimatedPrice: 2.60, isOpened: false, storageLocation: 'fridge', createdAt: DateTime.now()),
    Ingredient(id: 'ing-6', userId: null, name: 'melk', category: 'Zuivel', quantity: '1 liter', expirationDate: DateTime.now().subtract(const Duration(days: 1)), estimatedPrice: 1.10, isOpened: true, storageLocation: 'fridge', createdAt: DateTime.now()),
    Ingredient(id: 'ing-7', userId: null, name: 'wraps', category: 'Brood', quantity: '6 stuks', expirationDate: DateTime.now().add(const Duration(days: 10)), estimatedPrice: 2.20, isOpened: true, storageLocation: 'pantry', createdAt: DateTime.now()),
    Ingredient(id: 'ing-8', userId: null, name: 'tomaten', category: 'Groenten', quantity: '4 stuks', expirationDate: DateTime.now().add(const Duration(days: 2)), estimatedPrice: 2.10, isOpened: false, storageLocation: 'fridge', createdAt: DateTime.now()),
    Ingredient(id: 'ing-9', userId: null, name: 'rijst', category: 'Granen', quantity: '1 kg', expirationDate: DateTime.now().add(const Duration(days: 200)), estimatedPrice: 2.30, isOpened: false, storageLocation: 'pantry', createdAt: DateTime.now()),
    Ingredient(id: 'ing-10', userId: null, name: 'yoghurt', category: 'Zuivel', quantity: '500 g', expirationDate: DateTime.now().add(const Duration(days: 3)), estimatedPrice: 1.40, isOpened: true, storageLocation: 'fridge', createdAt: DateTime.now()),
    Ingredient(id: 'ing-11', userId: null, name: 'sla', category: 'Groenten', quantity: '1 zak', expirationDate: DateTime.now().add(const Duration(days: 1)), estimatedPrice: 1.30, isOpened: true, storageLocation: 'fridge', createdAt: DateTime.now()),
    Ingredient(id: 'ing-12', userId: null, name: 'ham', category: 'Vlees', quantity: '150 g', expirationDate: DateTime.now().add(const Duration(days: 2)), estimatedPrice: 2.40, isOpened: true, storageLocation: 'fridge', createdAt: DateTime.now()),
  ];
}
