import 'package:my_flutter_app/features/domain/entities/user.dart';

class UserModel extends UserEntity {
  UserModel({required super.id, required super.email, required super.username});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['uid'],
      email: json['email'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'uid': id, 'email': email, 'username': username};
  }
}
