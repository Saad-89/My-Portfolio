import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_fonts.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;
  final TextAlign alignment;

  const SectionTitle({
    Key? key,
    required this.title,
    required this.subtitle,
    this.isDark = false,
    this.alignment = TextAlign.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isMobile = screenSize.width < 768;

    return Column(
      children: [
        Text(
          title,
          textAlign: alignment,
          style: TextStyle(
            fontSize: isMobile ? 32 : 48,
            fontWeight: AppFonts.bold,
            color: isDark ? AppColors.primaryBlack : AppColors.pureWhite,
            fontFamily: AppFonts.primary,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          subtitle,
          textAlign: alignment,
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: AppFonts.regular,
            color: isDark ? AppColors.textSecondary : AppColors.lightGray,
            fontFamily: AppFonts.primary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
