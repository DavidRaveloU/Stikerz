import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:whaticker/core/constants/app_colors.dart';
import 'package:whaticker/core/providers/onboarding_provider.dart';
import 'package:whaticker/ui/features/onboarding/presentation/widgets/onboarding_page_1_welcome.dart';
import 'package:whaticker/ui/features/onboarding/presentation/widgets/onboarding_page_2_add_videos.dart';
import 'package:whaticker/ui/features/onboarding/presentation/widgets/onboarding_page_3_share_direct.dart';
import 'package:whaticker/ui/features/onboarding/presentation/widgets/onboarding_page_4_ads.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

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
            // Contenido principal con PageView (builder + preload hints)
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
                    return const RepaintBoundary(
                      child: OnboardingPage1Welcome(),
                    );
                  case 1:
                    return const RepaintBoundary(
                      child: OnboardingPage2AddVideos(),
                    );
                  case 2:
                    return const RepaintBoundary(
                      child: OnboardingPage3ShareDirect(),
                    );
                  case 3:
                    return RepaintBoundary(
                      child: OnboardingPage4Ads(onFinish: _completeOnboarding),
                    );
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
            // Dots de progreso vertical a la derecha
            Positioned(
              right: 24,
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
                      width: _currentPage == index ? 12 : 8,
                      height: _currentPage == index ? 12 : 8,
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
