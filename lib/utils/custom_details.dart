import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:robotics_app/theme.dart';

class CustomDetails extends StatelessWidget {
  const CustomDetails({
    super.key,
    this.icon,
    this.svgPath,
    required this.title,
    required this.subText,
  });

  final IconData? icon;
  final String? svgPath;
  final String title;
  final String subText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        children: [
          CircleAvatar(
            child:
                icon != null
                    ? Icon(icon, color: kPrimaryColor)
                    : (svgPath != null
                        ? SvgPicture.asset(
                          svgPath!,
                          colorFilter: ColorFilter.mode(
                            kPrimaryColor,
                            BlendMode.srcIn,
                          ),
                          height: 24,
                          width: 24,
                        )
                        : const SizedBox()),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12)),
                Text(
                  subText,
                  style: const TextStyle(fontSize: 16),
                  // allow line break
                  softWrap: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
