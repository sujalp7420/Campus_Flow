class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;
  final bool isDemo;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.isDemo = false,
  });

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  factory UserModel.fromMap(Map<String, dynamic> map, {bool isDemo = false}) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Student',
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'user',
      isDemo: isDemo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_demo': isDemo,
    };
  }
}