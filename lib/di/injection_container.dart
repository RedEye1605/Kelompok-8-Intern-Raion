import 'package:get_it/get_it.dart';
import 'package:my_flutter_app/features/data/datasources/cloudinary_service.dart';
import 'package:my_flutter_app/features/data/datasources/firebase_auth_service.dart';
import 'package:my_flutter_app/features/data/datasources/firebase_road_status_service.dart';
import 'package:my_flutter_app/features/data/repositories/auth_repository_impl.dart';
import 'package:my_flutter_app/features/data/repositories/road_status_repository_impl.dart';
import 'package:my_flutter_app/features/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/features/domain/repositories/road_status_repository.dart';
import 'package:my_flutter_app/features/domain/usecases/login_user.dart';
import 'package:my_flutter_app/features/domain/usecases/login_with_google.dart';
import 'package:my_flutter_app/features/domain/usecases/register_user.dart';
import 'package:my_flutter_app/features/domain/usecases/create_road_status.dart';
import 'package:my_flutter_app/features/domain/usecases/get_road_statuses.dart';
import 'package:my_flutter_app/features/domain/usecases/delete_road_status.dart';
import 'package:my_flutter_app/features/domain/usecases/update_road_status.dart';
import 'package:my_flutter_app/features/domain/usecases/upload_road_status.dart';
import 'package:my_flutter_app/features/presentation/providers/auth_provider.dart';
import 'package:my_flutter_app/features/presentation/providers/home_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:my_flutter_app/features/presentation/providers/road_status_provider.dart';

final sl = GetIt.instance;

void setupDependencyInjection() {
  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  // Data Layer
  sl.registerLazySingleton<FirebaseAuthService>(() => FirebaseAuthService());

  // Repository Layer
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  // Use Cases - Auth
  sl.registerLazySingleton<LoginUser>(() => LoginUser(sl()));
  sl.registerLazySingleton<RegisterUser>(() => RegisterUser(sl()));
  sl.registerLazySingleton<LoginWithGoogle>(() => LoginWithGoogle(sl()));

  // Cloudinary - DAFTARKAN HANYA SEKALI
  sl.registerLazySingleton<CloudinaryService>(() => CloudinaryService());

  // Data sources - Road Status
  sl.registerLazySingleton<FirebaseRoadStatusRemoteDataSource>(
    () => FirebaseRoadStatusRemoteDataSourceImpl(sl()),
  );

  // Repository - Road Status
  sl.registerLazySingleton<RoadStatusRepository>(
    () => RoadStatusRepositoryImpl(
      remoteDataSource: sl(),
      cloudinaryService: sl(),
    ),
  );

  // Use Cases - Road Status
  sl.registerLazySingleton(() => GetRoadStatuses(sl()));
  sl.registerLazySingleton(() => CreateRoadStatus(sl()));
  sl.registerLazySingleton(() => DeleteRoadStatus(sl()));
  sl.registerLazySingleton(() => UpdateRoadStatus(sl()));
  sl.registerLazySingleton(() => UploadRoadStatus(sl()));

  // Providers
  sl.registerLazySingleton<AuthProvider>(
    () => AuthProvider(
      loginUser: sl(),
      registerUser: sl(),
      loginWithGoogle: sl(),
    ),
  );

  sl.registerFactory(() => HomeProvider());

  sl.registerLazySingleton<RoadStatusProvider>(
    () => RoadStatusProvider(
      getRoadStatuses: sl(),
      createRoadStatus: sl(),
      deleteRoadStatus: sl(),
      updateRoadStatus: sl(),
      uploadRoadStatus: sl(),
      cloudinaryService: sl(),
    ),
  );
}
