import 'package:my_flutter_app/features/domain/entities/user.dart';

class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String email,
    required String nama,
  }) : super(
          id: id,
          email: email,
          nama: nama,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      nama: json['nama'], // Changed from username to nama
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nama': nama, // Changed from username to nama
    };
  }
}