import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';

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
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.l10n.renamePackTitle,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 20),

              _buildField(
                label: context.l10n.packNameLabel,
                controller: _nameCtrl,
                hint: context.l10n.packNamePlaceholder,
                onChanged: (_) {
                  if (_nameInlineError != null)
                    setState(() => _nameInlineError = null);
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return context.l10n.emptyFieldError;
                  }
                  return _nameInlineError;
                },
              ),
              const SizedBox(height: 14),

              _buildField(
                label: context.l10n.authorNameLabel,
                controller: _authorCtrl,
                hint: context.l10n.authorNamePlaceholder,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? context.l10n.emptyFieldError
                    : null,
              ),
              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: _loading ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 52,
                    decoration: BoxDecoration(
                      color: _loading
                          ? AppColors.accent.withOpacity(0.6)
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
                            style: const TextStyle(
                              color: AppColors.background,
                              fontSize: 15,
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
          style: const TextStyle(
            fontSize: 11,
            letterSpacing: 1.5,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          cursorColor: AppColors.accent,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
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
              borderSide: BorderSide(color: AppColors.accent.withOpacity(0.6)),
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
