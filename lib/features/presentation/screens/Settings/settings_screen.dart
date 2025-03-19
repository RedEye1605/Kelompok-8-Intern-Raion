import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import 'help_report_screen.dart';
import 'rate_us_screen.dart';
import 'pengajuan_warlok_screen.dart';

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
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.grey),
                    ),
                    child: const Text('Tidak'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(context); // Menutup dialog
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

  void showDeleteAccountDialog(BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Apakah Anda yakin ingin menghapus akun?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Tindakan ini tidak dapat dibatalkan.\nSemua data Anda akan hilang secara permanen.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red,
                        minimumSize: const Size(100, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Tidak',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onConfirm();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        minimumSize: const Size(100, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Ya',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation() async {
    final passwordController = TextEditingController();

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Store BuildContext for later use
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      await showDialog(
        context: context,
        builder:
            (BuildContext dialogContext) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: const Text('Konfirmasi Kata Sandi'),
              content: TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Kata Sandi',
                  border: OutlineInputBorder(),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text.isEmpty) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(content: Text('Masukkan kata sandi')),
                      );
                      return;
                    }

                    try {
                      final credential = firebase_auth
                          .EmailAuthProvider.credential(
                        email: user.email!,
                        password: passwordController.text,
                      );
                      await user.reauthenticateWithCredential(credential);
                      Navigator.of(dialogContext).pop();

                      // Show final confirmation dialog
                      showDeleteAccountDialog(context, () async {
                        try {
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder:
                                (loadingContext) => const AlertDialog(
                                  content: Row(
                                    children: [
                                      CircularProgressIndicator(),
                                      SizedBox(width: 16),
                                      Text("Menghapus akun..."),
                                    ],
                                  ),
                                ),
                          );

                          // Delete all user data in order
                          await Future.wait([
                            // 1. Delete warlok data
                            _firestore
                                .collection('warlok')
                                .doc(user.uid)
                                .delete(),

                            // 2. Delete ratings
                            _firestore
                                .collection('ratings')
                                .where('userId', isEqualTo: user.uid)
                                .get()
                                .then((snapshot) {
                                  for (var doc in snapshot.docs) {
                                    doc.reference.delete();
                                  }
                                }),

                            // 3. Delete properties
                            _firestore
                                .collection('properties')
                                .where('userId', isEqualTo: user.uid)
                                .get()
                                .then((snapshot) {
                                  for (var doc in snapshot.docs) {
                                    doc.reference.delete();
                                  }
                                }),

                            // 4. Delete bookings
                            _firestore
                                .collection('bookings')
                                .where('userId', isEqualTo: user.uid)
                                .get()
                                .then((snapshot) {
                                  for (var doc in snapshot.docs) {
                                    doc.reference.delete();
                                  }
                                }),
                          ]);

                          // 5. Get and delete username
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

                          // 6. Delete user document
                          await _firestore
                              .collection('users')
                              .doc(user.uid)
                              .delete();

                          // 7. Delete auth account
                          await user.delete();

                          // Navigate and show success message
                          navigator.pushNamedAndRemoveUntil(
                            '/login',
                            (route) => false,
                          );
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text('Akun berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } catch (e) {
                          Navigator.of(context).pop(); // Close loading dialog
                          scaffoldMessenger.showSnackBar(
                            SnackBar(
                              content: Text('Error: ${e.toString()}'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      });
                    } catch (e) {
                      scaffoldMessenger.showSnackBar(
                        const SnackBar(
                          content: Text('Kata sandi salah'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Konfirmasi'),
                ),
              ],
            ),
      );
    } finally {
      passwordController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Pengaturan', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Keamanan Section
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Keamanan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text('Ubah kata sandi'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ubah kata sandi akan segera hadir'),
                        ),
                      );
                    },
                  ),
                  const Divider(),

                  // Dukungan & Masukan Section
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Dukungan & Masukan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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

                  // Identitas Section
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Identitas',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Ajukan sebagai Warga Lokal'),
                    trailing: const Icon(Icons.keyboard_arrow_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PengajuanWarlokScreen(),
                        ),
                      );
                      // Remove the SnackBar message
                    },
                  ),
                  const Divider(),

                  // Tindakan Akun Section
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Tindakan Akun',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
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
                    onTap: _showLogoutDialog,
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
                    onTap:
                        _showDeleteConfirmation, // Changed to correct function
                  ),
                  const Divider(),
                  const SizedBox(height: 16),
                ],
              ),
    );
  }
}
