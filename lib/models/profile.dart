class ProfileModel {
  String name;
  String phone;
  String? image;

  ProfileModel({required this.name, required this.phone, this.image});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
        name: json['name'], phone: json['phone'], image: json['image'] ?? '');
  }
  factory ProfileModel.defaultValue() {
    return ProfileModel(name: '', phone: '');
  }
}
