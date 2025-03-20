import 'dart:io';
import 'package:flutter/material.dart';
import 'package:my_flutter_app/features/domain/entities/penginapan.dart';
import 'package:my_flutter_app/features/domain/usecases/create_penginapan.dart';
import 'package:firebase_auth/firebase_auth.dart';

class KategoriKamarFormData {
  String nama;
  String deskripsi;
  List<String> fasilitas;
  String harga;
  String jumlah;
  List<File> fotoKamar;

  KategoriKamarFormData({
    required this.nama,
    this.deskripsi = '',
    List<String>? fasilitas,
    this.harga = '',
    this.jumlah = '',
    List<File>? fotoKamar,
  }) : this.fasilitas = fasilitas ?? [],
       this.fotoKamar = fotoKamar ?? [];
}

class PenginapanFormProvider with ChangeNotifier {
  final CreatePenginapan _createPenginapanUseCase;

  // Form data
  String _namaRumah = '';
  String _alamatJalan = '';
  String _kecamatan = 'Lowokwaru';
  String _kelurahan = 'Jatimulyo';
  String _kodePos = '65141';
  String _linkMaps = '';
  List<File> _mainImages = [];
  String? _imageError;
  final int maxMainImages = 5; // Batas maksimum 5 foto sampul

  // Kategori kamar data
  Map<String, KategoriKamarFormData> _kategoriMap = {};
  List<String> _selectedKategori = [];
  String _currentKategori = '';

  // Controllers for current kategori
  final TextEditingController deskripsiController = TextEditingController();
  final TextEditingController hargaController = TextEditingController();
  final TextEditingController jumlahController = TextEditingController();

  // Loading state
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  String get namaRumah => _namaRumah;
  String get alamatJalan => _alamatJalan;
  String get kecamatan => _kecamatan;
  String get kelurahan => _kelurahan;
  String get kodePos => _kodePos;
  String get linkMaps => _linkMaps;
  List<File> get mainImages => _mainImages;
  bool get hasMainImages => _mainImages.isNotEmpty;
  int get mainImagesCount => _mainImages.length;
  bool get canAddMoreMainImages => _mainImages.length < maxMainImages;
  String? get imageError => _imageError;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, KategoriKamarFormData> get kategoriMap => _kategoriMap;
  List<String> get selectedKategori => _selectedKategori;
  String get currentKategori => _currentKategori;

  // Lists for dropdowns
  final List<String> kategoriOptions = [
    'Kamar Atas',
    'Kamar Bawah',
    'Kamar Utama',
    'Kamar Samping',
  ];

  PenginapanFormProvider({required CreatePenginapan createPenginapanUseCase})
    : _createPenginapanUseCase = createPenginapanUseCase;

  // Setters that notify listeners
  void setNamaRumah(String value) {
    _namaRumah = value;
    notifyListeners();
  }

  void setAlamatJalan(String value) {
    _alamatJalan = value;
    notifyListeners();
  }

  void setKecamatan(String value) {
    _kecamatan = value;
    // Reset kelurahan when kecamatan changes
    _kelurahan = _getKelurahanForKecamatan(value).first;
    notifyListeners();
  }

  void setKelurahan(String value) {
    _kelurahan = value;
    notifyListeners();
  }

  void setKodePos(String value) {
    _kodePos = value;
    notifyListeners();
  }

  void setLinkMaps(String value) {
    _linkMaps = value;
    notifyListeners();
  }

  void addMainImage(File image) {
    if (_mainImages.length < maxMainImages) {
      _mainImages.add(image);
      _imageError = null;
      notifyListeners();
    } else {
      _imageError = 'Maksimal $maxMainImages foto sampul';
      notifyListeners();
    }
  }

  void removeMainImage(int index) {
    if (index >= 0 && index < _mainImages.length) {
      _mainImages.removeAt(index);
      notifyListeners();
    }
  }

  // Untuk backward compatibility
  File? get mainImage => _mainImages.isNotEmpty ? _mainImages.first : null;
  void setMainImage(File image) {
    if (_mainImages.isEmpty) {
      _mainImages.add(image);
    } else {
      _mainImages[0] = image;
    }
    _imageError = null;
    notifyListeners();
  }

  void setImageError(String? error) {
    _imageError = error;
    notifyListeners();
  }

