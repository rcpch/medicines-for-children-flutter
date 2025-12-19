class StoredCredentials {
  const StoredCredentials({
    required this.email,
    required this.password,
  });

  factory StoredCredentials.fromJson(Map<String, dynamic> json) {
    return StoredCredentials(
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  final String email;
  final String password;
}
