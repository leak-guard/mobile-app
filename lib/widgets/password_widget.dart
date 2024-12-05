import 'package:flutter_neumorphic_plus/flutter_neumorphic.dart';
import 'package:leak_guard/widgets/custom_text_filed.dart';

class PasswordWidget extends StatefulWidget {
  const PasswordWidget(
      {super.key,
      required this.controller,
      this.validator,
      this.onTextFieldChanged});
  final TextEditingController controller;
  final VoidCallback? onTextFieldChanged;

  final String? Function(String?)? validator;

  @override
  State<PasswordWidget> createState() => _PasswordWidgetState();
}

class _PasswordWidgetState extends State<PasswordWidget> {
  bool _isPasswordVisible = false;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            hintText: 'Enter password...',
            validator: widget.validator,
            controller: widget.controller,
            onChanged: (_) {
              widget.onTextFieldChanged?.call();
            },
            obscureText: !_isPasswordVisible,
          ),
        ),
        const SizedBox(width: 8),
        NeumorphicButton(
          padding: const EdgeInsets.all(8),
          style: NeumorphicStyle(
            depth: 5,
            intensity: 0.8,
            boxShape: NeumorphicBoxShape.roundRect(
              BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
          child: _isPasswordVisible
              ? const Icon(Icons.visibility)
              : const Icon(Icons.visibility_off),
        ),
      ],
    );
  }
}
