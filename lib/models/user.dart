// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserModel {
  String? id;
  String email;
  String password;
  String? confirmPassword;

  UserModel({
    this.id,
    required this.email,
    required this.password,
    this.confirmPassword,
  });
  factory UserModel.defaultValue() {
    return UserModel(email: '', password: '');
  }
}
