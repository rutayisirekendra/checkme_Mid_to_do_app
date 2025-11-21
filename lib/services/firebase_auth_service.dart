import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart' as app_models;
import 'database_service.dart';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stream of auth state changes
  static Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Current Firebase user
  static User? get currentFirebaseUser => _auth.currentUser;
  
  // Convert Firebase user to app user model
  static Future<app_models.User?> convertToAppUser(User? firebaseUser) async {
    try {
      if (firebaseUser == null) return null;
      
      // Check if user exists in local database
      var appUser = DatabaseService.getUserById(firebaseUser.uid);
      
      if (appUser == null) {
        // Create new app user
        appUser = app_models.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await DatabaseService.saveUser(appUser);
      } else {
        // Update last login
        appUser = appUser.copyWith(lastLoginAt: DateTime.now());
        await DatabaseService.saveUser(appUser);
      }
      
      return appUser;
    } catch (e) {
      // Error converting Firebase user to app user
      return null;
    }
  }
  
  // Register with email and password
  static Future<app_models.User?> registerWithEmailPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // First, ensure we're signed out
      await _auth.signOut();
      
      final UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      
      // Create the app user in the database before signing out
      final firebaseUser = credential.user;
      app_models.User? appUser;
      
      if (firebaseUser != null) {
        appUser = app_models.User(
          id: firebaseUser.uid,
          name: name,
          email: email,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await DatabaseService.saveUser(appUser);
      }
      
      // CRITICAL: Sign out the user immediately after registration
      // This ensures they have to log in manually after signup
      await _auth.signOut();
      
      // Wait a moment to ensure sign-out is complete
      await Future.delayed(const Duration(milliseconds: 200));
      
      return appUser;
    } on FirebaseAuthException catch (e) {
      // Ensure we're signed out even if there's an error
      await _auth.signOut();
      throw _handleAuthException(e);
    } catch (e) {
      // Ensure we're signed out even if there's an error
      await _auth.signOut();
      throw Exception('Registration failed: ${e.toString()}');
    }
  }
  
  // Sign in with email and password
  static Future<app_models.User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Wait a bit to ensure the auth state is updated
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Get the current user directly from credential
      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw Exception('Authentication successful but user is null');
      }
      
      // Check if user exists in local database
      var appUser = DatabaseService.getUserById(firebaseUser.uid);
      
      if (appUser == null) {
        // Create new app user
        appUser = app_models.User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? firebaseUser.email?.split('@')[0] ?? 'User',
          email: firebaseUser.email ?? '',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        await DatabaseService.saveUser(appUser);
      } else {
        // Update last login
        appUser = appUser.copyWith(lastLoginAt: DateTime.now());
        await DatabaseService.saveUser(appUser);
      }
      
      return appUser;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Sign in failed: ${e.toString()}');
    }
  }
  
  // Sign out
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Sign out failed: ${e.toString()}');
    }
  }
  
  // Reset password
  static Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Password reset failed: ${e.toString()}');
    }
  }
  
  // Handle Firebase Auth exceptions
  static String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'The password provided is too weak.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'user-not-found':
        return 'No user found for this email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }
}

// Riverpod provider for Firebase Auth
final firebaseAuthProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// Stream provider for auth state changes
final authStateStreamProvider = StreamProvider<User?>((ref) {
  return FirebaseAuthService.authStateChanges;
});
