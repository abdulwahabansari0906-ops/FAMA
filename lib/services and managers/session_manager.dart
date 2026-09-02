import 'package:get_storage/get_storage.dart';
import 'package:get/get.dart';
import '../models/loogin_response_model.dart';
import '../models/signup_response_model.dart';
import '../Auth_Screens/login_screen.dart';

class SessionManager {
  SessionManager._();

  static final GetStorage _box = GetStorage();

  static const _keyToken = 'access_token';
  static const _keyUserId = 'user_id';
  static const _keyPhone = 'phone_number';
  static const _keyOnboardingDone = 'is_onboarding_completed';
  static const _keyFamaPoints = 'fama_points'; // NEW

  // ── Save session ──────────────────────────────────────────────

  static Future<void> saveSignupSession(SignupResponse response) async {
    await _box.write(_keyToken, response.accessToken);
    await _box.write(_keyUserId, response.data.userId);
    await _box.write(_keyPhone, response.data.phoneNumber);
    await _box.write(_keyOnboardingDone, response.data.isOnboardingCompleted);
    // agar SignupResponse.data mein points field hai to yahan bhi save karo:
    // await _box.write(_keyFamaPoints, response.data.famaPoints);
  }

  static Future<void> saveLoginSession(LoginResponse response) async {
    await _box.write(_keyToken, response.accessToken);
    await _box.write(_keyUserId, response.data.userId);
    await _box.write(_keyPhone, response.data.phoneNumber);
    await _box.write(_keyOnboardingDone, response.data.isOnboardingCompleted);
    // agar LoginResponse.data mein points field hai to yahan bhi save karo:
    // await _box.write(_keyFamaPoints, response.data.famaPoints);
  }

  /// Kahin bhi (e.g. profile/points API se) fresh points aane par isay
  /// call karke session update kar sakte ho.
  static Future<void> updateFamaPoints(int points) async {
    await _box.write(_keyFamaPoints, points);
  }

  // ── Read session ──────────────────────────────────────────────

  static String? get accessToken => _box.read(_keyToken);
  static int? get userId => _box.read(_keyUserId);
  static String? get phoneNumber => _box.read(_keyPhone);
  static bool get isOnboardingCompleted =>
      (_box.read(_keyOnboardingDone) ?? 0) == 1;
  static bool get isLoggedIn =>
      (_box.read(_keyToken) ?? '').toString().isNotEmpty;

  /// Current logged-in user ke fama points. Kabhi na milay to '0'.
  static int get famaPoints => (_box.read(_keyFamaPoints) ?? 0) as int;

  // ── Clear / logout ───────────────────────────────────────────

  static Future<void> clear() async => _box.erase();

  static Future<void> logout() async {
    await clear();
    Get.offAll(() => const LoginScreen());
  }
}