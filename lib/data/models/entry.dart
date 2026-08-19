import 'package:cloud_firestore/cloud_firestore.dart';

class Entry {
  final String id;
  final String categoryId;
  final double amount;
  final DateTime date;
  final String? note;
  final String? recipient;
  final DateTime createdAt;

  const Entry({
    required this.id,
    required this.categoryId,
    required this.amount,
    required this.date,
    required this.createdAt,
    this.note,
    this.recipient,
  });

  factory Entry.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Entry(
      id: doc.id,
      categoryId: data['categoryId'] as String,
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] as String?,
      recipient: data['recipient'] as String?,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'categoryId': categoryId,
    'amount': amount,
    'date': Timestamp.fromDate(date),
    'note': note,
    'recipient': recipient,
    'createdAt': Timestamp.fromDate(createdAt),
  };

  Entry copyWith({
    String? categoryId,
    double? amount,
    DateTime? date,
    String? note,
    String? recipient,
  }) {
    return Entry(
      id: id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      note: note ?? this.note,
      recipient: recipient ?? this.recipient,
      createdAt: createdAt,
    );
  }
}
