// widgets/gender_picker_sheet.dart
import 'package:flutter/material.dart';

Future<String?> showGenderPicker(BuildContext context, {String? selected}) {
  const options = ['Male', 'Female', 'Others'];
  const Color darkColor = Color(0xFF020A16);
  const Color borderColor = Color(0xFFE4E8ED);

  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(4)),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Gender',
                  style: TextStyle(fontFamily: 'Rob', fontSize: 15, fontWeight: FontWeight.w700, color: darkColor),
                ),
              ),
            ),
            ...options.map((g) => ListTile(
              title: Text(g, style: const TextStyle(fontFamily: 'Rob', fontSize: 13, color: darkColor)),
              trailing: g == selected ? const Icon(Icons.check_rounded, color: darkColor) : null,
              onTap: () => Navigator.pop(context, g),
            )),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}