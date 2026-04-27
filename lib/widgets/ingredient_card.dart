import 'package:flutter/material.dart';

import '../models/ingredient.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'tag_chip.dart';

class IngredientCard extends StatelessWidget {
  const IngredientCard({
    super.key,
    required this.ingredient,
    this.onEdit,
    this.onDelete,
  });

  final Ingredient ingredient;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final statusColor =
        app_date_utils.DateUtils.ingredientStatusColor(ingredient);
    final statusLabel =
        app_date_utils.DateUtils.ingredientStatusLabel(ingredient);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  ingredient.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                tooltip: 'Bewerken',
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'delete') onDelete?.call();
                },
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'delete', child: Text('Verwijderen'))
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TagChip(label: ingredient.quantity),
              TagChip(label: ingredient.category),
              TagChip(label: ingredient.storageLocation),
              TagChip(label: ingredient.isOpened ? 'Geopend' : 'Gesloten'),
              TagChip(
                  label: statusLabel,
                  color: statusColor.withValues(alpha: 0.14),
                  textColor: statusColor),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.event_outlined, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                    'Vervalt: ${app_date_utils.DateUtils.formatDate(ingredient.expirationDate)}'),
              ),
              Text(app_date_utils.DateUtils.formatMoney(
                  ingredient.estimatedPrice)),
            ],
          ),
        ],
      ),
    );
  }
}
