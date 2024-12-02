import 'package:flutter/material.dart';
import 'package:leak_guard/utils/colors.dart';

class CustomTextFiledDecorator extends StatelessWidget {
  const CustomTextFiledDecorator({super.key, required this.textFormField});
  final TextFormField textFormField;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        useMaterial3: true,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: MyColors.lightThemeFont,
          selectionColor: MyColors.lightThemeFont.withOpacity(0.2),
          selectionHandleColor: MyColors.lightThemeFont,
        ),
      ),
      child: Material(color: Colors.transparent, child: textFormField),
    );
  }
}
