import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:marketing_penerbit_jagaddhita/src/core/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getCurrentUserDetails() async {
    final user = _auth.currentUser;
    if (user != null) {
      final docRef = _firestore.collection('users').doc(user.uid);
      final doc = await docRef.get();

      if (doc.exists) {
        final userData = doc.data()!;
        // Sync photo URL if missing in Firestore but present in Auth
        if (userData['photo_url'] == null && user.photoURL != null) {
          await docRef.update({'photo_url': user.photoURL});
          userData['photo_url'] = user.photoURL; // Update local map
        }
        return UserModel.fromMap(userData, doc.id);
      } else {
        // Fallback: Create user doc if it doesn't exist (Lazy creation)
        String role = 'marketing';
        if ((user.email ?? '').toLowerCase().startsWith('admin')) {
          role = 'admin';
        }

        final newUser = UserModel(
          id: user.uid,
          email: user.email ?? '',
          role: role,
          name: (user.email ?? 'User').split('@')[0], // Default name from email
          createdAt: DateTime.now(),
        );

        // Use set() with merge: true just in case, though doc doesn't exist
        await docRef.set({
          'email': newUser.email,
          'role': newUser.role,
          'name': newUser.name,
          'created_at': FieldValue.serverTimestamp(),
        });

        return newUser;
      }
    }
    return null;
  }

  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp(
    String email,
    String password,
    String role, {
    String? username,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (cred.user != null) {
      // Create user doc
      await _firestore.collection('users').doc(cred.user!.uid).set({
        'email': email,
        'role': 'marketing', // Enforce default role for security
        'username': username,
        'name': username, // Default name to username
        'created_at': FieldValue.serverTimestamp(),
      });
    }
    return cred;
  }

  bool _googleSignInInitialized = false;

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) return;
    await GoogleSignIn.instance.initialize(
      clientId: kIsWeb
          ? '55240641303-hpr2olfa9i3jfpou3gqo1lvqlibjprna.apps.googleusercontent.com'
          : null,
      serverClientId: kIsWeb
          ? null
          : '55240641303-hpr2olfa9i3jfpou3gqo1lvqlibjprna.apps.googleusercontent.com',
    );
    _googleSignInInitialized = true;
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      UserCredential userCredential;
      
      if (kIsWeb) {
        // Use Firebase Auth's built-in popup for Web (GIS compliant)
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // Use google_sign_in package for Android/iOS
        await _ensureGoogleSignInInitialized();
        final googleUser = await GoogleSignIn.instance.authenticate();

        final googleAuth = googleUser.authentication;
        final authorizedUser = await googleUser.authorizationClient.authorizeScopes([
          'email',
          'profile',
        ]);
        final accessToken = authorizedUser.accessToken;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // Check/Create User Doc
      if (userCredential.user != null) {
        final user = userCredential.user!;
        final docRef = _firestore.collection('users').doc(user.uid);
        final doc = await docRef.get();

        if (!doc.exists) {
          String role = 'marketing';
          if ((user.email ?? '').toLowerCase().startsWith('admin')) {
            role = 'admin';
          }

          await docRef.set({
            'email': user.email ?? '',
            'role': role,
            'name': user.displayName ?? (user.email ?? 'User').split('@')[0],
            'photo_url': user.photoURL,
            'created_at': FieldValue.serverTimestamp(),
          });
        }
      }
      return userCredential;
    } catch (e) {
      debugPrint('Google Sign-In failed or canceled: $e');
      throw Exception('Google Sign-In failed: $e');
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      // 1. Delete Firestore Data
      await _firestore.collection('users').doc(user.uid).delete();
      // 2. Delete Auth Account
      await user.delete();
    }
  }
}
