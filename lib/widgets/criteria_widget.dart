import 'package:flutter/material.dart';
import 'package:leak_guard/widgets/custom_text_filed.dart';

class CriteriaWidget extends StatefulWidget {
  const CriteriaWidget(
      {super.key,
      required this.flowController,
      required this.timeController,
      required this.flowValidator,
      required this.timeValidator,
      this.onTextFieldChanged});
  final TextEditingController flowController;
  final TextEditingController timeController;
  final String? Function(String?) flowValidator;
  final String? Function(String?) timeValidator;
  final VoidCallback? onTextFieldChanged;

  @override
  State<CriteriaWidget> createState() => _CriteriaWidgetState();
}

class _CriteriaWidgetState extends State<CriteriaWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Heuristic criteria',
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.displayMedium),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Flow rate (ml/min)",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                  CustomTextField(
                    keyboardType: TextInputType.number,
                    controller: widget.flowController,
                    hintText: "Enter flow rate",
                    validator: widget.flowValidator,
                    onChanged: (_) {
                      widget.onTextFieldChanged?.call();
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Minimum time (sec)",
                        textAlign: TextAlign.left,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                    ],
                  ),
                  CustomTextField(
                    keyboardType: TextInputType.number,
                    controller: widget.timeController,
                    hintText: "Enter min time",
                    validator: widget.timeValidator,
                    onChanged: (_) {
                      widget.onTextFieldChanged?.call();
                    },
                  ),
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}
