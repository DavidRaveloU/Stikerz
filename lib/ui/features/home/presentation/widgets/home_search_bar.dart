import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class HomeSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const HomeSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  @override
  Widget build(BuildContext context) {
    // Vertical padding controls effective field height and scales with font.
    final verticalPadding = context.responsiveSize(12, tabletSize: 14);
    final horizontalOuter = context.responsiveSize(20, tabletSize: 24);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        horizontalOuter,
        context.responsiveSize(4, tabletSize: 6),
        horizontalOuter,
        context.responsiveSize(16, tabletSize: 18),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(width: context.responsiveSize(14, tabletSize: 16)),
            Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: context.responsiveSize(18, tabletSize: 20),
            ),
            SizedBox(width: context.responsiveSize(10, tabletSize: 12)),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: (v) {
                  setState(() {});
                  widget.onChanged(v);
                },
                style: context.responsiveTextStyle(
                  mobileSize: 14,
                  tabletSize: 15,
                  color: AppColors.textPrimary,
                ),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: context.l10n.searchPackPlaceholder,
                  hintStyle: context.responsiveTextStyle(
                    mobileSize: 14,
                    tabletSize: 15,
                    color: AppColors.textMuted,
                  ),
                  border: InputBorder.none,
                  // Use explicit content padding for predictable field height.
                  isCollapsed: true,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: verticalPadding,
                  ),
                ),
              ),
            ),
            if (widget.controller.text.trim().isNotEmpty)
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged('');
                  setState(() {});
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: context.responsiveSize(12, tabletSize: 14),
                    vertical: verticalPadding,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: context.responsiveSize(18, tabletSize: 20),
                  ),
                ),
              )
            else
              SizedBox(width: context.responsiveSize(14, tabletSize: 16)),
          ],
        ),
      ),
    );
  }
}
