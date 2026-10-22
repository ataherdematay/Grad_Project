import 'package:equatable/equatable.dart';

enum UserRole {
  customer,
  pro,
}

class UserModel extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String phoneNumber;
  final String email;
  final UserRole role;
  final String avatarUrl;
  final bool isVerified;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
    required this.email,
    required this.role,
    required this.avatarUrl,
    this.isVerified = true,
  });

  String get fullName => '$firstName $lastName';

  UserModel copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? email,
    UserRole? role,
    String? avatarUrl,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        phoneNumber,
        email,
        role,
        avatarUrl,
        isVerified,
      ];
}
