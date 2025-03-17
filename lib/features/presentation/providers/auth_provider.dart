import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/features/domain/usecases/login_user.dart';
import 'package:my_flutter_app/features/domain/usecases/login_with_google.dart';
import 'package:my_flutter_app/features/domain/usecases/register_user.dart';
import 'package:my_flutter_app/features/presentation/screens/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LoginWithGoogle loginWithGoogle;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  String? _userId;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider({
    required this.loginUser,
    required this.registerUser,
    required this.loginWithGoogle,
  });

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await loginUser(
        LoginParams(email: email, password: password),
      );
      _userId = user.id;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password, String username) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await registerUser(
        RegisterParams(email: email, password: password, username: username),
      );
      _userId = user.id;
      notifyListeners();

      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.id).set({
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      _setError(e.toString());
      throw e; // Rethrow to handle in UI
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logInWithGoogle(BuildContext context) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await loginWithGoogle();
      _userId = user.id;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      _setError('Failed to sign in with Google: ${e.toString()}');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Logout logic in AuthProvider:
  Future<void> signOut(BuildContext context) async {
    try {
      await _firebaseAuth.signOut();
      await GoogleSignIn().signOut(); // Sign out from Google as well
      _userId = null;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
