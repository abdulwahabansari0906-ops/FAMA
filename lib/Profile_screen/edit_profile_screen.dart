import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services and managers/profile_service.dart';
import '../services and managers/profile_update_service.dart';
import '../services and managers/session_manager.dart';
import '../widgets/app_helper.dart';

/// Edit Profile screen — GET /api/profile se current data load karta hai,
/// user bio/avatar/social handles edit kar sakta hai, aur Save par
/// POST /api/profile/update call hoti hai. Same theme (colors/fonts) aur
/// AppHelpers loader/snackbars baaki screens ki tarah use hote hain.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _tiktokController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();

  ProfileUser? _currentUser;
  File? _pickedAvatarFile;

  bool _isLoading = true;
  bool _loadFailed = false;
  String _errorMessage = '';
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // AppHelpers.showLoader() (GetX dialog) ko pehle frame ke baad chalate
    // hain warna "visitChildElements() called during build" crash aata hai.
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchCurrentProfile());
  }

  @override
  void dispose() {
    _bioController.dispose();
    _instagramController.dispose();
    _tiktokController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  // ── Fetching ─────────────────────────────────────────────────────────

  Future<void> _fetchCurrentProfile() async {
    setState(() {
      _isLoading = true;
      _loadFailed = false;
    });

    final String? token = SessionManager.accessToken;
    debugPrint('EDIT PROFILE DEBUG -> token: $token');

    if (token == null || token.trim().isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = 'Session expired. Please log in again.';
      });
      AppHelpers.showError(_errorMessage);
      return;
    }

    AppHelpers.showLoader();
    try {
      final ProfileData profile = await ProfileApiService.getProfile(token: token);

      AppHelpers.hideLoader();
      debugPrint('EDIT PROFILE DEBUG -> loaded user: ${profile.user.name}');

      if (!mounted) return;
      setState(() {
        _currentUser = profile.user;
        _bioController.text = profile.user.bio ?? '';
        _instagramController.text = profile.user.instagramHandle ?? '';
        _tiktokController.text = profile.user.tiktokHandle ?? '';
        _facebookController.text = profile.user.facebookHandle ?? '';
        _isLoading = false;
        _loadFailed = false;
      });
    } catch (e) {
      AppHelpers.hideLoader();
      debugPrint('EDIT PROFILE DEBUG -> error: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _loadFailed = true;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
      AppHelpers.showError(_errorMessage);
    }
  }

  // ── Avatar picking ──────────────────────────────────────────────────

  Future<void> _pickAvatar() async {
    try {
      final XFile? picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (picked == null) return;

      if (!mounted) return;
      setState(() => _pickedAvatarFile = File(picked.path));
    } catch (e) {
      debugPrint('EDIT PROFILE DEBUG -> avatar pick failed: $e');
      AppHelpers.showError('Could not open gallery.');
    }
  }

  /// Picked file ko `data:image/<ext>;base64,...` string me convert karta
  /// hai jo backend expect karta hai. Naya avatar pick na kiya ho to null.
  Future<String?> _buildAvatarDataUri() async {
    final File? file = _pickedAvatarFile;
    if (file == null) return null;

    final List<int> bytes = await file.readAsBytes();
    final String base64Str = base64Encode(bytes);

    final String extension = file.path.split('.').last.toLowerCase();
    final String mimeType = (extension == 'jpg' || extension == 'jpeg')
        ? 'image/jpeg'
        : (extension == 'webp')
        ? 'image/webp'
        : 'image/png';

    return 'data:$mimeType;base64,$base64Str';
  }

  // ── Save ─────────────────────────────────────────────────────────────

  Future<void> _handleSave() async {
    if (_isSaving) return;

    final String? token = SessionManager.accessToken;
    if (token == null || token.trim().isEmpty) {
      AppHelpers.showError('Session expired. Please log in again.');
      return;
    }

    setState(() => _isSaving = true);
    AppHelpers.showLoader();

    try {
      final String? avatarDataUri = await _buildAvatarDataUri();

      final ProfileData updated = await ProfileUpdateApiService.updateProfile(
        token: token,
        bio: _bioController.text.trim(),
        avatarDataUri: avatarDataUri,
        instagramHandle: _instagramController.text.trim(),
        tiktokHandle: _tiktokController.text.trim(),
        facebookHandle: _facebookController.text.trim(),
      );

      AppHelpers.hideLoader();
      if (!mounted) return;

      AppHelpers.showSuccess('Profile updated successfully.');
      // Calling screen (Profile screen) ko updated data wapas bhejo taake
      // wo apna state refresh kar sake.
      Navigator.pop(context, updated);
    } catch (e) {
      AppHelpers.hideLoader();
      debugPrint('EDIT PROFILE DEBUG -> save error: $e');
      if (!mounted) return;
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ── UI ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _darkColor,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            fontFamily: 'Rob',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _darkColor,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _currentUser == null) {
      // Sirf AppHelpers ka loader dikhta hai, koi default spinner nahi.
      return const SizedBox.shrink();
    }

    if (_loadFailed && _currentUser == null) {
      return Center(
        child: TextButton(
          onPressed: _fetchCurrentProfile,
          child: Text(
            '$_errorMessage\nTap to retry.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF60656B)),
          ),
        ),
      );
    }

    final ProfileUser? user = _currentUser;
    if (user == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: _buildAvatarPicker(user)),
          const SizedBox(height: 8),
          Center(
            child: Text(
              user.name.isNotEmpty ? user.name : 'Unnamed',
              style: const TextStyle(
                fontFamily: 'Rob',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: _darkColor,
              ),
            ),
          ),
          Center(
            child: Text(
              user.phoneNumber,
              style: const TextStyle(
                fontFamily: 'Rob',
                fontSize: 12,
                color: Color(0xFF60656B),
              ),
            ),
          ),
          const SizedBox(height: 24),

          _fieldLabel('Bio'),
          const SizedBox(height: 6),
          TextField(
            controller: _bioController,
            maxLines: 3,
            maxLength: 150,
            style: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: _darkColor),
            decoration: _inputDecoration('Tell people about yourself'),
          ),

          const SizedBox(height: 10),
          _fieldLabel('Instagram'),
          const SizedBox(height: 6),
          TextField(
            controller: _instagramController,
            style: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: _darkColor),
            decoration: _inputDecoration('username'),
          ),

          const SizedBox(height: 16),
          _fieldLabel('TikTok'),
          const SizedBox(height: 6),
          TextField(
            controller: _tiktokController,
            style: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: _darkColor),
            decoration: _inputDecoration('username'),
          ),

          const SizedBox(height: 16),
          _fieldLabel('Facebook'),
          const SizedBox(height: 6),
          TextField(
            controller: _facebookController,
            style: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: _darkColor),
            decoration: _inputDecoration('username'),
          ),

          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: _darkColor,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(
                  fontFamily: 'Rob',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAvatarPicker(ProfileUser user) {
    ImageProvider? avatarImage;
    if (_pickedAvatarFile != null) {
      avatarImage = FileImage(_pickedAvatarFile!);
    } else if (user.avatarUrl != null && user.avatarUrl!.isNotEmpty) {
      avatarImage = NetworkImage(user.avatarUrl!);
    }

    return GestureDetector(
      onTap: _pickAvatar,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xFFE4E8ED),
            backgroundImage: avatarImage,
            child: avatarImage == null
                ? const Icon(Icons.person, color: _darkColor, size: 40)
                : null,
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: _darkColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'Rob',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: _darkColor,
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: Color(0xFFA9AEB4)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _darkColor),
      ),
      counterText: '',
    );
  }
}