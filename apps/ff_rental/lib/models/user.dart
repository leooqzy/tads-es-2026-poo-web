class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'buyer',
  });

  final int id;
  final String name;
  final String email;
  final String role;

  bool get isAdmin => role == 'admin';
  bool get isSeller => role == 'seller';
  bool get isBuyer => role == 'buyer';

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'role': role};
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String? ?? 'buyer',
    );
  }
}
