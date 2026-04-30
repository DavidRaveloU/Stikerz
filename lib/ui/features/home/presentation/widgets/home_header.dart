import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MIS COLECCIONES',
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 2,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
              children: [
                TextSpan(
                  text: 'Wha',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                TextSpan(
                  text: 'ticker',
                  style: TextStyle(color: AppColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
