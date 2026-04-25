import 'package:flutter/material.dart';

import '../models/shopping_item.dart';
import '../utils/date_utils.dart' as app_date_utils;

class ShoppingItemTile extends StatelessWidget {
  const ShoppingItemTile({
    super.key,
    required this.item,
    required this.onChanged,
    this.onDelete,
  });

  final ShoppingItem item;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      tileColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Checkbox(value: item.isBought, onChanged: (value) => onChanged(value ?? false)),
      title: Text(item.name, style: TextStyle(decoration: item.isBought ? TextDecoration.lineThrough : null)),
      subtitle: Text(app_date_utils.DateUtils.formatMoney(item.estimatedPrice)),
      trailing: IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: onDelete),
    );
  }
}
