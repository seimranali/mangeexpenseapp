import 'package:cloud_firestore/cloud_firestore.dart';

/// A monthly spending limit for a single category. Document id == categoryId.
class Budget {
  final String categoryId;
  final double monthlyLimit;
  final DateTime updatedAt;

  const Budget({
    required this.categoryId,
    required this.monthlyLimit,
    required this.updatedAt,
  });

  factory Budget.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Budget(
      categoryId: doc.id,
      monthlyLimit: (data['monthlyLimit'] as num).toDouble(),
      updatedAt:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'monthlyLimit': monthlyLimit,
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
