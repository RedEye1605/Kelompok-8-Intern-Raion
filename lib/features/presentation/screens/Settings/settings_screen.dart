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

  Future<void> _showDeleteConfirmation() async {
    final passwordController = TextEditingController();
    BuildContext? dialogContext;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Get stable references to avoid context issues
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);

      // STEP 1: Password confirmation
      final bool? passwordConfirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return AlertDialog(
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
                onPressed: () => Navigator.of(dialogContext!).pop(false),
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
                    Navigator.of(dialogContext!).pop(true);
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
          );
        },
      );

      if (passwordConfirmed != true) return;

      // STEP 2: Final confirmation
      final bool? shouldDelete = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Apakah Anda yakin ingin menghapus akun?',
              textAlign: TextAlign.center,
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Tindakan ini tidak dapat dibatalkan.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Semua data Anda akan dihapus secara permanen:',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('• Profil pengguna', style: TextStyle(color: Colors.grey)),
                Text('• Rating & ulasan', style: TextStyle(color: Colors.grey)),
                Text(
                  '• Properti & penginapan',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '• Pemesanan & riwayat',
                  style: TextStyle(color: Colors.grey),
                ),
                Text(
                  '• Status jalan & postingan',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext!).pop(false),
                child: const Text('Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(dialogContext!).pop(true),
                child: const Text(
                  'Hapus Akun',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          );
        },
      );

      if (shouldDelete != true) return;

      // STEP 3: Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          dialogContext = context;
          return WillPopScope(
            onWillPop:
                () async => false, // Prevent back button from closing dialog
            child: AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text("Menghapus akun dan data Anda..."),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // STEP 4: Delete all user data
      try {
        // 1. First get all the user data we need before deleting
        final userData =
            await _firestore.collection('users').doc(user.uid).get();
        final username = userData.data()?['username']?.toString().toLowerCase();

        // 2. Check for and delete road status posts
        await _firestore
            .collection('road_status')
            .where('userId', isEqualTo: user.uid)
            .get()
            .then((snapshot) {
              for (var doc in snapshot.docs) {
                doc.reference.delete();
              }
            })
            .catchError((e) => debugPrint('Error deleting road_status: $e'));

        // 3. Delete warlok data if exists
        await _firestore
            .collection('warlok')
            .doc(user.uid)
            .delete()
            .catchError((e) => debugPrint('Error deleting warlok: $e'));

        // 4. Delete all user ratings
        await _firestore
            .collection('ratings')
            .where('userId', isEqualTo: user.uid)
            .get()
            .then((snapshot) {
              for (var doc in snapshot.docs) {
                doc.reference.delete();
              }
            })
            .catchError((e) => debugPrint('Error deleting ratings: $e'));

        // 5. Delete all user properties
        await _firestore
            .collection('properties')
            .where('userId', isEqualTo: user.uid)
            .get()
            .then((snapshot) {
              for (var doc in snapshot.docs) {
                doc.reference.delete();
              }
            })
            .catchError((e) => debugPrint('Error deleting properties: $e'));

        // 6. Delete all user bookings
        await _firestore
            .collection('bookings')
            .where('userId', isEqualTo: user.uid)
            .get()
            .then((snapshot) {
              for (var doc in snapshot.docs) {
                doc.reference.delete();
              }
            })
            .catchError((e) => debugPrint('Error deleting bookings: $e'));

        // 7. Delete username reference if it exists
        if (username != null) {
          await _firestore
              .collection('usernames')
              .doc(username)
              .delete()
              .catchError((e) => debugPrint('Error deleting username: $e'));
        }

        // 8. Delete user document
        await _firestore
            .collection('users')
            .doc(user.uid)
            .delete()
            .catchError((e) => debugPrint('Error deleting user document: $e'));

        // 9. Finally delete the Firebase Auth account
        await user.delete();

        // Close the loading dialog if still showing
        if (dialogContext != null && navigator.canPop()) {
          Navigator.of(dialogContext!).pop();
        }

        // Navigate to login screen
        navigator.pushNamedAndRemoveUntil('/login', (route) => false);

        // Show success message
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Akun berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        // Close loading dialog if showing
        if (dialogContext != null && navigator.canPop()) {
          Navigator.of(dialogContext!).pop();
        }

        // Show detailed error
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus akun: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      // Always clean up resources
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
