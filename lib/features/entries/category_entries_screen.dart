import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/categories.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/entry.dart';
import '../../providers/app_providers.dart';
import '../../widgets/empty_state.dart';

class CategoryEntriesScreen extends ConsumerWidget {
  final String categoryId;

  const CategoryEntriesScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = categoryById(categoryId);
    final entriesAsync = ref.watch(entriesForCategoryProvider(categoryId));

    return Scaffold(
      appBar: AppBar(title: Text(info.label)),
      body: entriesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Something went wrong: $e')),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.inbox_rounded,
              title: 'No entries yet',
              message: 'Tap the + button to add your first entry here.',
            );
          }
          final total = entries.fold<double>(0, (a, e) => a + e.amount);
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
            itemCount: entries.length + 1,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        Formatters.money(total),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                );
              }
              final entry = entries[i - 1];
              return _EntryTile(entry: entry, categoryId: categoryId);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/entry/new?category=$categoryId'),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }
}

class _EntryTile extends ConsumerWidget {
  final Entry entry;
  final String categoryId;

  const _EntryTile({required this.entry, required this.categoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(Formatters.money(entry.amount)),
      subtitle: Text(
        [
          Formatters.dayMonthYear.format(entry.date),
          if (entry.recipient != null && entry.recipient!.isNotEmpty)
            entry.recipient!,
          if (entry.note != null && entry.note!.isNotEmpty) entry.note!,
        ].join(' · '),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == 'edit') {
            context.push('/entry/${entry.id}?category=$categoryId');
          } else if (value == 'delete') {
            final uid = ref.read(currentUidProvider);
            if (uid != null) {
              await ref
                  .read(entryRepositoryProvider)
                  .deleteEntry(uid, entry.id);
            }
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(value: 'edit', child: Text('Edit')),
          PopupMenuItem(value: 'delete', child: Text('Delete')),
        ],
      ),
    );
  }
}
