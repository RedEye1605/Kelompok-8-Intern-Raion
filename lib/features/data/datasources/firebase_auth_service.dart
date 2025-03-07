import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:my_flutter_app/features/data/models/user_model.dart';

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthService({firebase_auth.FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;



  // Register
  Future<UserModel> register(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        return UserModel(id: firebaseUser.uid, email: firebaseUser.email ?? '');
      } else {
        throw Exception('User registration failed');
      }
    } catch (e) {
      throw Exception('Error registering user: $e');
    }
  }


  // Login
  Future<UserModel> login(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        print("Firebase User: ${firebaseUser.uid}, ${firebaseUser.email}");
        return UserModel(id: firebaseUser.uid, email: firebaseUser.email ?? '');
      } else {
        throw Exception('User login failed');
      }
    } catch (e) {
      print("Login Error: $e");
      throw Exception('Error logging in user: $e');
    }
  }

  //google signin
  Future<UserModel> signInWithGoogle() async {
  try {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    if (gUser == null) {
      throw Exception("Google Sign-In dibatalkan");
    }

    final GoogleSignInAuthentication gAuth = await gUser.authentication;

    final credential = firebase_auth.GoogleAuthProvider.credential(
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      return UserModel(id: firebaseUser.uid, email: firebaseUser.email ?? '');
    } else {
      throw Exception("Google Sign-In gagal");
    }
  } catch (e) {
    throw Exception("Error Google Sign-In: $e");
  }
}


  // Sign Out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}