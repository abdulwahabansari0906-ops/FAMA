import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/fame_stepps_app_bar.dart';
import 'commune_school_screen.dart';

class CommuneScreen extends StatefulWidget {
  const CommuneScreen({super.key});

  @override
  State<CommuneScreen> createState() => _CommuneScreenState();
}

class _CommuneScreenState extends State<CommuneScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  final List<String> _locations = [
    'Location #1',
    'Location #2',
    'Location #3',
    'Location #4',
    'Location #5',
    'Location #6',
  ];

  String? _selectedLocation;

  static const Color _darkColor = Color(0xFF020A16);
  static const Color _borderColor = Color(0xFFE4E8ED);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _goToNextScreen() {
    Get.to(()=>ChooseSchoolScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Reusable AppBar
      appBar: FamaStepAppBar(
        onBackTap: () => Get.back(),
        onNextTap: _goToNextScreen,
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
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: _darkColor,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Choose Location',
                              style: TextStyle(
                                fontFamily: 'Rob',
                                fontSize: 14,
                                color: _darkColor,
                                fontWeight: FontWeight.w700,
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

                  // Location List
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      itemCount: _locations.length,
                      itemBuilder: (context, index) {
                        final String location =
                        _locations[index];

                        final bool isSelected =
                            _selectedLocation == location;

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
                              const Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: _darkColor,
                              ),
                              const SizedBox(width: 7),
                              Text(
                                location,
                                style: const TextStyle(
                                  fontFamily: 'Rob',
                                  fontSize: 12,
                                  color: _darkColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),

                              // Select Button
                              SizedBox(
                                height: 26,
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedLocation =
                                          location;
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
                                      horizontal: 12,
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
                onPressed: _goToNextScreen,
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