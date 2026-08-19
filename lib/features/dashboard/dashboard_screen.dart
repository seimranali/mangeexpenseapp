import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/categories.dart';
import '../../core/utils/formatters.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_card.dart';
import 'widgets/category_row_tile.dart';
import 'widgets/spend_pie_chart.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesForSelectedMonthProvider);
    final month = ref.watch(selectedMonthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Overview'),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                DateTime(month.year, month.month - 1),
          ),
          Center(
            child: Text(
              Formatters.monthYear.format(month),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: () => ref.read(selectedMonthProvider.notifier).state =
                DateTime(month.year, month.month + 1),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong: $e')),
        data: (entries) {
          final totalsByCategory = <String, double>{};
          for (final e in entries) {
            totalsByCategory[e.categoryId] =
                (totalsByCategory[e.categoryId] ?? 0) + e.amount;
          }
          final grandTotal = totalsByCategory.values.fold<double>(
            0,
            (a, b) => a + b,
          );
          final totals =
              totalsByCategory.entries
                  .map((e) => CategoryTotal(categoryById(e.key), e.value))
                  .toList()
                ..sort((a, b) => b.total.compareTo(a.total));

          if (entries.isEmpty) {
            return ListView(
              children: const [
                SizedBox(height: 60),
                EmptyState(
                  icon: Icons.receipt_long_rounded,
                  title: 'No entries yet this month',
                  message:
                      'Tap the + button to log your first household expense.',
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            children: [
              SectionCard(
                child: Column(
                  children: [
                    Text(
                      'Total spent',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      Formatters.money(grandTotal),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontSize: 32),
                    ),
                    const SizedBox(height: 12),
                    SpendPieChart(totals: totals, grandTotal: grandTotal),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    for (final t in totals)
                      CategoryRowTile(
                        data: t,
                        onTap: () =>
                            context.push('/category/${t.category.id}'),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
