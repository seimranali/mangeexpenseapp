import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';
import '../../../widgets/category_avatar.dart';
import 'spend_pie_chart.dart';

class CategoryRowTile extends StatelessWidget {
  final CategoryTotal data;
  final VoidCallback onTap;

  const CategoryRowTile({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            CategoryAvatar(info: data.category, size: 40),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                data.category.label,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            Text(
              Formatters.money(data.total),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}
