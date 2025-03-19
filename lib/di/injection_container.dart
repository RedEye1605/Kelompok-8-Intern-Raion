import 'package:get_it/get_it.dart';
import 'package:my_flutter_app/features/data/datasources/cloudinary_service.dart';
import 'package:my_flutter_app/features/data/datasources/firebase_auth_service.dart';
import 'package:my_flutter_app/features/data/repositories/auth_repository_impl.dart';
import 'package:my_flutter_app/features/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/features/domain/usecases/login_user.dart';
import 'package:my_flutter_app/features/domain/usecases/login_with_google.dart';
import 'package:my_flutter_app/features/domain/usecases/register_user.dart';
import 'package:my_flutter_app/features/presentation/providers/auth_provider.dart';
import 'package:my_flutter_app/features/presentation/providers/home_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final sl = GetIt.instance;

void setupDependencyInjection() {
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data Layer
  sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());

  // Repository Layer
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton<LoginUser>(() => LoginUser(sl()));
  sl.registerLazySingleton<RegisterUser>(() => RegisterUser(sl()));
  sl.registerLazySingleton<LoginWithGoogle>(() => LoginWithGoogle(sl()));

  // Cloudinary
  // sl.registerLazySingleton<CloudinaryService>(() => CloudinaryService());
  
  // Providers
  sl.registerLazySingleton<AuthProvider>(() => AuthProvider(
    loginUser: sl(),
    registerUser: sl(),
    loginWithGoogle: sl(),    
  ));
  sl.registerFactory(() => HomeProvider());
}