  // Kategori Kamar methods
  void addKategori(String kategori) {
    if (!_selectedKategori.contains(kategori)) {
      _selectedKategori.add(kategori);
      // Buat objek KategoriKamarFormData baru dengan data kosong
      _kategoriMap[kategori] = KategoriKamarFormData(
        nama: kategori,
        deskripsi: '',
        fasilitas: [],
        harga: '',
        jumlah: '',
        fotoKamar: [],
      );

      // Sebelum pindah kategori, simpan data kategori aktif
      saveCurrentKategoriData();

      // Pindah ke kategori baru
      _currentKategori = kategori;

      // Muat data kategori baru (yang kosong) ke controller
      loadKategoriData();

      notifyListeners();
    }
  }

  void removeKategori(String kategori) {
    _selectedKategori.remove(kategori);
    _kategoriMap.remove(kategori);

    // If current kategori is removed, switch to another or clear
    if (_currentKategori == kategori) {
      _currentKategori =
          _selectedKategori.isNotEmpty ? _selectedKategori.first : '';
      loadKategoriData();
    }

    notifyListeners();
  }

  void switchKategori(String kategori) {
    // Jangan lakukan apa-apa jika kategori yang sama
    if (_currentKategori == kategori) return;

    print("Switching from $_currentKategori to $kategori");

    // Save current form data first
    if (_currentKategori.isNotEmpty) {
      saveCurrentKategoriData();
    }

    _currentKategori = kategori;
    loadKategoriData();
    notifyListeners();
  }

  void saveCurrentKategoriData() {
    if (_currentKategori.isEmpty ||
        !_kategoriMap.containsKey(_currentKategori)) {
      print("Cannot save data: no current kategori or not in map");
      return;
    }

    final data = _kategoriMap[_currentKategori]!;

    print("Saving data for kategori '$_currentKategori':");
    print(" - Current deskripsi in controller: '${deskripsiController.text}'");
    print(" - Current harga in controller: '${hargaController.text}'");
    print(" - Current jumlah in controller: '${jumlahController.text}'");

    // Simpan data dari controller ke model
    data.deskripsi = deskripsiController.text;
    data.harga = hargaController.text;
    data.jumlah = jumlahController.text;
    // Catatan: Data fasilitas dan foto sudah disimpan melalui add/remove methods

    print(" - Saved deskripsi: '${data.deskripsi}'");
    print(" - Saved harga: '${data.harga}'");
    print(" - Saved jumlah: '${data.jumlah}'");
    print(" - Fasilitas count: ${data.fasilitas.length}");
    print(" - Foto count: ${data.fotoKamar.length}");
  }

  void loadKategoriData() {
    // PENTING: Bersihkan controller terlebih dahulu!
    print("Clearing all controllers");
    deskripsiController.clear();
    hargaController.clear();
    jumlahController.clear();

    if (_currentKategori.isEmpty ||
        !_kategoriMap.containsKey(_currentKategori)) {
      print("Cannot load data: no current kategori or not in map");
      return;
    }

    final data = _kategoriMap[_currentKategori]!;

    print("Loading data for kategori '$_currentKategori':");
    print(" - Deskripsi to load: '${data.deskripsi}'");
    print(" - Harga to load: '${data.harga}'");
    print(" - Jumlah to load: '${data.jumlah}'");

    // Load data from model ke controllers
    deskripsiController.text = data.deskripsi;
    hargaController.text = data.harga;
    jumlahController.text = data.jumlah;

    print(
      " - Controller deskripsi after loading: '${deskripsiController.text}'",
    );
    print(" - Controller harga after loading: '${hargaController.text}'");
    print(" - Controller jumlah after loading: '${jumlahController.text}'");
  }

  // Metode yang diperlukan untuk form - PERUBAHAN DISINI
  void setDeskripsiKamar(String value) {
    if (_currentKategori.isEmpty || !_kategoriMap.containsKey(_currentKategori))
      return;

    // Update data di model dan controller
    _kategoriMap[_currentKategori]!.deskripsi = value;
    // TextEditingController.text assignments don't need to be duplicated when
    // they're triggered by a TextField onChanged event
    notifyListeners();
  }

  // Method untuk mengatur harga kamar kategori yang aktif
  void setHargaKamar(String value) {
    if (_currentKategori.isEmpty || !_kategoriMap.containsKey(_currentKategori))
      return;

    // Update data di model langsung
    _kategoriMap[_currentKategori]!.harga = value;
    notifyListeners();
  }

