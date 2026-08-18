import 'package:fama/Auth_Screens/signup_screen.dart';
import 'package:fama/Community_screen/commune_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import '../widgets/fama_top_bar.dart';

class SignupDetailsScreen extends StatefulWidget {
  const SignupDetailsScreen({super.key});

  @override
  State<SignupDetailsScreen> createState() =>
      _SignupDetailsScreenState();
}

class _SignupDetailsScreenState
    extends State<SignupDetailsScreen> {
  final TextEditingController _nameController =
  TextEditingController();

  String? _day;
  String? _month;
  String? _year;
  String _gender = 'male';

  static const Color _borderColor = Color(0xFFE3E7EC);

  static const TextStyle _labelStyle = TextStyle(
    fontFamily: 'Rob',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Color(0xFF404040),
  );

  static const TextStyle _fieldStyle = TextStyle(
    fontFamily: 'Rob',
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Color(0xFF07101D),
  );

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData currentTheme = Theme.of(context);

    return Theme(
      data: currentTheme.copyWith(
        textTheme: currentTheme.textTheme.apply(
          fontFamily: 'Rob',
        ),
        primaryTextTheme: currentTheme.primaryTextTheme.apply(
          fontFamily: 'Rob',
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: FamaTopBar(
          onBackTap: () => Navigator.pop(context),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Name (Public)',
                        style: _labelStyle,
                      ),
                      const SizedBox(height: 8),

                      SizedBox(
                        height: 48,
                        child: TextField(
                          controller: _nameController,
                          cursorColor: Colors.black,
                          style: _fieldStyle,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            hintText: 'Type Name...',
                            hintStyle: _fieldStyle,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14,
                            ),
                            enabledBorder: _inputBorder(10),
                            focusedBorder: _inputBorder(
                              10,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),
                      const Text(
                        'Birthday',
                        style: _labelStyle,
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: _buildDropdown(
                              hint: 'Day',
                              value: _day,
                              items: List.generate(
                                31,
                                    (index) => '${index + 1}',
                              ),
                              onChanged: (value) {
                                setState(() => _day = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDropdown(
                              hint: 'Month',
                              value: _month,
                              items: List.generate(
                                12,
                                    (index) => '${index + 1}',
                              ),
                              onChanged: (value) {
                                setState(() => _month = value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDropdown(
                              hint: 'Year',
                              value: _year,
                              items: List.generate(
                                100,
                                    (index) =>
                                '${DateTime.now().year - index}',
                              ),
                              onChanged: (value) {
                                setState(() => _year = value);
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      const Text(
                        'Gender',
                        style: _labelStyle,
                      ),
                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: _genderOption(
                              label: 'Male',
                              icon: Icons.person_outline,
                              value: 'male',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _genderOption(
                              label: 'Female',
                              icon: Icons.person_3_outlined,
                              value: 'female',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                   Get.to(()=>CommuneScreen());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF020A16),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(),
                  ),
                  child: const Text(
                    'Continue  →',
                    style: TextStyle(
                      fontFamily: 'Rob',
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return SizedBox(
      height: 48,
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        style: _fieldStyle,
        dropdownColor: Colors.white,
        icon: const Icon(
          Icons.unfold_more,
          size: 16,
          color: Color(0xFF07101D),
        ),
        hint: Text(hint, style: _fieldStyle),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(
            left: 12,
            right: 8,
          ),
          enabledBorder: _inputBorder(10),
          focusedBorder: _inputBorder(
            10,
            color: Colors.black,
          ),
        ),
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item, style: _fieldStyle),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _genderOption({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final bool selected = _gender == value;

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _gender = value),
      child: Container(
        height: 48,
        padding: const EdgeInsets.only(left: 10, right: 4),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFF0F1F3)
              : Colors.white,
          border: Border.all(color: _borderColor),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 17,
              color: const Color(0xFF07101D),
            ),
            const SizedBox(width: 6),
            Text(label, style: _fieldStyle),
            const Spacer(),
            Transform.scale(
              scale: 0.8,
              child: Radio<String>(
                value: value,
                groupValue: _gender,
                activeColor: const Color(0xFF07101D),
                materialTapTargetSize:
                MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() => _gender = newValue);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  OutlineInputBorder _inputBorder(
      double radius, {
        Color color = _borderColor,
      }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: color,
        width: 1,
      ),
    );
  }
}