import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/categories.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/category_avatar.dart';
import '../../widgets/section_card.dart';

class BudgetsScreen extends ConsumerWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesForSelectedMonthProvider);
    final budgetsAsync = ref.watch(budgetsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong: $e')),
        data: (entries) {
          final spentByCategory = <String, double>{};
          for (final e in entries) {
            spentByCategory[e.categoryId] =
                (spentByCategory[e.categoryId] ?? 0) + e.amount;
          }
          final budgetByCategory = {
            for (final b in budgetsAsync.value ?? [])
              b.categoryId: b.monthlyLimit,
          };

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: kCategories.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final info = kCategories[i];
              final spent = spentByCategory[info.id] ?? 0;
              final limit = budgetByCategory[info.id];
              return _BudgetTile(info: info, spent: spent, limit: limit);
            },
          );
        },
      ),
    );
  }
}

class _BudgetTile extends ConsumerWidget {
  final CategoryInfo info;
  final double spent;
  final double? limit;

  const _BudgetTile({required this.info, required this.spent, this.limit});

  Future<void> _editLimit(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: limit != null ? limit!.toStringAsFixed(0) : '',
    );
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${info.label} budget'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Monthly limit',
            prefixText: '\$ ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final value = double.tryParse(controller.text.trim());
              Navigator.pop(context, value);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result > 0) {
      final uid = ref.read(currentUidProvider);
      if (uid != null) {
        await ref.read(budgetRepositoryProvider).setBudget(
          uid,
          info.id,
          result,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final progress = (limit != null && limit! > 0)
        ? (spent / limit!).clamp(0.0, 1.5)
        : null;
    final overBudget = progress != null && progress > 1.0;

    return SectionCard(
      child: InkWell(
        onTap: () => _editLimit(context, ref),
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CategoryAvatar(info: info, size: 40),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    info.label,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Text(
                  limit != null
                      ? '${Formatters.money(spent)} / ${Formatters.money(limit!)}'
                      : Formatters.money(spent),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            if (progress != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 8,
                  backgroundColor: scheme.surfaceContainerHighest,
                  color: overBudget ? scheme.error : info.color,
                ),
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                'Tap to set a monthly budget',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: scheme.outline),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
