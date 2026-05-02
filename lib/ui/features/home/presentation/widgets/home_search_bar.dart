import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                cursorColor: AppColors.accent,
                decoration: InputDecoration(
                  hintText: context.l10n.searchPackPlaceholder,
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isCollapsed: true,
                ),
              ),
            ),
            if (widget.controller.text.trim().isNotEmpty)
              GestureDetector(
                onTap: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textMuted,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
