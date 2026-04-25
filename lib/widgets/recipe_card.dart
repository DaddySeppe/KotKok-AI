import 'package:flutter/material.dart';

import '../models/recipe.dart';
import '../utils/date_utils.dart' as app_date_utils;
import 'dashboard_card.dart';
import 'tag_chip.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    this.onTap,
  });

  final Recipe recipe;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DashboardCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  recipe.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              TagChip(label: '${recipe.studentScore}/100'),
            ],
          ),
          const SizedBox(height: 8),
          Text(recipe.description, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TagChip(label: '${recipe.cookingTimeMinutes} min'),
              TagChip(label: '${app_date_utils.DateUtils.formatMoney(recipe.estimatedExtraCost)} extra'),
              TagChip(label: '${recipe.dishCount} bord${recipe.dishCount == 1 ? '' : 'en'}'),
              ...recipe.tags.map((tag) => TagChip(label: tag)),
            ],
          ),
          if (recipe.reason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              recipe.reason,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54),
            ),
          ],
        ],
      ),
    );
  }
}
