import 'package:flutter/cupertino.dart';

class WidthSpacer extends StatelessWidget {
  final width;
  const WidthSpacer(this.width, {super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var screenWidth = size.width;
    return SizedBox(
      width: width * screenWidth,
    );
  }
}