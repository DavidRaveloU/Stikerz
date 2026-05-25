import 'package:flutter/material.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutCard extends StatelessWidget {
  final String name;
  final String role;
  final String description;
  final String appName;
  final String version;
  final String instagramUrl;
  final String githubUrl;
  final String emailAddress;

  const AboutCard({
    super.key,
    required this.name,
    required this.role,
    required this.description,
    required this.appName,
    required this.version,
    required this.instagramUrl,
    required this.githubUrl,
    required this.emailAddress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, Color(0xFF0F0715)],
          ),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(160),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 32, 28, 20),
                child: Column(
                  children: [
                    _buildAvatar(),
                    const SizedBox(height: 20),
                    Text(
                      name,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      role.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2.0,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        height: 1.7,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton(
                          icon: Icons.alternate_email,
                          onPressed: () => _openExternalUrl(instagramUrl),
                        ),
                        const SizedBox(width: 10),
                        _socialButton(
                          icon: Icons.code,
                          onPressed: () => _openExternalUrl(githubUrl),
                        ),
                        const SizedBox(width: 10),
                        _socialButton(
                          icon: Icons.mail_outline,
                          onPressed: () => _openEmail(emailAddress),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      appName,
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.2),
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        version,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 10,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    final initials = name.isNotEmpty
        ? name.split(' ').map((s) => s[0]).take(2).join()
        : '?';

    return Stack(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.accent, Color(0xFF7AA82B)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: CircleAvatar(
              backgroundColor: AppColors.background,
              child: Text(
                initials,
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.accent,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.background, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _socialButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 17, color: AppColors.textPrimary),
        onPressed: onPressed,
      ),
    );
  }
}
