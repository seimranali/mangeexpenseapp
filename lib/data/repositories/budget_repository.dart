import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/budget.dart';

class BudgetRepository {
  final FirebaseFirestore _firestore;

  BudgetRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('budgets');

  Stream<List<Budget>> watchBudgets(String uid) {
    return _collection(
      uid,
    ).snapshots().map((snap) => snap.docs.map(Budget.fromFirestore).toList());
  }

  Future<void> setBudget(String uid, String categoryId, double monthlyLimit) {
    return _collection(uid).doc(categoryId).set({
      'monthlyLimit': monthlyLimit,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> deleteBudget(String uid, String categoryId) {
    return _collection(uid).doc(categoryId).delete();
  }
}