  // Method untuk mengatur jumlah kamar kategori yang aktif
  void setJumlahKamar(String value) {
    if (_currentKategori.isEmpty || !_kategoriMap.containsKey(_currentKategori))
      return;

    // Update data di model langsung
    _kategoriMap[_currentKategori]!.jumlah = value;
    notifyListeners();
  }

  // Method untuk mendapatkan fasilitas kategori aktif
  List<String> getCurrentKategoriFasilitas() {
    if (_currentKategori.isEmpty ||
        !_kategoriMap.containsKey(_currentKategori)) {
      return [];
    }
    return _kategoriMap[_currentKategori]!.fasilitas;
  }

  // Add/remove facilities
  void addFasilitas(String fasilitas) {
    if (_currentKategori.isEmpty) return;

    // Pastikan list ada dan dapat dimodifikasi
    if (!_kategoriMap.containsKey(_currentKategori)) {
      _kategoriMap[_currentKategori] = KategoriKamarFormData(
        nama: _currentKategori,
      );
    }

    if (!_kategoriMap[_currentKategori]!.fasilitas.contains(fasilitas)) {
      _kategoriMap[_currentKategori]!.fasilitas.add(fasilitas);
      notifyListeners();
    }
  }

  void removeFasilitas(String fasilitas) {
    if (_currentKategori.isEmpty) return;

    if (_kategoriMap.containsKey(_currentKategori)) {
      _kategoriMap[_currentKategori]!.fasilitas.remove(fasilitas);
      notifyListeners();
    }
  }

  // Tambahkan foto ke kategori yang aktif
  Future<void> addFotoKamar(File foto) async {
    if (_currentKategori.isEmpty) return;

    if (!_kategoriMap.containsKey(_currentKategori)) {
      _kategoriMap[_currentKategori] = KategoriKamarFormData(
        nama: _currentKategori,
      );
    }

    _kategoriMap[_currentKategori]!.fotoKamar.add(foto);
    notifyListeners();
  }

  // Hapus foto dari kategori yang aktif
  void removeFotoKamar(int index) {
    if (_currentKategori.isEmpty) return;

    if (_kategoriMap.containsKey(_currentKategori) &&
        index < _kategoriMap[_currentKategori]!.fotoKamar.length) {
      _kategoriMap[_currentKategori]!.fotoKamar.removeAt(index);
      notifyListeners();
    }
  }

  // Dapatkan daftar foto dari kategori yang aktif
  List<File> getCurrentKategoriFoto() {
    if (_currentKategori.isEmpty ||
        !_kategoriMap.containsKey(_currentKategori)) {
      return [];
    }
    return _kategoriMap[_currentKategori]!.fotoKamar;
  }

  // Helper method untuk mendapatkan daftar kelurahan berdasarkan kecamatan
  List<String> _getKelurahanForKecamatan(String kecamatan) {
    final Map<String, List<String>> kelurahanOptions = {
      'Lowokwaru': [
        'Jatimulyo',
        'Landungsari',
        'Dinoyo',
        'Merjosari',
        'Tlogomas',
      ],
      'Sukun': ['Sukun', 'Ciptomulyo', 'Bandungrejosari', 'Tanjungrejo'],
      'Klojen': ['Klojen', 'Oro-oro Dowo', 'Samaan', 'Rampal Celaket'],
      'Blimbing': ['Blimbing', 'Purwantoro', 'Bunulrejo', 'Pandanwangi'],
      'Kedungkandang': ['Kedungkandang', 'Sawojajar', 'Madyopuro', 'Lesanpuro'],
    };

    return kelurahanOptions[kecamatan] ?? ['Jatimulyo'];
  }

  // Method to collect all data for preview or submission
  Map<String, dynamic> getAllData() {
    // First save any unsaved data in the current category
    if (_currentKategori.isNotEmpty) {
      saveCurrentKategoriData();
    }

    // Convert KategoriKamarFormData to Map format
    Map<String, Map<String, dynamic>> kategoriKamarMap = {};
    _kategoriMap.forEach((key, value) {
      kategoriKamarMap[key] = {
        'deskripsi': value.deskripsi,
        'fasilitas': value.fasilitas, // Ensure this is a List<String>
        'harga': value.harga,
        'jumlah': value.jumlah,
      };
    });

    return {
      'namaRumah': _namaRumah,
      'alamatJalan': _alamatJalan,
      'kecamatan': _kecamatan,
      'kelurahan': _kelurahan,
      'kodePos': _kodePos,
      'linkMaps': _linkMaps,
      'kategoriKamar': kategoriKamarMap,
      'mainImages': _mainImages,
    };
  }

