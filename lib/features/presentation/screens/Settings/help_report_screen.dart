import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpReportScreen extends StatelessWidget {
  const HelpReportScreen({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  void _showContactDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Hubungi Layanan Pelanggan'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Pilih metode kontak:'),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.email, color: Colors.blue),
                  title: const Text('Email'),
                  subtitle: const Text('support@myflutterapp.com'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _launchUrl('mailto:support@myflutterapp.com');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: const Text('Telepon'),
                  subtitle: const Text('+62 812 3456 7890'),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _launchUrl('tel:+6281234567890');
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text(
          'Bantuan & Laporkan Masalah',
          style: TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bantuan Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Bantuan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.book),
            title: const Text('Panduan Pengguna'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Panduan pengguna akan segera hadir'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Kebijakan dan Ketentuan'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              _launchUrl('https://myflutterapp.com/privacy-policy');
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.support),
            title: const Text('Layanan Pelanggan'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () => _showContactDialog(context),
          ),
          const Divider(),

          // Laporan Section
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Laporan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.warning),
            title: const Text('Masalah Teknis'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Laporkan Masalah Teknis'),
                      content: const Text(
                        'Silakan jelaskan masalah teknis yang Anda alami melalui email support kami.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _launchUrl(
                              'mailto:support@myflutterapp.com?subject=Laporan%20Masalah%20Teknis',
                            );
                          },
                          child: const Text('Email Support'),
                        ),
                      ],
                    ),
              );
            },
          ),
          const Divider(),

          ListTile(
            leading: const Icon(Icons.security),
            title: const Text('Aktivitas Mencurigakan'),
            trailing: const Icon(Icons.keyboard_arrow_right),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text('Laporkan Aktivitas Mencurigakan'),
                      content: const Text(
                        'Untuk melaporkan aktivitas mencurigakan, silakan hubungi tim keamanan kami.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _launchUrl(
                              'mailto:security@myflutterapp.com?subject=Laporan%20Aktivitas%20Mencurigakan',
                            );
                          },
                          child: const Text('Hubungi Tim Keamanan'),
                        ),
                      ],
                    ),
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// Screen untuk melaporkan masalah teknis
class ReportTechnicalIssueScreen extends StatefulWidget {
  const ReportTechnicalIssueScreen({super.key});

  @override
  State<ReportTechnicalIssueScreen> createState() =>
      _ReportTechnicalIssueScreenState();
}

class _ReportTechnicalIssueScreenState
    extends State<ReportTechnicalIssueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _issueController = TextEditingController();
  final _stepsController = TextEditingController();
  String _selectedCategory = 'Aplikasi Crash';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'Aplikasi Crash',
    'Layar Blank/Putih',
    'Tidak Bisa Login',
    'Fitur Tidak Berfungsi',
    'Notifikasi Bermasalah',
    'Lainnya',
  ];

  @override
  void dispose() {
    _issueController.dispose();
    _stepsController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Simulasi pengiriman laporan
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // Show success dialog
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Laporan Terkirim'),
              content: const Text(
                'Terima kasih telah melaporkan masalah. Tim kami akan segera menindaklanjuti laporan Anda.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Laporkan Masalah Teknis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Deskripsi masalah yang Anda alami:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori Masalah',
                  border: OutlineInputBorder(),
                ),
                items:
                    _categories.map((String category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedCategory = newValue;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _issueController,
                decoration: const InputDecoration(
                  labelText: 'Jelaskan masalahnya',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harap isi deskripsi masalah';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _stepsController,
                decoration: const InputDecoration(
                  labelText: 'Langkah-langkah untuk mereproduksi masalah',
                  hintText:
                      'Contoh: 1. Buka aplikasi\n2. Klik tombol login\n3. Error muncul',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitReport,
                      icon: const Icon(Icons.send),
                      label:
                          _isSubmitting
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Kirim Laporan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Screen untuk melaporkan aktivitas mencurigakan
class ReportSuspiciousScreen extends StatefulWidget {
  const ReportSuspiciousScreen({super.key});

  @override
  State<ReportSuspiciousScreen> createState() => _ReportSuspiciousScreenState();
}

class _ReportSuspiciousScreenState extends State<ReportSuspiciousScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reportController = TextEditingController();
  final _usernameController = TextEditingController();
  String _selectedReason = 'Konten Tidak Pantas';
  bool _isSubmitting = false;

  final List<String> _reasons = [
    'Konten Tidak Pantas',
    'Penyalahgunaan',
    'Penipuan',
    'Pelanggaran Privasi',
    'Akun Palsu',
    'Lainnya',
  ];

  @override
  void dispose() {
    _reportController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Simulasi pengiriman laporan
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // Show success dialog
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Laporan Terkirim'),
              content: const Text(
                'Terima kasih telah melaporkan masalah. Kami akan menyelidiki dan mengambil tindakan yang sesuai.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Laporkan Aktivitas Mencurigakan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Kami mengambil laporan dengan sangat serius. Harap berikan detail yang cukup agar kami dapat menginvestigasi.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username yang dilaporkan (opsional)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedReason,
                decoration: const InputDecoration(
                  labelText: 'Alasan Pelaporan',
                  border: OutlineInputBorder(),
                ),
                items:
                    _reasons.map((String reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedReason = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Harap pilih alasan pelaporan';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _reportController,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi detail',
                  hintText: 'Jelaskan secara detail apa yang terjadi',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harap isi deskripsi laporan';
                  } else if (value.trim().length < 10) {
                    return 'Deskripsi terlalu pendek';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitReport,
                      icon: const Icon(Icons.send),
                      label:
                          _isSubmitting
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Kirim Laporan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Screen untuk saran dan masukan
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackController = TextEditingController();
  String _selectedType = 'Saran Fitur';
  bool _isSubmitting = false;
  double _rating = 4.0;

  final List<String> _types = [
    'Saran Fitur',
    'Peningkatan UI/UX',
    'Masukan Umum',
    'Lainnya',
  ];

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _submitFeedback() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      // Simulasi pengiriman feedback
      await Future.delayed(const Duration(seconds: 2));

      if (!mounted) return;

      setState(() => _isSubmitting = false);

      // Show success dialog
      showDialog(
        context: context,
        builder:
            (ctx) => AlertDialog(
              title: const Text('Terima Kasih!'),
              content: const Text(
                'Masukan Anda sangat berarti bagi kami untuk terus meningkatkan kualitas aplikasi.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        title: const Text('Saran dan Masukan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bagaimana kami dapat meningkatkan aplikasi ini? Kami menghargai masukan Anda!',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),

              const Text(
                'Beri nilai pengalaman Anda:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              Slider(
                value: _rating,
                min: 1.0,
                max: 5.0,
                divisions: 4,
                label: _rating.toString(),
                onChanged: (value) {
                  setState(() {
                    _rating = value;
                  });
                },
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Buruk'),
                  Text(
                    _rating.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const Text('Sangat Baik'),
                ],
              ),

              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Jenis Masukan',
                  border: OutlineInputBorder(),
                ),
                items:
                    _types.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedType = newValue;
                    });
                  }
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _feedbackController,
                decoration: const InputDecoration(
                  labelText: 'Masukan Anda',
                  hintText: 'Bagikan ide atau saran Anda di sini',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harap isi masukan Anda';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitFeedback,
                      icon: const Icon(Icons.send),
                      label:
                          _isSubmitting
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Text('Kirim Masukan'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
