import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/utils/colors.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.validator,
    this.onChanged,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.readOnly = false,
    this.style,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool enabled;
  final bool readOnly;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final defaultStyle = Theme.of(context).textTheme.displaySmall!.copyWith(
          fontWeight: FontWeight.normal,
        );

    return Neumorphic(
      style: NeumorphicStyle(
        depth: -5,
        intensity: 0.8,
        boxShape: NeumorphicBoxShape.roundRect(
          BorderRadius.circular(12),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      child: Theme(
        data: ThemeData(
          useMaterial3: true,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: MyColors.lightThemeFont,
            selectionColor: MyColors.lightThemeFont.withOpacity(0.2),
            selectionHandleColor: MyColors.lightThemeFont,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: TextFormField(
            controller: controller,
            enabled: enabled,
            readOnly: readOnly,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: style ?? defaultStyle,
            decoration: InputDecoration(
              fillColor: MyColors.background,
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: TextStyle(
                color: MyColors.lightThemeFont.withOpacity(0.5),
              ),
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
