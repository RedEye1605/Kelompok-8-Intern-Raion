import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RateUsScreen extends StatefulWidget {
  const RateUsScreen({super.key});

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  double _rating = 0.0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _getRatingText() {
    if (_rating == 0) {
      return 'Masih kosong nih';
    } else if (_rating < 2) {
      return 'Maaf atas pengalaman buruknya';
    } else if (_rating < 4) {
      return 'Terima kasih, kami akan terus meningkatkan layanan';
    } else {
      return 'Terima kasih atas penilaian positifnya!';
    }
  }

  Color _getRatingColor() {
    if (_rating == 0) {
      return Colors.grey;
    } else if (_rating < 2) {
      return Colors.red;
    } else if (_rating < 4) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  // Fungsi untuk menampilkan dialog terima kasih
  void _showThankYouDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 60),
              const SizedBox(height: 16),
              const Text(
                'Terima kasih atas masukan Anda!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                _rating >= 4
                    ? 'Semoga Anda menikmati petualangan berikutnya bersama kami!'
                    : 'Kami akan terus berupaya meningkatkan layanan kami.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.pop(context); // Kembali ke halaman sebelumnya
                },
                child: const Text('Oke', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon berikan rating terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = _auth.currentUser?.uid;
      if (userId != null) {
        await _firestore.collection('ratings').add({
          'userId': userId,
          'rating': _rating,
          'feedback': _feedbackController.text,
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;

        setState(() => _isSubmitting = false);

        // Tampilkan dialog terima kasih setelah berhasil mengirim
        _showThankYouDialog();
      }
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSubmitting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beri Rating'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Beri rating sekarang!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukan Anda membantu kami menjadi lebih baik.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              Center(
                child: RatingBar.builder(
                  initialRating: _rating,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 50,
                  itemBuilder:
                      (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                  onRatingUpdate: (rating) {
                    setState(() {
                      _rating = rating;
                    });
                  },
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  _getRatingText(),
                  style: TextStyle(
                    color: _getRatingColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Bersedia berbagi lebih banyak tentang hal ini?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                child: TextField(
                  controller: _feedbackController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    hintText: 'Masukkan komentar atau saran Anda di sini...',
                    contentPadding: EdgeInsets.all(16),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitRating,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isSubmitting
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text(
                                'Kirim Rating',
                                style: TextStyle(fontSize: 16),
                              ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Mungkin nanti',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
