import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_flutter_app/features/domain/entities/road_status.dart';
import 'package:my_flutter_app/features/presentation/widgets/road_status_card.dart';
import 'package:my_flutter_app/features/presentation/screens/Home/mvp/road-status-tab/create_road_status_screen.dart';
import 'package:my_flutter_app/features/presentation/providers/road_status_provider.dart';

class RoadStatusScreen extends StatefulWidget {
  @override
  _RoadStatusScreenState createState() => _RoadStatusScreenState();
}

class _RoadStatusScreenState extends State<RoadStatusScreen> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _fetchRoadStatuses();
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  Future<void> _fetchRoadStatuses() async {
    await Provider.of<RoadStatusProvider>(
      context,
      listen: false,
    ).loadRoadStatuses();
  }

  void _showCongratulationsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/icons/Dollar.png', width: 50, height: 50),
                const SizedBox(height: 16),
                const Text(
                  'Selamat!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Anda mendapatkan 20 point',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Terus unggah kondisi jalan untuk mengumpulkan lebih banyak poin dan raih hadiah menarik lainnya!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 12,
                    ),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Oke'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kondisi Jalan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchRoadStatuses,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchRoadStatuses,
        child: Consumer<RoadStatusProvider>(
          builder: (ctx, roadStatusProvider, child) {
            if (roadStatusProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (roadStatusProvider.errorMessage != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Terjadi kesalahan: ${roadStatusProvider.errorMessage}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _fetchRoadStatuses,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              );
            }

            final roadStatuses = roadStatusProvider.roadStatuses;

            if (roadStatuses.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada status jalan yang diunggah',
                  style: TextStyle(fontSize: 16),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: roadStatuses.length,
              itemBuilder: (context, index) {
                return RoadStatusCard(
                  roadStatus: roadStatuses[index],
                  onEdit: () {
                    _navigateToEditScreen(context, roadStatuses[index]);
                  },
                  onDelete: () {
                    _showDeleteConfirmationDialog(
                      context,
                      roadStatuses[index].id,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 17, right: 17),
        child: InkWell(
          onTap: () {
            _navigateToCreateScreen(context);
          },
          child: Image.asset(
            "assets/icons/Group 385.png",
            width: 75, 
            height: 75,
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _navigateToCreateScreen(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateRoadStatusScreen()),
    );

    if (result == true) {
      // Reload data setelah sukses
      await _fetchRoadStatuses();

      // Tampilkan dialog selamat
      _showCongratulationsDialog(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status jalan berhasil ditambahkan')),
      );
    }
  }

  void _navigateToEditScreen(
    BuildContext context,
    RoadStatusEntity roadStatus,
  ) async {
    // Menggunakan CreateRoadStatusScreen sebagai editor
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => CreateRoadStatusScreen(
              isEditing:
                  true, // Tambahkan parameter ini di CreateRoadStatusScreen
              roadStatusToEdit: roadStatus, // Data yang akan diedit
            ),
      ),
    );

    if (result != null && result is RoadStatusEntity) {
      await Provider.of<RoadStatusProvider>(
        context,
        listen: false,
      ).updateExistingRoadStatus(result);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status jalan berhasil diperbarui')),
      );
    }
  }

  void _showDeleteConfirmationDialog(
    BuildContext context,
    String roadStatusId,
  ) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Konfirmasi Hapus'),
            content: const Text(
              'Apakah Anda yakin ingin menghapus status jalan ini?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(ctx).pop();
                  await Provider.of<RoadStatusProvider>(
                    context,
                    listen: false,
                  ).removeRoadStatus(roadStatusId);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status jalan berhasil dihapus'),
                      ),
                    );
                  }
                },
                child: const Text('Hapus'),
              ),
            ],
          ),
    );
  }
}
