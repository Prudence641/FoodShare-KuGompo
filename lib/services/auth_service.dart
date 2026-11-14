
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  // Firebase services are accessed only when needed.
  // This prevents Firebase initialization errors when
  // the AuthService is created during widget tests.

  FirebaseAuth get _auth => FirebaseAuth.instance;

  FirebaseFirestore get _firestore =>
      FirebaseFirestore.instance;

  // ==========================================
  // REGISTER A NEW USER
  // ==========================================

  Future<UserCredential> registerUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    // Only Donor and Recipient registration is allowed.
    if (role != 'Donor' && role != 'Recipient') {
      throw Exception('Invalid registration role.');
    }

    // Validate registration information.
    if (fullName.trim().isEmpty ||
        email.trim().isEmpty ||
        password.isEmpty) {
      throw Exception(
        'Please complete all registration fields.',
      );
    }

    // Create Firebase Authentication account.
    final credential =
        await _auth.createUserWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = credential.user;

    if (user == null) {
      throw Exception(
        'Account creation failed. Please try again.',
      );
    }

    try {
      // Save user's display name.
      await user.updateDisplayName(fullName.trim());

      // Create the user's Firestore profile.
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'fullName': fullName.trim(),
        'email': email.trim().toLowerCase(),
        'role': role,

        // Recipients do not require donor approval.
        // Donors must be approved by an administrator.
        'isVerified': role == 'Recipient',

        'approvalStatus':
            role == 'Donor' ? 'pending' : 'approved',

        'createdAt': FieldValue.serverTimestamp(),
      });

      return credential;
    } catch (e) {
      // Clean up the Authentication account if
      // creating the Firestore profile fails.
      try {
        await user.delete();
      } catch (_) {
        // Preserve the original registration error.
      }

      rethrow;
    }
  }

  // ==========================================
  // SIGN IN AN EXISTING USER
  // ==========================================

  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  // ==========================================
  // CHECK SECURE ADMIN CUSTOM CLAIM
  // ==========================================

  Future<bool> hasAdminAccess(User user) async {
    final tokenResult = await user.getIdTokenResult(true);

    return tokenResult.claims?['admin'] == true;
  }

  // ==========================================
  // GET USER PROFILE FROM FIRESTORE
  // ==========================================

  Future<Map<String, dynamic>?> getUserProfile(
    String uid,
  ) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  // ==========================================
  // SIGN OUT
  // ==========================================

  Future<void> logout() async {
    await _auth.signOut();
  }
}
