import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/repositories/pack_repository.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class CreatePackModal extends StatefulWidget {
  const CreatePackModal({super.key});

  @override
  State<CreatePackModal> createState() => _CreatePackModalState();
}

class _CreatePackModalState extends State<CreatePackModal> {
  final _nameCtrl = TextEditingController();
  final _authorCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _nameInlineError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _authorCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await PackRepository.instance.createPack(
        name: _nameCtrl.text.trim(),
        author: _authorCtrl.text.trim(),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } on DuplicatePackNameException catch (e) {
      if (!mounted) return;
      setState(() => _nameInlineError = e.message);
      _formKey.currentState?.validate();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final horizontal = context.responsiveSize(20, tabletSize: 24);
    final modalMaxHeight = media.size.height * (context.isDesktop ? 0.78 : 0.9);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: modalMaxHeight,
              minWidth: double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontal,
                context.responsiveSize(12, tabletSize: 14),
                horizontal,
                context.responsiveSize(24, tabletSize: 28) + media.padding.bottom,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Container(
                            width: context.responsiveSize(36, tabletSize: 40),
                            height: 4,
                            decoration: BoxDecoration(
                              color: AppColors.border,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        SizedBox(height: context.responsiveSize(20, tabletSize: 24)),
                        Text(
                          context.l10n.newPack,
                          style: context.responsiveTextStyle(
                            mobileSize: 20,
                            tabletSize: 22,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: context.responsiveSize(20, tabletSize: 24)),

                        _buildLabel(context, context.l10n.packNameLabel),
                        _buildField(
                          context: context,
                          controller: _nameCtrl,
                          hint: context.l10n.packNameExample,
                          onChanged: (_) {
                            if (_nameInlineError != null) {
                              setState(() => _nameInlineError = null);
                            }
                          },
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return context.l10n.emptyFieldError;
                            }
                            return _nameInlineError;
                          },
                        ),
                        SizedBox(height: context.responsiveSize(14, tabletSize: 16)),

                        _buildLabel(context, context.l10n.authorNameLabel),
                        _buildField(
                          context: context,
                          controller: _authorCtrl,
                          hint: context.l10n.authorNameExample,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? context.l10n.emptyFieldError
                              : null,
                        ),
                        SizedBox(height: context.responsiveSize(22, tabletSize: 24)),

                        SizedBox(
                          width: double.infinity,
                          child: GestureDetector(
                            onTap: _loading ? null : _submit,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              height: context.responsiveSize(52, tabletSize: 56),
                              decoration: BoxDecoration(
                                color: _loading
                                    ? AppColors.accent.withValues(alpha: 0.6)
                                    : AppColors.accent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: _loading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: AppColors.background,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      context.l10n.createPackButton,
                                      style: context.responsiveTextStyle(
                                        mobileSize: 15,
                                        tabletSize: 16,
                                        color: AppColors.background,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) => Padding(
    padding: EdgeInsets.only(bottom: context.responsiveSize(6, tabletSize: 8)),
    child: Text(
      text,
      style: context.responsiveTextStyle(
        mobileSize: 11,
        tabletSize: 12,
        letterSpacing: 1.5,
        color: AppColors.textMuted,
      ),
    ),
  );

  Widget _buildField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    ValueChanged<String>? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      validator: validator,
      style: context.responsiveTextStyle(
        mobileSize: 14,
        tabletSize: 15,
        color: AppColors.textPrimary,
      ),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: context.responsiveTextStyle(
          mobileSize: 14,
          tabletSize: 15,
          color: AppColors.textMuted,
        ),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.responsiveSize(14, tabletSize: 16),
          vertical: context.responsiveSize(13, tabletSize: 14),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.accent.withValues(alpha: 0.6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
