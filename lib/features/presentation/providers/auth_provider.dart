  import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/domain/repositories/auth_repository.dart';
  import 'package:my_flutter_app/features/domain/usecases/login_user.dart';
  import 'package:my_flutter_app/features/domain/usecases/login_with_google.dart';
  import 'package:my_flutter_app/features/domain/usecases/register_user.dart';
  import 'package:my_flutter_app/features/presentation/screens/home_screen.dart';

  class AuthProvider with ChangeNotifier {
    final LoginUser loginUser;
    final RegisterUser registerUser;
    final LoginWithGoogle loginWithGoogle;
  

    String? _userId;

    AuthProvider( {required this.loginUser, required this.registerUser, required this.loginWithGoogle});

    bool _isLoading = false;
    String? _errorMessage;

    bool get isLoading => _isLoading;
    String? get errorMessage => _errorMessage;

    Future<void> login(
        String email, String password, BuildContext context) async {
      _setLoading(true);
      _clearError();
      try {
        await loginUser(LoginParams(email: email, password: password));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        );
      } catch (e) {
        _setError(e.toString());
      } finally {
        _setLoading(false);
      }
    }

    Future<void> register(String email, String password) async {
      _setLoading(true);
      _clearError();
      try {
        await registerUser(RegisterParams(email: email, password: password));
      } catch (e) {
        _setError(e.toString());
      } finally {
        _setLoading(false);
      }
    }

    Future<void> logInWithGoogle(BuildContext context) async {
      _setLoading(true);
      _clearError();
      // Implement Google Sign In
      try {
        final user = await loginWithGoogle();
        if (user != null) {
          _userId = user.id;
          notifyListeners();

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen()),
          );
        }
      } catch (e) {
        _setError(e.toString());
      } finally {
        _setLoading(false);
        
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