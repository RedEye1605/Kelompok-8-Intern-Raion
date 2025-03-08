import 'package:my_flutter_app/features/domain/repositories/auth_repository.dart';
import 'package:my_flutter_app/features/domain/entities/user.dart';

class LoginWithGoogle {
  final AuthRepository authRepository;

  LoginWithGoogle(this.authRepository);

  Future<UserEntity> call() async {
    return await authRepository.loginWithGoogle();
  }
}
