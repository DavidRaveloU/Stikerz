import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/extensions/localization_extension.dart';
import 'package:stikerz/core/repositories/pack_repository.dart';
import 'package:stikerz/core/utils/responsive_text.dart';

class RenamePackModal extends StatefulWidget {
  final String currentName;
  final String currentAuthor;
  final Future<void> Function(String name, String author) onSave;

  const RenamePackModal({
    super.key,
    required this.currentName,
    required this.currentAuthor,
    required this.onSave,
  });

  @override
  State<RenamePackModal> createState() => _RenamePackModalState();
}

class _RenamePackModalState extends State<RenamePackModal> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _authorCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _nameInlineError;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _authorCtrl = TextEditingController(text: widget.currentAuthor);
  }

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
      await widget.onSave(_nameCtrl.text.trim(), _authorCtrl.text.trim());
      if (mounted) Navigator.pop(context);
    } on DuplicatePackNameException catch (e) {
      if (!mounted) return;
      setState(() => _nameInlineError = e.message);
      _formKey.currentState?.validate();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          context.responsiveSize(20, tabletSize: 24),
          context.responsiveSize(12, tabletSize: 14),
          context.responsiveSize(20, tabletSize: 24),
          context.responsiveSize(32, tabletSize: 36),
        ),
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
                context.l10n.renamePackTitle,
                style: context.responsiveTextStyle(
                  mobileSize: 20,
                  tabletSize: 22,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: context.responsiveSize(20, tabletSize: 24)),

              _buildField(
                label: context.l10n.packNameLabel,
                controller: _nameCtrl,
                hint: context.l10n.packNamePlaceholder,
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

              _buildField(
                label: context.l10n.authorNameLabel,
                controller: _authorCtrl,
                hint: context.l10n.authorNamePlaceholder,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.l10n.emptyFieldError
                    : null,
              ),
              SizedBox(height: context.responsiveSize(22, tabletSize: 24)),

              // Use vertical padding instead of fixed height for better
              // accessibility with larger system font sizes.
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _loading ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      vertical: context.responsiveSize(16, tabletSize: 18),
                    ),
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
                            context.l10n.saveChangesButton,
                            style: context.responsiveTextStyle(
                              mobileSize: 15,
                              tabletSize: 16,
                              color: AppColors.background,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String? Function(String?) validator,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.responsiveTextStyle(
            mobileSize: 11,
            tabletSize: 12,
            color: AppColors.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: context.responsiveSize(6, tabletSize: 8)),
        TextFormField(
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
              borderSide: BorderSide(
                color: AppColors.accent.withValues(alpha: 0.6),
              ),
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
        ),
      ],
    );
  }
}
