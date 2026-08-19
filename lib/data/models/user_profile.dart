import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String? displayName;
  final String? email;
  final String currencySymbol;
  final DateTime createdAt;

  const UserProfile({
    required this.uid,
    required this.createdAt,
    this.displayName,
    this.email,
    this.currencySymbol = '\$',
  });

  factory UserProfile.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserProfile(
      uid: doc.id,
      displayName: data['displayName'] as String?,
      email: data['email'] as String?,
      currencySymbol: data['currencySymbol'] as String? ?? '\$',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'displayName': displayName,
    'email': email,
    'currencySymbol': currencySymbol,
    'createdAt': Timestamp.fromDate(createdAt),
  };
}
