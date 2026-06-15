import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/services/device_info_service.dart';
import 'package:stikerz/core/services/feedback_service.dart';
import 'package:stikerz/core/services/tally_webview_service.dart';
import 'package:stikerz/generated_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class BugReportModal extends StatefulWidget {
  final Future<Map<String, String>> Function()? deviceInfoLoader;

  const BugReportModal({super.key, this.deviceInfoLoader});

  @override
  State<BugReportModal> createState() => _BugReportModalState();
}

class _BugReportModalState extends State<BugReportModal> {
  final _problemController = TextEditingController();
  final _emailController = TextEditingController();
  final _deviceInfoNotifier = ValueNotifier<Map<String, String>>({});
  final _deviceInfoLoaded = ValueNotifier<bool>(false);
  bool _isSubmitting = false;
  bool _canSubmitState = false;

  @override
  void initState() {
    super.initState();
    final loadDeviceInfo =
        widget.deviceInfoLoader ?? DeviceInfoService.getDeviceInfo;
    loadDeviceInfo().then((info) {
      if (mounted) {
        _deviceInfoNotifier.value = info;
        _deviceInfoLoaded.value = true;
      }
    });
  }

  @override
  void dispose() {
    _problemController.dispose();
    _emailController.dispose();
    _deviceInfoNotifier.dispose();
    _deviceInfoLoaded.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final email = value.trim();
    if (email.isEmpty) return false;
    final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return regex.hasMatch(email);
  }

  bool _isValidProblem(String value) {
    final problem = value.trim();
    if (problem.isEmpty) return false;
    final nonWhitespaceCount = problem.replaceAll(RegExp(r'\s'), '').length;
    return nonWhitespaceCount >= 10;
  }

  void _updateCanSubmit() {
    final newValue =
        _isValidEmail(_emailController.text) &&
        _isValidProblem(_problemController.text);
    if (newValue != _canSubmitState) {
      setState(() => _canSubmitState = newValue);
    }
  }

  Future<void> _sendFeedback() async {
    final l10n = AppLocalizations.of(context);
    final email = _emailController.text.trim();
    final problem = _problemController.text.trim();

    if (!_canSubmitState) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorOccurred)));
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final deviceInfoStr = DeviceInfoService.formatDeviceInfo(
        _deviceInfoNotifier.value,
      );

      final success = await TallyWebviewService.submitHeadless(
        email: email,
        problem: problem,
        deviceInfo: deviceInfoStr,
      );

      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.feedbackSent)));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.errorOccurred)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorOccurred)));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _sendEmail() async {
    final l10n = AppLocalizations.of(context);
    final supportEmail = FeedbackService.supportEmail;

    if (supportEmail.isEmpty || !_canSubmitState) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorOccurred)));
      return;
    }

    final email = _emailController.text.trim();
    final problem = _problemController.text.trim();

    final subject = Uri.encodeComponent('Stikerz - Bug report / Feedback');
    final bodyText =
        '''
Hi team,

I'd like to share the following feedback:

Email: ${email.isEmpty ? 'N/A' : email}

Comment:
${problem.isEmpty ? 'N/A' : problem}

--------------------------------

Device info:
${DeviceInfoService.formatDeviceInfo(_deviceInfoNotifier.value)}
''';

    final body = Uri.encodeComponent(bodyText);
    final mailto = Uri.parse(
      'mailto:$supportEmail?subject=$subject&body=$body',
    );

    if (!await launchUrl(mailto, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorOccurred)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isEnabled = _canSubmitState && !_isSubmitting;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text(l10n.bugReport), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.deviceInfo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            // Listen to both notifiers without rebuilding the full parent tree.
            ValueListenableBuilder<bool>(
              valueListenable: _deviceInfoLoaded,
              builder: (context, isLoaded, child) {
                return ValueListenableBuilder<Map<String, String>>(
                  valueListenable: _deviceInfoNotifier,
                  builder: (context, deviceInfo, child) {
                    if (!isLoaded) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    }

                    if (deviceInfo.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Text(
                          'Error loading device info',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: Colors.red),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...deviceInfo.entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    e.key,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      e.value,
                                      textAlign: TextAlign.end,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.textPrimary,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 20),

            Text(
              l10n.describeProblem,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _problemController,
                maxLines: 4,
                minLines: 3,
                onChanged: (_) => _updateCanSubmit(),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: l10n.describeProblemHint,
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              l10n.email,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) => _updateCanSubmit(),
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: Localizations.localeOf(context).languageCode == 'en'
                      ? 'yourname@example.com'
                      : l10n.emailHint,
                  hintStyle: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isEnabled ? _sendFeedback : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: AppColors.background,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        l10n.sendFeedback,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),

            Center(
              child: Text(
                l10n.alternatively,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: isEnabled ? _sendEmail : null,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.email, size: 16),
                    const SizedBox(width: 8),
                    Text(l10n.sendEmail),
                  ],
                ),
              ),
            ),
            SizedBox(height: keyboardHeight + 16),
          ],
        ),
      ),
    );
  }
}
