import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Akun dan Profil',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 80,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/profile_page.png"),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 100),
                Stack(
                  alignment: AlignmentDirectional(1.35, 1.35),
                  children: [
                    FutureBuilder<String>(
                      future: getProfilePicture(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircleAvatar(
                            backgroundColor: Colors.grey,
                            radius: 50,
                            child:CircularProgressIndicator(), // Menampilkan loading sementara
                          );
                        }
                        if (snapshot.hasError || !snapshot.hasData) {
                          return CircleAvatar(
                            backgroundImage: NetworkImage(
                              'https://example.com/default_profile.png',
                            ),
                            radius: 50,
                          );
                        }
                        return CircleAvatar(
                          backgroundImage: NetworkImage(
                            snapshot.data!,
                          ), // Foto profil dari Firestore
                          radius: 50,
                        );
                      },
                    ),
                    IconButton(
                      onPressed:
                          () => Navigator.pushNamed(context, "/edit_profile"),
                      icon: Image.asset(
                        "assets/icons/edit_profile.png",
                        width: 34,
                        height: 34,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                Column(
                  children: [
                    FutureBuilder<Map<String, dynamic>?>(
  future: getUserData(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    }

    if (snapshot.hasError || !snapshot.hasData) {
      return Text("Gagal memuat data");
    }

    // Ambil data dari Firestore
    var userData = snapshot.data!;
    String nama = userData['nama'] ?? 'Nama tidak ditemukan';
    String email = FirebaseAuth.instance.currentUser?.email ?? "Email tidak ditemukan";
    String nomor = userData['nomor'] ?? '+62 |';
    String negara = userData['negara'] ?? 'Indonesia';

    return Column(
      children: [
        TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: nama,
            labelStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          readOnly: true,
        ),
        const SizedBox(height: 10),
        TextField(
          enabled: false,
          decoration: InputDecoration(
            labelText: email,
            labelStyle: TextStyle(
              color: Colors.black,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          readOnly: true,
        ),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: "Pilih negara",
            labelStyle: TextStyle(
              color: Colors.grey,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          value: negara, // Negara dari Firestore
          items: [
            DropdownMenuItem(
              value: 'Indonesia',
              child: Row(
                children: [
                  Image.asset('assets/icons/indonesia.png'),
                  SizedBox(width: 10),
                  Text("Indonesia"),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Malaysia',
              child: Row(
                children: [
                  Image.asset('assets/icons/Malaysia.png'),
                  SizedBox(width: 10),
                  Text("Malaysia"),
                ],
              ),
            ),
            DropdownMenuItem(
              value: 'Singapura',
              child: Row(
                children: [
                  Image.asset('assets/icons/Singapore.png'),
                  SizedBox(width: 10),
                  Text("Singapura"),
                ],
              ),
            ),
          ],
          onChanged: null, // Tidak bisa diubah langsung
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            prefixText: nomor,
            labelText: nomor,
            labelStyle: TextStyle(
              color: Colors.grey,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.normal,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
              borderSide: BorderSide(color: Colors.grey, width: 1.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          readOnly: true,
          enabled: false,
        ),
      ],
    );
  },
)

                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _getNomorTelepon() {
  return "+62 |";
}

Future<String> getProfilePicture() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  return userDoc.exists
      ? userDoc['userPhoto']
      : 'https://example.com/default_profile.png';
}

Future<String> getNama() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  return userDoc.exists
      ? userDoc['userPhoto']
      : 'https://example.com/default_profile.png';
}

Future<Map<String, dynamic>?> getUserData() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;
  DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(userId).get();

  if (userDoc.exists) {
    return userDoc.data() as Map<String, dynamic>;
  } else {
    return null;
  }
}
