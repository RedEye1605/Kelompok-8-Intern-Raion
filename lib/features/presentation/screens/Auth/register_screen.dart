import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _namaController =
      TextEditingController(); // Changed from _usernameController
  bool _isLoading = false;
  bool _acceptTerms = false;

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _register() async {
    if (!_acceptTerms) {
      _showError('Silakan setujui syarat dan ketentuan');
      return;
    }

    if (_namaController.text.isEmpty) {
      _showError('Nama tidak boleh kosong');
      return;
    }

    if (_namaController.text.length < 3) {
      _showError('Nama minimal 3 karakter');
      return;
    }

    final RegExp nameRegex = RegExp(r'^[a-zA-Z\s]+$');
    if (!nameRegex.hasMatch(_namaController.text)) {
      _showError('Nama hanya boleh berisi huruf dan spasi');
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
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      if (mounted) {
        _showError(e.toString().replaceAll('Exception:', '').trim());
      }
    } finally {
      setState(() => _isLoading = false);
    }
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
        _showError(e.toString().replaceAll('Exception:', '').trim());
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 200),
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
                        TextField(
                          controller: _namaController,
                          decoration: const InputDecoration(
                            labelText:
                                "Nama Lengkap", // Changed from "Username"
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: ImageIcon(
                              AssetImage("assets/icons/user.png"),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email",
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.email),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Kata Sandi",
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: ImageIcon(
                              AssetImage("assets/icons/password.png"),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Konfirmasi Kata Sandi",
                            labelStyle: TextStyle(
                              color: Colors.grey,
                              fontFamily: 'Poppins',
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(10.0),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: ImageIcon(
                              AssetImage("assets/icons/password.png"),
                              color: Colors.black,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Checkbox(
                              value: _acceptTerms,
                              onChanged: (value) {
                                setState(() => _acceptTerms = value ?? false);
                              },
                            ),
                            const Text(
                              "Saya setuju dengan syarat dan ketentuan",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
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
                                    icon: Image.asset(
                                      "assets/icons/google.png",
                                    ),
                                    style: ButtonStyle(
                                      backgroundColor:
                                          const WidgetStatePropertyAll<Color>(
                                            Colors.white,
                                          ),
                                      shape: WidgetStatePropertyAll<
                                        RoundedRectangleBorder
                                      >(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
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
