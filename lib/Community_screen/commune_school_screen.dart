import 'dart:async';
import 'package:fama/Community_screen/invite_friend_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services and managers/school_list_service.dart';
import '../widgets/fame_stepps_app_bar.dart';
import '../widgets/onboarding_data_controller.dart';
import '../widgets/app_helper.dart';
import '../services and managers/onboarding_service.dart';
import '../models/school_model.dart';

class ChooseSchoolScreen extends StatefulWidget {
  const ChooseSchoolScreen({super.key});

  @override
  State<ChooseSchoolScreen> createState() => _ChooseSchoolScreenState();
}

class _ChooseSchoolScreenState extends State<ChooseSchoolScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<SchoolModel> _schools = [];
  bool _isLoading = false;
  Timer? _debounce;

  SchoolModel? _selectedSchool;

  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  @override
  void initState() {
    super.initState();
    _loadSchools();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      _loadSchools(search: _searchController.text.trim());
    });
  }

  Future<void> _loadSchools({String search = ''}) async {
    setState(() => _isLoading = true);
    try {
      final schools = await SchoolService.fetchSchools(search: search);
      setState(() => _schools = schools);
    } catch (e) {
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _skipStep() {
    // Get.toNamed('/next-screen');
  }

  Future<void> _nextStep() async {
    if (_selectedSchool == null) {
      AppHelpers.showError('School select karein.');
      return;
    }

    final controller = Get.find<OnboardingDataController>();
    controller.schoolId = _selectedSchool!.id;
    controller.schoolName = _selectedSchool!.name;

    AppHelpers.showLoader();
    try {
      await OnboardingService.completeOnboarding(
        name: controller.name,
        birthday: controller.birthday,
        gender: controller.gender,
        locationId: controller.locationId!,
        schoolId: controller.schoolId!,
      );
      AppHelpers.hideLoader();
      Get.to(() => InviteFriendsScreen());
    } catch (e) {
      AppHelpers.hideLoader();
      AppHelpers.showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: FamaStepAppBar(
        actionText: 'Skip',
        onBackTap: () => Get.back(),
        onNextTap: _skipStep,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/images/home.png', width: 18, height: 18, fit: BoxFit.contain),
                            const SizedBox(width: 6),
                            const Text(
                              'Choose School',
                              style: TextStyle(fontFamily: 'Rob', fontSize: 14, color: _darkColor, fontWeight: FontWeight.w700),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: _darkColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(78, 28),
                                  padding: const EdgeInsets.symmetric(horizontal: 10),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                ),
                                child: const Text('+ Add School',
                                    style: TextStyle(fontFamily: 'Rob', fontSize: 10, fontWeight: FontWeight.w500)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            cursorColor: _darkColor,
                            cursorHeight: 16,
                            style: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: _darkColor),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: Color(0xFF60656B)),
                              isDense: true,
                              prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF30363D)),
                              prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 40),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              enabledBorder: _searchBorder(),
                              focusedBorder: _searchBorder(color: _darkColor),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator(color: _darkColor))
                        : _schools.isEmpty
                        ? const Center(
                      child: Text(
                        'No schools found',
                        style: TextStyle(fontFamily: 'Rob', fontSize: 13, color: Color(0xFF60656B)),
                      ),
                    )
                        : ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _schools.length,
                      itemBuilder: (context, index) {
                        final SchoolModel school = _schools[index];
                        final bool isSelected = _selectedSchool?.id == school.id;

                        return Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            border: Border(
                              top: index == 0 ? const BorderSide(color: _borderColor, width: 1) : BorderSide.none,
                              bottom: const BorderSide(color: _borderColor, width: 1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset('assets/images/home.png', width: 18, height: 18, fit: BoxFit.contain),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Text(
                                  school.name,
                                  style: const TextStyle(fontFamily: 'Rob', fontSize: 12, color: _darkColor, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                height: 26,
                                child: ElevatedButton(
                                  onPressed: () => setState(() => _selectedSchool = school),
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: _darkColor,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(48, 26),
                                    padding: const EdgeInsets.symmetric(horizontal: 11),
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    shape: const StadiumBorder(),
                                  ),
                                  child: Text(isSelected ? 'Selected' : 'Select',
                                      style: const TextStyle(fontFamily: 'Rob', fontSize: 10, fontWeight: FontWeight.w500)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _darkColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: const RoundedRectangleBorder(),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Next Step', style: TextStyle(fontFamily: 'Rob', fontSize: 13, fontWeight: FontWeight.w400)),
                    SizedBox(width: 10),
                    Icon(Icons.arrow_forward, size: 15),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _searchBorder({Color color = _borderColor}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: color, width: 1),
    );
  }
}