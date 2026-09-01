class LoginResponse {
  final bool status;
  final String message;
  final String accessToken;
  final LoginUserData data;

  LoginResponse({
    required this.status,
    required this.message,
    required this.accessToken,
    required this.data,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      accessToken: json['access_token'] ?? '',
      data: LoginUserData.fromJson(json['data'] ?? {}),
    );
  }
}

class LoginUserData {
  final int userId;
  final String? name;
  final String phoneNumber;
  final int? locationId;
  final int? schoolId;
  final int famaPoints;
  final int isOnboardingCompleted;

  LoginUserData({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.locationId,
    required this.schoolId,
    required this.famaPoints,
    required this.isOnboardingCompleted,
  });

  factory LoginUserData.fromJson(Map<String, dynamic> json) {
    return LoginUserData(
      userId: json['user_id'] ?? 0,
      name: json['name'],
      phoneNumber: json['phone_number'] ?? '',
      locationId: json['location_id'],
      schoolId: json['school_id'],
      famaPoints: json['fama_points'] ?? 0,
      isOnboardingCompleted: json['is_onboarding_completed'] ?? 0,
    );
  }
}