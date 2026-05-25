import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stikerz/core/constants/app_colors.dart';
import 'package:stikerz/core/providers/onboarding_provider.dart';
import 'package:stikerz/core/utils/responsive_text.dart';
import 'package:stikerz/ui/features/onboarding/presentation/widgets/onboarding_page_1_welcome.dart';
import 'package:stikerz/ui/features/onboarding/presentation/widgets/onboarding_page_2_add_videos.dart';
import 'package:stikerz/ui/features/onboarding/presentation/widgets/onboarding_page_3_share_direct.dart';
import 'package:stikerz/ui/features/onboarding/presentation/widgets/onboarding_page_4_ads.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  final bool showAnimations;

  const OnboardingPage({super.key, this.showAnimations = true});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late PageController _pageController;
  int _currentPage = 0;
  static const int _totalPages = 4;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    await ref.read(onboardingNotifierProvider.notifier).completeOnboarding();
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _currentPage > 0) {
          _previousPage();
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Main vertical pager.
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              allowImplicitScrolling: true,
              itemCount: _totalPages,
              onPageChanged: (page) {
                setState(() => _currentPage = page);
              },
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return RepaintBoundary(
                      child: OnboardingPage1Welcome(
                        showAnimations: widget.showAnimations,
                      ),
                    );
                  case 1:
                    return RepaintBoundary(
                      child: OnboardingPage2AddVideos(
                        showAnimations: widget.showAnimations,
                      ),
                    );
                  case 2:
                    return RepaintBoundary(
                      child: OnboardingPage3ShareDirect(
                        showAnimations: widget.showAnimations,
                      ),
                    );
                  case 3:
                    return RepaintBoundary(
                      child: OnboardingPage4Ads(
                        onFinish: _completeOnboarding,
                        initialSeconds: widget.showAnimations
                            ? kOnboardingPage4InitialSeconds
                            : 0,
                      ),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
            // Right-side vertical progress dots.
            Positioned(
              right: context.responsiveSize(24, tabletSize: 32),
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _totalPages,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _currentPage == index
                          ? context.responsiveSize(12, tabletSize: 14)
                          : context.responsiveSize(8, tabletSize: 10),
                      height: _currentPage == index
                          ? context.responsiveSize(12, tabletSize: 14)
                          : context.responsiveSize(8, tabletSize: 10),
                      decoration: BoxDecoration(
                        color: _currentPage == index
                            ? AppColors.accent
                            : AppColors.border,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
