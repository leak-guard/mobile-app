import 'package:flutter/material.dart';
import 'package:leak_guard/utils/colors.dart';

class LoadingWidget extends StatelessWidget {
  const LoadingWidget(
      {super.key, required this.child, required this.isLoading});
  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Stack(children: [
            const ModalBarrier(
              dismissible: false,
              color: Colors.black54,
            ),
            Center(
              child: CircularProgressIndicator(
                color: MyColors.lightThemeFont,
              ),
            ),
          ]),
      ],
    );
  }
}
