import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_flutter_app/features/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthService({
    firebase_auth.FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  // Register
  Future<UserModel> register(
    String email,
    String password,
    String username,
  ) async {
    if (username.isEmpty) {
      throw Exception('Username cannot be empty');
    }

    try {
      // Check if username is already taken
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username.toLowerCase())
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        throw Exception('Username is already taken');
      }

      // Create user with Firebase Authentication
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        print(
          "Firebase User Created: ${firebaseUser.uid}, ${firebaseUser.email}",
        );

        // Create user document in Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .set({
              'email': email,
              'username': username.toLowerCase(), // Save username as a field
              'createdAt': FieldValue.serverTimestamp(),
            });

        return UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: username,
        );
      } else {
        throw Exception('User registration failed');
      }
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('Email already in use');
        case 'invalid-email':
          throw Exception('Invalid email');
        case 'operation-not-allowed':
          throw Exception('Operation not allowed');
        case 'weak-password':
          throw Exception('Weak password');
        default:
          throw Exception('Registration failed: ${e.message}');
      }
    } catch (e) {
      print("Registration Error: $e");
      throw Exception('Error registering user: $e');
    }
  }

  // Login
  Future<UserModel> login(String email, String password) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password cannot be empty');
      }

      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user == null) {
        throw Exception('Login failed - no user returned');
      }

      // Fetch user data from Firestore
      final userData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final username = userData.data()?['username'] ?? '';

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        username: username,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found with this email');
        case 'wrong-password':
          throw Exception('Wrong password provided');
        case 'user-disabled':
          throw Exception('This account has been disabled');
        case 'invalid-email':
          throw Exception('Invalid email address');
        default:
          throw Exception('Login failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to login: ${e.toString()}');
    }
  }

  // Google Sign-In
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception('Sign in cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final firebase_auth.AuthCredential credential = firebase_auth
          .GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Failed to sign in with Google');
      }

      // Fetch user data from Firestore
      final userData =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

      final username = userData.data()?['username'] ?? '';

      return UserModel(
        id: user.uid,
        email: user.email ?? '',
        username: username,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw Exception('Account exists with different credentials');
        case 'invalid-credential':
          throw Exception('Invalid credentials');
        case 'operation-not-allowed':
          throw Exception('Operation not allowed');
        case 'user-disabled':
          throw Exception('User disabled');
        case 'user-not-found':
          throw Exception('User not found');
        case 'wrong-password':
          throw Exception('Wrong password');
        default:
          throw Exception('Authentication failed: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: ${e.toString()}');
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
