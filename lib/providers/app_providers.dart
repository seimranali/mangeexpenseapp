import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/budget.dart';
import '../data/models/entry.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/budget_repository.dart';
import '../data/repositories/entry_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final entryRepositoryProvider = Provider<EntryRepository>(
  (ref) => EntryRepository(),
);

final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => BudgetRepository(),
);

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges();
});

/// Convenience provider exposing the current signed-in uid, or null.
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});

/// Selected month for dashboard/reports, defaults to the current month.
final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final entriesForSelectedMonthProvider = StreamProvider<List<Entry>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  final month = ref.watch(selectedMonthProvider);
  final from = DateTime(month.year, month.month);
  final to = DateTime(month.year, month.month + 1);
  return ref
      .watch(entryRepositoryProvider)
      .watchEntries(uid, from: from, to: to);
});

final budgetsProvider = StreamProvider<List<Budget>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(budgetRepositoryProvider).watchBudgets(uid);
});

/// Entries across the trailing 6 months (inclusive of the current month),
/// used to power the reports trend chart.
final entriesLast6MonthsProvider = StreamProvider<List<Entry>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return const Stream.empty();
  final now = DateTime.now();
  final from = DateTime(now.year, now.month - 5);
  return ref.watch(entryRepositoryProvider).watchEntries(uid, from: from);
});

final entriesForCategoryProvider =
    StreamProvider.family<List<Entry>, String>((ref, categoryId) {
      final uid = ref.watch(currentUidProvider);
      if (uid == null) return const Stream.empty();
      return ref
          .watch(entryRepositoryProvider)
          .watchEntries(uid, categoryId: categoryId);
    });
