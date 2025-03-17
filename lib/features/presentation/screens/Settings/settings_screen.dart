import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import 'help_report_screen.dart';
import 'rate_us_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _username = '';
  String _email = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userData =
            await _firestore.collection('users').doc(user.uid).get();

        if (mounted && userData.exists) {
          setState(() {
            _username = userData.data()?['username'] ?? '';
            _email = user.email ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Dialog konfirmasi logout
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Apakah Anda yakin ingin keluar?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Anda perlu masuk kembali untuk mengakses akun Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      ); // Menutup dialog jika memilih "Tidak"
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Tidak'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // Menutup dialog

                      // Proses logout
                      await Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      ).signOut(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.red, // Tombol "Ya" dengan warna merah
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ya'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Perbarui metode _showDeleteConfirmation()
  void _showDeleteConfirmation() {
    final _passwordController = TextEditingController();

    // Step 1: Minta password terlebih dahulu
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan Kata Sandi',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Untuk melanjutkan penghapusan akun, masukkan kata sandi Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Kata sandi',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      ); // Menutup dialog jika memilih "Batal"
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Batal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Validasi input
                      if (_passwordController.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masukkan kata sandi'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      Navigator.pop(context); // Tutup dialog password

                      // Verifikasi password
                      try {
                        final user = _auth.currentUser;
                        if (user != null && user.email != null) {
                          // Mencoba untuk re-authenticate
                          final credential = firebase_auth
                              .EmailAuthProvider.credential(
                            email: user.email!,
                            password: _passwordController.text,
                          );

                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (context) => const AlertDialog(
                                  content: Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 16),
                                      Text("Memverifikasi..."),
                                    ],
                                  ),
                                ),
                          );

                          // Authenticate
                          await user.reauthenticateWithCredential(credential);

                          if (Navigator.canPop(context)) {
                            Navigator.of(context).pop(); // Tutup loading dialog
                          }

                          // Jika autentikasi berhasil, tampilkan dialog konfirmasi
                          _showFinalDeleteConfirmation();
                        }
                      } catch (e) {
                        if (Navigator.canPop(context)) {
                          Navigator.of(
                            context,
                          ).pop(); // Tutup loading dialog jika ada
                        }

                        String errorMessage = 'Kata sandi tidak valid';
                        if (e is firebase_auth.FirebaseAuthException) {
                          if (e.code == 'wrong-password') {
                            errorMessage =
                                'Kata sandi tidak valid. Silakan coba lagi';
                          } else if (e.code == 'too-many-requests') {
                            errorMessage =
                                'Terlalu banyak percobaan. Silakan coba beberapa saat lagi';
                          }
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      } finally {
                        // Bersihkan password controller
                        _passwordController.clear();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Selanjutnya'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Metode untuk konfirmasi akhir penghapusan akun
  void _showFinalDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Apakah Anda yakin ingin menghapus akun?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Tindakan ini tidak dapat dibatalkan. Semua data Anda akan hilang secara permanen.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                      ); // Menutup dialog jika memilih "Tidak"
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Tidak'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // Menutup dialog

                      try {
                        final user = _auth.currentUser;
                        if (user != null) {
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (context) => const AlertDialog(
                                  content: Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 16),
                                      Text("Menghapus akun..."),
                                    ],
                                  ),
                                ),
                          );

                          // Delete user data from Firestore
                          await _firestore
                              .collection('users')
                              .doc(user.uid)
                              .delete();

                          // Delete any user-related collections
                          await _firestore
                              .collection('ratings')
                              .where('userId', isEqualTo: user.uid)
                              .get()
                              .then((snapshot) {
                                for (DocumentSnapshot doc in snapshot.docs) {
                                  doc.reference.delete();
                                }
                              });

                          // Kode yang perlu ditambahkan pada fungsi penghapusan akun
                          // Tambahkan setelah menghapus data ratings
                          final userData =
                              await _firestore
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();
                          final username =
                              userData
                                  .data()?['username']
                                  ?.toString()
                                  .toLowerCase();
                          if (username != null) {
                            await _firestore
                                .collection('usernames')
                                .doc(username)
                                .delete();
                          }

                          // Delete the actual user account
                          await user.delete();

                          if (mounted) {
                            // Close loading dialog
                            Navigator.of(context).pop();

                            // Navigate to login screen
                            Navigator.pushReplacementNamed(context, '/login');

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Akun Anda telah dihapus'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      } catch (e) {
                        // Close loading dialog if it's open
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }

                        String errorMessage = 'Error: ${e.toString()}';

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(errorMessage),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Ya'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Pengaturan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  // Profile section
                  Container(
                    color: Colors.blue,
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: Text(
                            _username.isNotEmpty
                                ? _username[0].toUpperCase()
                                : '',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _username,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _email,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Account Settings
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'AKUN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text('Edit Profil'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Edit Profil akan segera hadir'),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Keamanan'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pengaturan keamanan akan segera hadir',
                          ),
                        ),
                      );
                    },
                  ),

                  // App Settings
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'APLIKASI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.notifications),
                    title: const Text('Notifikasi'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Pengaturan notifikasi akan segera hadir',
                          ),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.language),
                    title: const Text('Bahasa'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Pengaturan bahasa akan segera hadir'),
                        ),
                      );
                    },
                  ),

                  // Support
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'TENTANG & BANTUAN',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.help),
                    title: const Text('Bantuan & Laporkan Masalah'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HelpReportScreen(),
                        ),
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.star),
                    title: const Text('Beri Rating'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RateUsScreen()),
                      );
                    },
                  ),

                  const Divider(),

                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('Tentang Aplikasi'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      showAboutDialog(
                        context: context,
                        applicationName: 'My Flutter App',
                        applicationVersion: '1.0.0',
                        applicationLegalese: '© 2025 My Flutter App',
                        children: const [
                          Text(
                            'Aplikasi yang dibuat dengan Flutter untuk menunjukkan berbagai fitur dan kemampuan framework Flutter.',
                          ),
                        ],
                      );
                    },
                  ),

                  // Logout
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      'AKSI',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text(
                      'Keluar',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward,
                      color: Colors.red,
                    ),
                    onTap:
                        _showLogoutDialog, // Menampilkan dialog konfirmasi logout
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                    title: const Text(
                      'Hapus Akun',
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(Icons.delete, color: Colors.red),
                    onTap: _showDeleteConfirmation,
                  ),

                  const SizedBox(height: 16),
                ],
              ),
    );
  }
}
