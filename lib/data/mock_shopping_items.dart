import '../models/shopping_item.dart';

class MockShoppingItems {
  static final items = <ShoppingItem>[
    ShoppingItem(id: 'shop-1', userId: null, name: 'room', estimatedPrice: 1.20, isBought: false, createdAt: DateTime.now()),
    ShoppingItem(id: 'shop-2', userId: null, name: 'ui', estimatedPrice: 0.50, isBought: false, createdAt: DateTime.now()),
    ShoppingItem(id: 'shop-3', userId: null, name: 'look', estimatedPrice: 0.70, isBought: false, createdAt: DateTime.now()),
    ShoppingItem(id: 'shop-4', userId: null, name: 'brood', estimatedPrice: 2.10, isBought: false, createdAt: DateTime.now()),
    ShoppingItem(id: 'shop-5', userId: null, name: 'rijst', estimatedPrice: 2.30, isBought: true, createdAt: DateTime.now()),
    ShoppingItem(id: 'shop-6', userId: null, name: 'tomatensaus', estimatedPrice: 1.60, isBought: false, createdAt: DateTime.now()),
    ShoppingItem(id: 'shop-7', userId: null, name: 'kruiden', estimatedPrice: 1.00, isBought: false, createdAt: DateTime.now()),
    ShoppingItem(id: 'shop-8', userId: null, name: 'mozzarella', estimatedPrice: 1.80, isBought: false, createdAt: DateTime.now()),
  ];
}
