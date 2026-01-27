import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MenuIcon extends StatelessWidget {
  final String assetPath;

  const MenuIcon({super.key, required this.assetPath});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      // decoration: BoxDecoration(
      //   color: Colors.black,
      //   borderRadius: BorderRadius.circular(10),
      // ),
      child: SvgPicture.asset(
        assetPath,
        width: 32,
        height: 32,
      ),
    );
  }
}
