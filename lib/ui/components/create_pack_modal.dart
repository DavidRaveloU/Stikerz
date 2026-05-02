import 'package:flutter/material.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/extensions/localization_extension.dart';
import 'package:whaticker/core/repositories/pack_repository.dart';

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
              maxHeight: media.size.height * 0.9,
              minWidth: double.infinity,
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                20,
                12,
                20,
                24 + media.padding.bottom,
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
                        // Handle
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
                          context.l10n.newPack,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Campo: nombre del paquete
                        _buildLabel(context.l10n.packNameLabel),
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
                        const SizedBox(height: 14),

                        // Campo: autor
                        _buildLabel(context.l10n.authorNameLabel),
                        _buildField(
                          context: context,
                          controller: _authorCtrl,
                          hint: context.l10n.authorNameExample,
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? context.l10n.emptyFieldError
                              : null,
                        ),
                        const SizedBox(height: 22),

                        // Botón crear
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
                                      context.l10n.createPackButton,
                                      style: const TextStyle(
                                        color: AppColors.background,
                                        fontSize: 15,
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

  Widget _buildLabel(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 11,
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
    );
  }
}
