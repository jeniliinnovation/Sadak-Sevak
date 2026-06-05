class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? token;
  final String? avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.token,
    this.avatar,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      name: json['name'] ?? 'Citizen',
      email: json['email'] ?? '',
      role: json['role'] ?? 'citizen',
      token: json['token'],
      avatar: json['avatar'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'token': token,
      'avatar': avatar,
    };
  }
}
