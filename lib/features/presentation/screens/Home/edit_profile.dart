import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
    final _namaController = TextEditingController();
    final _nomorController = TextEditingController();
    final _negaraController = TextEditingController();
    String? _selectedNegara = "Indonesia";
    final User? user = FirebaseAuth.instance.currentUser;
  @override
  Widget build(BuildContext context) {

    @override
    void initState(){
      super.initState();
      _negaraController.text = _selectedNegara!;
    }

    void negaraChanged(String? newValue){
      setState(() {
        _selectedNegara = newValue;
        _negaraController.text = newValue!;
      });
    }

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
                    onPressed: (){}, 
                    icon: Image.asset("assets/icons/edit_photo.png", width: 34, height: 34,))
                  ] 
                ),
                SizedBox(height: 24),
                Column(
                  children: [
                    TextField(
                      controller: _namaController,
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
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        labelText: user?.email?? "Email tidak ditemukan.",
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
                        enabled: false,
                      ),
                      // controller: TextEditingController(text: user?.email ?? "Email tidak ditemukan"),
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
                      onChanged: negaraChanged,
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        prefixText: _getNomorNegara(_selectedNegara),
                        labelText: "Telepon ",
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
                      controller: _nomorController,
                    ),
                  ],
                ),
                SizedBox(
                  height: 100,
                ),
                ElevatedButton(
                  onPressed: _editHandle,
                  child: Text("Simpan"))
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future<void> _editHandle() async {
  final User? user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Pengguna tidak ditemukan")),
    );
    return;
  }

  try {
    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'nama': _namaController.text,
      'email': user.email,
      'negara': _selectedNegara,
      'nomor': _nomorController.text,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profil berhasil diperbarui")),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Gagal menyimpan data: $e")),
    );
    
  }
  Navigator.pop(context);
}

}

String _getNomorNegara (String? negara) {
  if (negara == "Indonesia" ) {
    return "+62 | ";
  }
  if (negara == "Malaysia" ) {
    return "+60 | ";
  }
  if (negara == "Singapura" ) {
    return "+65 | ";
  }

  return "";
}