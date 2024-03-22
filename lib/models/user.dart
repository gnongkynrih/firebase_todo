// ignore_for_file: public_member_api_docs, sort_constructors_first
class UserSchema {
  String? id;
  String email;
  String password;
  String? confirmPassword;

  UserSchema({
    this.id,
    required this.email,
    required this.password,
    this.confirmPassword,
  });
  factory UserSchema.defaultValue() {
    return UserSchema(email: '', password: '');
  }
}
