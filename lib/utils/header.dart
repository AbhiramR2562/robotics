import 'package:flutter/material.dart';
import 'package:robotics_app/theme.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
    required this.size,
    required this.child,
    this.cutHeight = 20,
  });

  final Size size;
  final Widget child;

  final double cutHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size.height * 0.12,
      child: Stack(
        children: [
          Container(
            height: size.height * 0.1 - cutHeight,

            decoration: BoxDecoration(color: kPrimaryColor),
          ),
          Positioned(bottom: 0, left: 0, right: 0, child: child),
        ],
      ),
    );
  }
}