  // Submit the form data to create a penginapan
  Future<PenginapanEntity?> submitForm() async {
    try {
      // Validasi data kategori
      if (!validateAllKategoriData()) {
        return null;
      }

      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Get all form data
      final formData = getAllData();

      // Prepare entity data
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final now = DateTime.now();

      // Convert kategori data to entities
      final Map<String, KategoriKamarEntity> kategoriKamarEntities = {};

      // Di sini idealnya kita akan menangani upload foto tambahan per kategori
      // namun untuk saat ini kita hanya membuat entitasnya saja
      (formData['kategoriKamar'] as Map<String, dynamic>).forEach((key, value) {
        kategoriKamarEntities[key] = KategoriKamarEntity(
          nama: key,
          deskripsi: value['deskripsi'],
          fasilitas: List<String>.from(value['fasilitas']),
          harga: value['harga'],
          jumlah: value['jumlah'],
          fotoKamar: [], // Akan diisi URL setelah upload
        );
      });

      // Sisanya sama seperti sebelumnya
      // ...
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Gagal menyimpan penginapan: ${e.toString()}';
      notifyListeners();
      return null;
    }
  }

  // Reset the entire form
  void resetForm() {
    _namaRumah = '';
    _alamatJalan = '';
    _kecamatan = 'Lowokwaru';
    _kelurahan = 'Jatimulyo';
    _kodePos = '65141';
    _linkMaps = '';
    _mainImages = []; // Reset dengan list kosong
    _imageError = null;

    // Buat map baru alih-alih memodifikasi yang ada
    _kategoriMap = {};
    _selectedKategori = [];
    _currentKategori = '';

    deskripsiController.clear();
    hargaController.clear();
    jumlahController.clear();
    notifyListeners();
  }

  bool validateAllKategoriData() {
    // Simpan data kategori yang sedang aktif terlebih dahulu
    if (_currentKategori.isNotEmpty) {
      saveCurrentKategoriData();
    }

    if (_selectedKategori.isEmpty) {
      _errorMessage = 'Minimal satu kategori kamar harus dipilih';
      notifyListeners();
      return false;
    }

    bool isValid = true;
    String missingDataKategori = '';

    // Validasi setiap kategori
    for (String kategori in _selectedKategori) {
      final data = _kategoriMap[kategori]!;

      if (data.deskripsi.isEmpty) {
        isValid = false;
        missingDataKategori = kategori;
        break;
      }

      if (data.harga.isEmpty) {
        isValid = false;
        missingDataKategori = kategori;
        break;
      }

      if (data.jumlah.isEmpty) {
        isValid = false;
        missingDataKategori = kategori;
        break;
      }

      if (data.fasilitas.isEmpty) {
        isValid = false;
        missingDataKategori = kategori;
        break;
      }
    }

    if (!isValid) {
      _errorMessage = 'Data kategori "$missingDataKategori" belum lengkap';
      notifyListeners();
    }

    return isValid;
  }

  /// Validasi data untuk kategori yang sedang aktif
  bool validateCurrentKategoriData() {
    if (_currentKategori.isEmpty ||
        !_kategoriMap.containsKey(_currentKategori)) {
      return false;
    }

    final data = _kategoriMap[_currentKategori]!;

    // Simpan data terbaru dari controller sebelum validasi
    saveCurrentKategoriData();

    // Cek data required
    if (data.deskripsi.isEmpty) {
      _errorMessage = 'Deskripsi kamar $_currentKategori tidak boleh kosong';
      notifyListeners();
      return false;
    }

    if (data.harga.isEmpty) {
      _errorMessage = 'Harga kamar $_currentKategori tidak boleh kosong';
      notifyListeners();
      return false;
    }

    if (data.jumlah.isEmpty) {
      _errorMessage = 'Jumlah kamar $_currentKategori tidak boleh kosong';
      notifyListeners();
      return false;
    }

    if (data.fasilitas.isEmpty) {
      _errorMessage = 'Fasilitas kamar $_currentKategori tidak boleh kosong';
      notifyListeners();
      return false;
    }

    return true;
  }

  @override
  void dispose() {
    deskripsiController.dispose();
    hargaController.dispose();
    jumlahController.dispose();
    super.dispose();
  }
}
