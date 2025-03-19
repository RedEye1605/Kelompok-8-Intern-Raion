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
                  alignment: AlignmentDirectional(1.35,1.35),
                  children:[
                  CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 50,
                    child: Image.asset('assets/icons/profile-icon.png'),
                  ),
                  IconButton(
                    onPressed: ()=> Navigator.pushNamed(context, "/edit_profile"), 
                    icon: Image.asset("assets/icons/edit_profile.png", width: 34, height: 34,))
                  ] 
                ),
                SizedBox(height: 24),
                Column(
                  children: [
                    TextField(
                      enabled: false,
                      decoration: const InputDecoration(
                        labelText: "Nama",
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
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
                        labelText: user?.email ?? "Email tidak Ditemukan",
                        labelStyle: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      // controller: TextEditingController(text: user?.email ?? "Email tidak ditemukan"),
                      readOnly: true,
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Pilih negara",
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
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
                      onChanged: null,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        prefixText: _getNomorTelepon(),
                        labelText: _getNomorTelepon(),
                        labelStyle: TextStyle(
                          color: Colors.grey,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.normal,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      readOnly: true,
                      enabled: false,
                    ),
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
