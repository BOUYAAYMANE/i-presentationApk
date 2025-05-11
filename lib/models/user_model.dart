class User {
  final int id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? profilePhotoPath;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.profilePhotoPath,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      phone: json['phone'],
      profilePhotoPath: json['profile_photo_path'],
    );
  }
}
