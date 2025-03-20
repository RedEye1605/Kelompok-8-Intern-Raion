import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/domain/entities/road_status.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class RoadStatusCard extends StatelessWidget {
  final RoadStatusEntity roadStatus;
  final Function onEdit;
  final Function onDelete;

  RoadStatusCard({
    required this.roadStatus,
    required this.onEdit,
    required this.onDelete,
  });

  Future<Map<String, dynamic>?> _getUserData(String userId) async {
    try {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    return timeago.format(dateTime, locale: 'id');
  }

  // Method untuk membuka URL
  Future<void> _launchURL(String url) async {
    // Jika URL tidak dimulai dengan http atau https, tambahkan https://
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      print('Tidak dapat membuka URL: $url');
    }
  }

  // Cek apakah user yang sedang login adalah pemilik status
  bool _isOwner() {
    final currentUser = FirebaseAuth.instance.currentUser;
    return currentUser != null && currentUser.uid == roadStatus.userId;
  }

  @override
  Widget build(BuildContext context) {
    // Cek kepemilikan status
    final bool isOwner = _isOwner();

    return Column(
      children: [
        FutureBuilder<Map<String, dynamic>?>(
          future: _getUserData(roadStatus.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 50,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            }

            final userData = snapshot.data;
            final String userPhoto = userData?['userPhoto'] ?? '';
            final String userName = userData?['nama'] ?? 'Pengguna';
            final String timeAgo = _getTimeAgo(roadStatus.createdAt);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with avatar, name, and time
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundImage:
                            userPhoto.isNotEmpty
                                ? NetworkImage(userPhoto)
                                : null,
                        backgroundColor: Colors.blue.shade100,
                        child:
                            userPhoto.isEmpty
                                ? Text(
                                  userName.isNotEmpty
                                      ? userName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                )
                                : null,
                      ),
                      const SizedBox(width: 12),
                      // Name and time column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // User name
                            Text(
                              userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            // Post time
                            Text(
                              timeAgo,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Options menu - hanya tampilkan jika user adalah pemilik
                      if (isOwner)
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              onEdit();
                            } else if (value == 'delete') {
                              onDelete();
                            }
                          },
                          color: Colors.white,
                          elevation: 8,
                          offset: const Offset(0, 40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          position: PopupMenuPosition.under,
                          icon: const Icon(Icons.more_vert),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem<String>(
                                value: 'edit',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.edit,
                                      size: 16,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem<String>(
                                value: 'delete',
                                child: Row(
                                  children: const [
                                    Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Hapus',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
                              ),
                            ];
                          },
                        ),
                    ],
                  ),
                  // Content container aligned with name and time
                  Padding(
                    padding: const EdgeInsets.only(left: 52.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description text
                        const SizedBox(height: 8),
                        Text(
                          roadStatus.description,
                          style: const TextStyle(fontSize: 14),
                        ),
                        // Maps link if available - dengan url_launcher
                        if (roadStatus.linkMaps.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: InkWell(
                              onTap: () => _launchURL(roadStatus.linkMaps),
                              child: Text(
                                roadStatus.linkMaps,
                                style: const TextStyle(
                                  color: Colors.blue,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),

                        // Code untuk bagian gambar tetap sama
                        if (roadStatus.images.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children:
                                roadStatus.images.map((imageUrl) {
                                  return GestureDetector(
                                    onTap: () {
                                      // Tampilkan gambar dalam mode fullscreen saat diklik
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder:
                                              (context) => Scaffold(
                                                appBar: AppBar(
                                                  backgroundColor: Colors.black,
                                                  iconTheme:
                                                      const IconThemeData(
                                                        color: Colors.white,
                                                      ),
                                                ),
                                                backgroundColor: Colors.black,
                                                body: Center(
                                                  child: InteractiveViewer(
                                                    minScale: 0.5,
                                                    maxScale: 3.0,
                                                    child: Image.network(
                                                      imageUrl,
                                                      fit: BoxFit.contain,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 100,
                                      height: 100,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          8.0,
                                        ),
                                        color:
                                            Colors
                                                .grey[200], // Background untuk placeholder
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (
                                          context,
                                          child,
                                          loadingProgress,
                                        ) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value:
                                                  loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                      : null,
                                              strokeWidth: 2,
                                            ),
                                          );
                                        },
                                        errorBuilder: (
                                          context,
                                          error,
                                          stackTrace,
                                        ) {
                                          print("Error loading image: $error");
                                          return Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: const [
                                                Icon(
                                                  Icons.error_outline,
                                                  color: Colors.red,
                                                ),
                                                SizedBox(height: 4),
                                                Text(
                                                  'Gagal memuat',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  );
                                }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(color: Colors.grey, thickness: 1, height: 20),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
