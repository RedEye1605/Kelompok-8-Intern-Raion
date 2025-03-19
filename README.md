# my_flutter_app

Sebuah aplikasi Flutter yang memanfaatkan Firebase untuk autentikasi (Firebase Auth) dan penyimpanan catatan (Cloud Firestore). Proyek ini menerapkan pola Clean Architecture dengan pembagian domain, data, dan presentation, serta menggunakan [Provider](https://pub.dev/packages/provider) + [GetIt](https://pub.dev/packages/get_it) untuk state management dan dependency injection.

## Fitur Utama
- **Autentikasi Firebase**: 
  - Registrasi akun baru
  - Login dengan email/password
  - Logout
  - Proteksi rute berdasarkan status auth
- **Clean Architecture**: 
  - Domain Layer: Entities, Use Cases, Repository Contracts
  - Data Layer: Repository Implementations, Data Sources
  - Presentation Layer: UI + State Management
- **State Management & DI**:
  - Provider untuk manajemen state
  - GetIt untuk dependency injection

## Teknologi yang Digunakan
- Flutter SDK
- Firebase (Auth & Firestore)
- Provider (State Management)
- GetIt (Dependency Injection)

## Struktur Folder
```
lib/
  ├── core/                    // Kode dasar & utilities
  │   ├── error/              // Error handling
  │   ├── usecases/           // Base use case contract
  │   └── utils/              // Helper functions
  ├── di/                     // Dependency Injection
  │   └── injection_container.dart
  ├── features/
  │   ├── data/               
  │   │   ├── datasources/    // Firebase services
  │   │   ├── models/         // Data models
  │   │   └── repositories/   // Repository implementations
  │   ├── domain/             
  │   │   ├── entities/       // Business objects
  │   │   ├── repositories/   // Repository contracts  
  │   │   └── usecases/      // Business logic
  │   └── presentation/
  │       ├── provider/       // State management
  │       ├── screens/        // UI screens
  │       └── widgets/        // Reusable widgets
  └── main.dart               // Entry point
```

## Persiapan

### Prerequisites
- Flutter SDK (versi terbaru)
- Firebase project & configurasi
- Android Studio / VS Code
- Android Emulator / iOS Simulator

### Instalasi
1. Clone repository:
```bash
git clone https://github.com/RedEye1605/Kelompok-8-Intern-Raion.git
cd Kelompok-8-Intern-Raion
```

2. Install dependencies:
```yaml
dependencies:
  flutter:
    sdk: flutter
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
  cloud_firestore: ^5.6.5
  provider: ^6.0.5
  get_it: ^8.0.3
```

3. Get packages:
```bash
flutter pub get
```

4. Setup Firebase:
- Buat project di [Firebase Console](https://console.firebase.google.com/)
- Download & tambahkan file konfigurasi:
  - `google-services.json` untuk Android
  - `GoogleService-Info.plist` untuk iOS
- Aktifkan Authentication & Cloud Firestore

### Menjalankan Aplikasi
1. Pastikan device/emulator terhubung:
```bash
flutter devices
```

2. Jalankan aplikasi:
```bash
flutter run
```

## Testing
```bash
# Unit & Widget Tests
flutter test

# Integration Tests
flutter test integration_test
```

## Build & Deploy
### Android
```bash
flutter build apk --release
```
File APK akan tersedia di `build/app/outputs/flutter-apk/app-release.apk`

### iOS
```bash
flutter build ios --release
```
Buka Xcode untuk proses deployment ke App Store

## Kontribusi
1. Fork repository
2. Buat branch fitur (`git checkout -b feature/AmazingFeature`)
3. Commit perubahan (`git commit -m 'Add some AmazingFeature'`)
4. Push ke branch (`git push origin feature/AmazingFeature`)
5. Buat Pull Request

## Kontak
- **Rhendy Saragih** - [@rhendysrg_](https://instagram.com/rhendysrg_)
- **Ihtishamul Hasan** - [@_shamhasan](https://instagram.com/_shamhasan)


Project Link: [https://github.com/RedEye1605/Kelompok-8-Intern-Raion](https://github.com/RedEye1605/Kelompok-8-Intern-Raion)
