class SignupResponse {
  final bool status;
  final String message;
  final String accessToken;
  final SignupUserData data;

  SignupResponse({
    required this.status,
    required this.message,
    required this.accessToken,
    required this.data,
  });

  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    return SignupResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      accessToken: json['access_token'] ?? '',
      data: SignupUserData.fromJson(json['data'] ?? {}),
    );
  }
}

class SignupUserData {
  final int userId;
  final String phoneNumber;
  final int isOnboardingCompleted;
  final int famaPoints;

  SignupUserData({
    required this.userId,
    required this.phoneNumber,
    required this.isOnboardingCompleted,
    required this.famaPoints,
  });

  factory SignupUserData.fromJson(Map<String, dynamic> json) {
    return SignupUserData(
      userId: json['user_id'] ?? 0,
      phoneNumber: json['phone_number'] ?? '',
      isOnboardingCompleted: json['is_onboarding_completed'] ?? 0,
      famaPoints: json['fama_points'] ?? 0,
    );
  }
}