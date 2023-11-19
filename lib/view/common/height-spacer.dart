import 'package:flutter/cupertino.dart';

class HeightSpacer extends StatelessWidget {
  final height;
  const HeightSpacer(this.height, {super.key});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    var screenHeight = size.height;
    return SizedBox(
      height: height * screenHeight,
    );
  }
}