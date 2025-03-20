import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/domain/usecases/login_user.dart';
import 'package:my_flutter_app/features/domain/usecases/login_with_google.dart';
import 'package:my_flutter_app/features/domain/usecases/register_user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:my_flutter_app/features/presentation/screens/Home/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final LoginUser loginUser;
  final RegisterUser registerUser;
  final LoginWithGoogle loginWithGoogle;
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      _setError(e.toString()); // Simpan error di _errorMessage
      rethrow; // Lempar ulang untuk ditangani di UI
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password, String nama) async {
    _setLoading(true);
    _clearError();
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'nama': nama,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      _userId = userCredential.user!.uid;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
      rethrow; // Rethrow to handle in UI
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
          MaterialPageRoute(builder: (_) => const HomePage()),
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
