import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RateUsScreen extends StatefulWidget {
  const RateUsScreen({super.key});

  @override
  State<RateUsScreen> createState() => _RateUsScreenState();
}

class _RateUsScreenState extends State<RateUsScreen> {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // State variables
  double _rating = 0;
  bool _isSubmitting = false;
  final TextEditingController _feedbackController = TextEditingController();

  // Helper methods
  String _getRatingText() {
    if (_rating == 0) return 'Masih kosong nih';
    if (_rating <= 1) return 'Maaf atas pengalaman buruknya';
    if (_rating <= 2) return 'Mohon maaf atas ketidaknyamanannya';
    if (_rating <= 3) return 'Terima kasih atas masukannya';
    if (_rating <= 4) return 'Senang Anda menyukainya';
    return 'Terima kasih atas penilaian positifnya!';
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

        // Show success dialog
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                contentPadding: const EdgeInsets.all(20),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Terima kasih atas masukan Anda!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Image.asset(
                      'assets/icons/Star_animasi.png',
                      height: 150,
                      width: 150,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Semoga Anda menikmati petualangan berikutnya bersama kami!',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(150, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'OK',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengirim rating: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  // UI Components
  Widget _buildEmojiAvatar() {
    final Map<int, _EmojiConfig> emojiConfigs = {
      0: _EmojiConfig(Colors.grey, Icons.sentiment_very_dissatisfied),
      1: _EmojiConfig(Colors.yellow, Icons.sentiment_dissatisfied),
      2: _EmojiConfig(Colors.orange, Icons.sentiment_neutral),
      3: _EmojiConfig(Colors.blue, Icons.sentiment_satisfied),
      4: _EmojiConfig(Colors.green, Icons.sentiment_very_satisfied),
    };

    final config = emojiConfigs[_rating.toInt()] ?? emojiConfigs[4]!;

    return CircleAvatar(
      radius: 50,
      backgroundColor: config.color,
      child: Icon(config.icon, size: 50, color: Colors.white),
    );
  }

  Widget _buildRatingStars() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(5, (index) {
        return IconButton(
          icon: Icon(
            index < _rating ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 40,
          ),
          onPressed: () => setState(() => _rating = index + 1.0),
        );
      }),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submitRating,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
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
                      'Kirim',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[50],
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            child: const Text(
              'Mungkin nanti',
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Beri Rating', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(
                'Beri rating sekarang!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukan Anda membantu kami menjadi lebih baik.',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 40),
              _buildEmojiAvatar(),
              const SizedBox(height: 20),
              Text(
                _getRatingText(),
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              _buildRatingStars(),
              const SizedBox(height: 20),
              const Text(
                'Bersedia berbagi lebih banyak tentang hal ini?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _feedbackController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Tulis feedback Anda...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmojiConfig {
  final Color color;
  final IconData icon;

  const _EmojiConfig(this.color, this.icon);
}
