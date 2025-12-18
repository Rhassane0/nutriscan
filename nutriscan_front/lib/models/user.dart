class UserProfile {
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? activityLevel; // sedentary, light, moderate, active, veryActive
  final String? goalType; // maintain, lose, gain
  final String bio;
  final String website;

  UserProfile({
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.activityLevel,
    this.goalType,
    required this.bio,
    required this.website,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      age: json['age'] as int?,
      gender: json['gender'] as String?,
      heightCm: (json['heightCm'] as num?)?.toDouble(),
      weightKg: (json['weightKg'] as num?)?.toDouble(),
      activityLevel: json['activityLevel'] as String?,
      goalType: json['goalType'] as String?,
      bio: json['bio'] as String? ?? '',
      website: json['website'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (age != null) 'age': age,
      if (gender != null) 'gender': gender,
      if (heightCm != null) 'heightCm': heightCm,
      if (weightKg != null) 'weightKg': weightKg,
      if (activityLevel != null) 'activityLevel': activityLevel,
      if (goalType != null) 'goalType': goalType,
      'bio': bio,
      'website': website,
    };
  }
}

class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? role;
  final UserProfile? profile; // new optional profile

  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.role,
    this.profile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? json['userId'] as int? ?? 0,
      username: json['username'] as String? ?? json['fullName'] as String? ?? json['email'] as String? ?? 'Utilisateur',
      email: json['email'] as String? ?? '',
      fullName: json['fullName'] as String?,
      role: json['role'] as String?,
      profile: json['profile'] != null ? UserProfile.fromJson(json['profile'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      if (fullName != null) 'fullName': fullName,
      if (role != null) 'role': role,
      if (profile != null) 'profile': profile!.toJson(),
    };
  }
}

class AuthResponse {
  final String token;
  final User user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'user': user.toJson(),
    };
  }
}

class LoginRequest {
  final String username;
  final String password;

  LoginRequest({
    required this.username,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
    };
  }
}

class RegisterRequest {
  final String username;
  final String email;
  final String password;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
    };
  }
}
