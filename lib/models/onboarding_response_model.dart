class OnboardingResponse {
  final bool status;
  final String message;
  final OnboardingUserData data;

  OnboardingResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory OnboardingResponse.fromJson(Map<String, dynamic> json) {
    return OnboardingResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: OnboardingUserData.fromJson(json['data'] ?? {}),
    );
  }
}

class OnboardingUserData {
  final int userId;
  final String? name;
  final String phoneNumber;
  final String? birthday;
  final String? gender;
  final int? locationId;
  final String? locationName;
  final int? schoolId;
  final String? schoolName;
  final int famaPoints;
  final int isOnboardingCompleted;

  OnboardingUserData({
    required this.userId,
    required this.name,
    required this.phoneNumber,
    required this.birthday,
    required this.gender,
    required this.locationId,
    required this.locationName,
    required this.schoolId,
    required this.schoolName,
    required this.famaPoints,
    required this.isOnboardingCompleted,
  });

  factory OnboardingUserData.fromJson(Map<String, dynamic> json) {
    return OnboardingUserData(
      userId: json['user_id'] ?? 0,
      name: json['name'],
      phoneNumber: json['phone_number'] ?? '',
      birthday: json['birthday'],
      gender: json['gender'],
      locationId: json['location_id'],
      locationName: json['location_name'],
      schoolId: json['school_id'],
      schoolName: json['school_name'],
      famaPoints: json['fama_points'] ?? 0,
      isOnboardingCompleted: json['is_onboarding_completed'] ?? 0,
    );
  }
}