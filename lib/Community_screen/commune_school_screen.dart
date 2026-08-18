import 'package:fama/Community_screen/invite_friend_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/fame_stepps_app_bar.dart';

class ChooseSchoolScreen extends StatefulWidget {
  const ChooseSchoolScreen({super.key});

  @override
  State<ChooseSchoolScreen> createState() =>
      _ChooseSchoolScreenState();
}

class _ChooseSchoolScreenState
    extends State<ChooseSchoolScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  final List<Map<String, dynamic>> _schools = List.generate(
    9,
        (index) => {
      'name': 'School #${index + 1}',
      'count': 22,
    },
  );

  String? _selectedSchool;

  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _skipStep() {
    // Get.toNamed('/next-screen');
  }

  void _nextStep() {
    Get.to(()=>InviteFriendsScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Reusable AppBar
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
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      14,
                      16,
                      12,
                    ),
                    child: Column(
                      children: [
                        // Heading and Add School
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/home.png',
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Choose School',
                              style: TextStyle(
                                fontFamily: 'Rob',
                                fontSize: 14,
                                color: _darkColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            SizedBox(
                              height: 28,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Get.toNamed('/add-school');
                                },
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: _darkColor,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(78, 28),
                                  padding:
                                  const EdgeInsets.symmetric(
                                    horizontal: 10,
                                  ),
                                  tapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(4),
                                  ),
                                ),
                                child: const Text(
                                  '+ Add School',
                                  style: TextStyle(
                                    fontFamily: 'Rob',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Search Field
                        SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            cursorColor: _darkColor,
                            cursorHeight: 16,
                            style: const TextStyle(
                              fontFamily: 'Rob',
                              fontSize: 13,
                              color: _darkColor,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Search',
                              hintStyle: const TextStyle(
                                fontFamily: 'Rob',
                                fontSize: 13,
                                color: Color(0xFF60656B),
                              ),
                              isDense: true,
                              prefixIcon: const Icon(
                                Icons.search,
                                size: 18,
                                color: Color(0xFF30363D),
                              ),
                              prefixIconConstraints:
                              const BoxConstraints(
                                minWidth: 36,
                                minHeight: 40,
                              ),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              enabledBorder: _searchBorder(),
                              focusedBorder: _searchBorder(
                                color: _darkColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // School List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _schools.length,
                      itemBuilder: (context, index) {
                        final Map<String, dynamic> school =
                        _schools[index];

                        final String schoolName =
                        school['name'] as String;

                        final int members =
                        school['count'] as int;

                        final bool isSelected =
                            _selectedSchool == schoolName;

                        return Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            border: Border(
                              top: index == 0
                                  ? const BorderSide(
                                color: _borderColor,
                                width: 1,
                              )
                                  : BorderSide.none,
                              bottom: const BorderSide(
                                color: _borderColor,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Image.asset(
                                'assets/images/home.png',
                                width: 18,
                                height: 18,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 7),

                              Text(
                                schoolName,
                                style: const TextStyle(
                                  fontFamily: 'Rob',
                                  fontSize: 12,
                                  color: _darkColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),

                              const SizedBox(width: 8),

                              // Member Count
                              Container(
                                height: 20,
                                padding:
                                const EdgeInsets.symmetric(
                                  horizontal: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: _borderColor,
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.person_outline,
                                      size: 12,
                                      color: _darkColor,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '$members',
                                      style: const TextStyle(
                                        fontFamily: 'Rob',
                                        fontSize: 10,
                                        color: _darkColor,
                                        fontWeight:
                                        FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const Spacer(),

                              // Select Button
                              SizedBox(
                                height: 26,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedSchool =
                                          schoolName;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: _darkColor,
                                    foregroundColor: Colors.white,
                                    minimumSize:
                                    const Size(48, 26),
                                    padding:
                                    const EdgeInsets.symmetric(
                                      horizontal: 11,
                                    ),
                                    tapTargetSize:
                                    MaterialTapTargetSize
                                        .shrinkWrap,
                                    shape:
                                    const StadiumBorder(),
                                  ),
                                  child: Text(
                                    isSelected
                                        ? 'Selected'
                                        : 'Select',
                                    style: const TextStyle(
                                      fontFamily: 'Rob',
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.w500,
                                    ),
                                  ),
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

            // Bottom Button
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
                    Text(
                      'Next Step',
                      style: TextStyle(
                        fontFamily: 'Rob',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 10),
                    Icon(
                      Icons.arrow_forward,
                      size: 15,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _searchBorder({
    Color color = _borderColor,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(
        color: color,
        width: 1,
      ),
    );
  }
}