import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/entry.dart';

class EntryRepository {
  final FirebaseFirestore _firestore;

  EntryRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _collection(String uid) =>
      _firestore.collection('users').doc(uid).collection('entries');

  Stream<List<Entry>> watchEntries(
    String uid, {
    DateTime? from,
    DateTime? to,
    String? categoryId,
  }) {
    Query<Map<String, dynamic>> query = _collection(uid);
    if (from != null) {
      query = query.where(
        'date',
        isGreaterThanOrEqualTo: Timestamp.fromDate(from),
      );
    }
    if (to != null) {
      query = query.where('date', isLessThan: Timestamp.fromDate(to));
    }
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    query = query.orderBy('date', descending: true);

    return query.snapshots().map(
      (snap) => snap.docs.map(Entry.fromFirestore).toList(),
    );
  }

  Future<Entry?> getEntry(String uid, String entryId) async {
    final doc = await _collection(uid).doc(entryId).get();
    if (!doc.exists) return null;
    return Entry.fromFirestore(doc);
  }

  Future<void> addEntry(String uid, Entry entry) {
    return _collection(uid).doc(entry.id).set(entry.toFirestore());
  }

  Future<void> updateEntry(String uid, Entry entry) {
    return _collection(uid).doc(entry.id).update(entry.toFirestore());
  }

  Future<void> deleteEntry(String uid, String entryId) {
    return _collection(uid).doc(entryId).delete();
  }
}
