import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/routes/route_paths.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSize(20, tabletSize: 24),
        context.responsiveSize(20, tabletSize: 24),
        context.responsiveSize(20, tabletSize: 24),
        context.responsiveSize(8, tabletSize: 10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.myCollections,
            style: context.responsiveTextStyle(
              mobileSize: 11,
              tabletSize: 12,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: context.responsiveSize(4, tabletSize: 6)),
          Row(
            children: [
              Image.asset(
                'assets/images/logo.png',
                height: context.responsiveSize(50, tabletSize: 58),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(
                  Icons.more_vert_outlined,
                  color: AppColors.textSecondary,
                ),
                onPressed: () {
                  (GoRouter.of(context)).push(RoutePaths.settings);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
