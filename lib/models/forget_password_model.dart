class ForgotPasswordResponse {
  final bool status;
  final String message;
  final String token;
  final String expiresIn;

  ForgotPasswordResponse({
    required this.status,
    required this.message,
    required this.token,
    required this.expiresIn,
  });

  factory ForgotPasswordResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return ForgotPasswordResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      token: data['token'] ?? '',
      expiresIn: data['expires_in'] ?? '',
    );
  }
}