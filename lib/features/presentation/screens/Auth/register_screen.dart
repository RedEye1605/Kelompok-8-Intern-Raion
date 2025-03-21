import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>(); // Add form key for validation
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _namaController = TextEditingController();
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    // Clean up controllers
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _namaController.dispose();
    super.dispose();
  }

  // Show error with better formatting
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success message
  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _register() async {
    // Clear previous messages
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    
    // Collect all validation errors
    List<String> errors = [];
    
    // Validate name
    if (_namaController.text.isEmpty) {
      errors.add('Nama harus diisi');
    } else if (_namaController.text.length < 3) {
      errors.add('Nama harus minimal 3 karakter');
    } else if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(_namaController.text)) {
      errors.add('Nama hanya boleh berisi huruf dan spasi');
    }
    
    // Validate email
    if (_emailController.text.isEmpty) {
      errors.add('Email harus diisi');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      errors.add('Format email tidak valid');
    }
    
    // Validate password
    if (_passwordController.text.isEmpty) {
      errors.add('Kata sandi harus diisi');
    } else if (_passwordController.text.length < 8) {
      errors.add('Kata sandi minimal 8 karakter');
    } else if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])').hasMatch(_passwordController.text)) {
      errors.add('Kata sandi harus mengandung huruf besar, huruf kecil, dan angka');
    }
    
    // Validate password confirmation
    if (_confirmPasswordController.text != _passwordController.text) {
      errors.add('Konfirmasi kata sandi tidak sesuai');
    }
    
    // Check terms acceptance
    if (!_acceptTerms) {
      errors.add('Anda harus menyetujui syarat dan ketentuan');
    }
    
    // Show errors if any
    if (errors.isNotEmpty) {
      _showErrors(errors);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(context, listen: false).register(
        _emailController.text,
        _passwordController.text,
        _namaController.text,
      );

      if (mounted) {
        _showSuccess('Pendaftaran berhasil! Silakan masuk dengan akun Anda.');
        
        // Add a small delay so user can see the success message
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = _getReadableErrorMessage(e.toString());
        _showError(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  // Better error messages for Firebase errors
  String _getReadableErrorMessage(String error) {
    String cleanError = error.replaceAll('Exception:', '').trim();
    
    if (cleanError.contains('email-already-in-use')) {
      return 'Email sudah terdaftar. Silakan gunakan email lain atau login.';
    } else if (cleanError.contains('weak-password')) {
      return 'Kata sandi terlalu lemah. Gunakan kombinasi huruf, angka, dan simbol.';
    } else if (cleanError.contains('invalid-email')) {
      return 'Format email tidak valid.';
    } else if (cleanError.contains('network-request-failed')) {
      return 'Koneksi internet bermasalah. Periksa koneksi Anda dan coba lagi.';
    } else if (cleanError.contains('operation-not-allowed')) {
      return 'Pendaftaran dengan email dan kata sandi tidak diizinkan.';
    } else if (cleanError.contains('too-many-requests')) {
      return 'Terlalu banyak percobaan. Silakan coba lagi nanti.';
    } else if (cleanError.contains('recaptcha')) {
      return 'Terjadi masalah dengan verifikasi keamanan. Silakan coba lagi.';
    }
    
    return 'Terjadi kesalahan: $cleanError';
  }

  void _showErrors(List<String> errors) {
    if (!mounted || errors.isEmpty) return;
    
    // For a single error, just show it directly
    if (errors.length == 1) {
      _showError(errors[0]);
      return;
    }
    
    // For multiple errors, show a summary and option to see all
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  'Ada beberapa masalah:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text('• ${errors[0]}', style: const TextStyle(fontSize: 14)),
            Text(
              '• Dan ${errors.length - 1} masalah lainnya',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 7),
        action: SnackBarAction(
          label: 'LIHAT SEMUA',
          textColor: Colors.white,
          onPressed: () {
            _showAllErrors(errors);
          },
        ),
      ),
    );
  }

  void _showAllErrors(List<String> errors) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.error_outline, color: Colors.red, size: 36),
        title: const Text(
          'Perbaiki masalah berikut:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors
                .map((error) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          Expanded(child: Text(error)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      await Provider.of<AuthProvider>(
        context,
        listen: false,
      ).logInWithGoogle(context);
    } catch (e) {
      if (mounted) {
        _showError(_getReadableErrorMessage(e.toString()));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80), // Reduced from 200 to 80
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const Text(
                          "Daftar",
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                            color: Colors.blue,
                          ),
                        ),
                        const Text(
                          "Buat akun baru Anda",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Enhanced Name TextField
                        TextField(
                          controller: _namaController,
                          decoration: InputDecoration(
                            labelText: "Nama Lengkap",
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const ImageIcon(
                              AssetImage("assets/icons/user.png"),
                              color: Colors.black,
                            ),
                            suffixIcon: _namaController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _namaController.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 10),
                        // Enhanced Email TextField
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: "Email",
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.email),
                            suffixIcon: _emailController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed: () {
                                      setState(() {
                                        _emailController.clear();
                                      });
                                    },
                                  )
                                : null,
                          ),
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 10),
                        // Enhanced Password TextField
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: "Kata Sandi",
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const ImageIcon(
                              AssetImage("assets/icons/password.png"),
                              color: Colors.black,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Enhanced Confirm Password TextField
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          decoration: InputDecoration(
                            labelText: "Konfirmasi Kata Sandi",
                            labelStyle: const TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                            border: const OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const ImageIcon(
                              AssetImage("assets/icons/password.png"),
                              color: Colors.black,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword = !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Enhanced Terms Checkbox
                        Row(
                          children: [
                            Checkbox(
                              activeColor: Colors.blue,
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() => _acceptTerms = value ?? false);
                              },
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() => _acceptTerms = !_acceptTerms);
                                },
                                child: const Text(
                                  "Saya setuju dengan syarat dan ketentuan",
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        if (_isLoading)
                          const CircularProgressIndicator()
                        else
                          Column(
                            children: [
                              ElevatedButton(
                                onPressed: _register,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 50,
                                    vertical: 20,
                                  ),
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  minimumSize: const Size(double.infinity, 35),
                                ),
                                child: const Text(
                                  "Daftar",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        left: 25,
                                        right: 10,
                                      ),
                                      child: const Divider(
                                        color: Colors.black,
                                        height: 36,
                                      ),
                                    ),
                                  ),
                                  const Text(
                                    "Atau daftar dengan",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                  Expanded(
                                    child: Container(
                                      margin: const EdgeInsets.only(
                                        left: 10,
                                        right: 25,
                                      ),
                                      child: const Divider(
                                        color: Colors.black,
                                        height: 36,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: _signInWithGoogle,
                                    icon: Image.asset("assets/icons/google.png"),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          const WidgetStatePropertyAll<Color>(
                                            Colors.white,
                                          ),
                                      shape: WidgetStatePropertyAll<
                                        RoundedRectangleBorder
                                      >(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  IconButton(
                                    onPressed: () {
                                      // TODO: Implement Apple sign in
                                    },
                                    icon: Image.asset("assets/icons/apple.png"),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          const WidgetStatePropertyAll<Color>(
                                            Colors.white,
                                          ),
                                      shape: WidgetStatePropertyAll<
                                        RoundedRectangleBorder
                                      >(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        const SizedBox(height: 20),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            "Sudah punya akun? Masuk",
                            style: TextStyle(
                              color: Colors.black,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
