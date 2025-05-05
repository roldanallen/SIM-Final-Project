import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:software_development/services/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Collection reference
  final CollectionReference usersRef = FirebaseFirestore.instance.collection('userData');

  /// Save user data to Firestore using UID as document ID
  Future<void> createUser(UserModel user) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception("User UID not found");

      // Use uid as document ID
      await usersRef.doc(uid).set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user in Firestore: $e');
    }
  }

  /// Get user data by email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await usersRef.where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromMap(querySnapshot.docs.first.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }
}
