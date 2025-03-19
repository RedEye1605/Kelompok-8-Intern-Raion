import 'package:my_flutter_app/core/usecases/usecases.dart';
import 'package:my_flutter_app/features/domain/entities/user.dart';
import 'package:my_flutter_app/features/domain/repositories/auth_repository.dart';

class RegisterUser implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUser(this.repository);

  @override
  Future<UserEntity> call(RegisterParams params) async {
    return await repository.register(params.email, params.password, params.username);
  }
}

class RegisterParams {
  final String email;
  final String password;
  final String username;

  RegisterParams({required this.email, required this.password, required this.username});
}