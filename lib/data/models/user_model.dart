class User {
  final String id;
  final String username;
  final String? avatarUrl;
  final String? email;
  final Map<String, dynamic> rawData;

  User({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.email,
    required this.rawData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['sub'] ?? json['id'] ?? '',
      username: json['preferred_username'] ?? json['name'] ?? json['nickname'] ?? '',
      avatarUrl: json['picture'],
      email: json['email'],
      rawData: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sub': id,
      'preferred_username': username,
      'picture': avatarUrl,
      'email': email,
      ...rawData,
    };
  }
}