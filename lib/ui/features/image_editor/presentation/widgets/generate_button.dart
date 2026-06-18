import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/image_editor/presentation/providers/image_editor_provider.dart';

/// Button that triggers sticker generation.
class GenerateButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const GenerateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(imageEditorProvider);
    final canGenerate = ref.watch(canGenerateProvider);

    return Container(
      padding: EdgeInsets.fromLTRB(
        context.responsiveSize(16, tabletSize: 20),
        context.responsiveSize(8, tabletSize: 10),
        context.responsiveSize(16, tabletSize: 20),
        context.responsiveSize(24, tabletSize: 28),
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: context.responsiveSize(48, tabletSize: 52),
          child: ElevatedButton(
            onPressed: canGenerate ? onPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: context.responsiveTextStyle(
                mobileSize: 15,
                tabletSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: state.isGenerating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: AppColors.background,
                      strokeWidth: 2,
                    ),
                  )
                : Text(context.l10n.generateStaticSticker),
          ),
        ),
      ),
    );
  }
}
