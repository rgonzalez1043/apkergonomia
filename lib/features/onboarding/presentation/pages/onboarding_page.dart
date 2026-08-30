import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/router/route_names.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../shared/widgets/ergo_button.dart';
import '../../data/onboarding_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.self_improvement_rounded,
      title: 'Tu salud es lo primero',
      description:
          'ErgoWorkCoach combina bienestar postural, emocional y cognitivo en una sola app.',
      color: AppColors.primary,
    ),
    _OnboardingSlide(
      icon: Icons.accessibility_new_rounded,
      title: 'Pain Manager Inteligente',
      description:
          'Registra tus zonas de dolor y recibe ejercicios personalizados por región y nivel.',
      color: AppColors.painModule,
    ),
    _OnboardingSlide(
      icon: Icons.air_rounded,
      title: 'Respira con propósito',
      description:
          '8 técnicas de respiración para cada situación: estrés, concentración, energía y más.',
      color: AppColors.breathingModule,
    ),
    _OnboardingSlide(
      icon: Icons.emoji_events_rounded,
      title: 'Gamificación real',
      description:
          'Gana XP, desbloquea logros y construye rachas diarias hacia hábitos saludables.',
      color: AppColors.gamificationModule,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      await _finishOnboarding();
    }
  }

  Future<void> _finishOnboarding() async {
    await OnboardingPreferences.markCompleted();
    if (mounted) context.go(RouteNames.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                child: const Text('Omitir'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _slides.length,
                itemBuilder: (context, i) => _SlideContent(slide: _slides[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _slides.length,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: i == _currentPage ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: i == _currentPage
                              ? AppColors.primary
                              : Theme.of(context).dividerColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppDimensions.lg),
                  ErgoButton(
                    label: _currentPage == _slides.length - 1
                        ? 'Comenzar'
                        : 'Siguiente',
                    onPressed: _next,
                    icon: _currentPage == _slides.length - 1
                        ? Icons.rocket_launch_rounded
                        : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideContent extends StatelessWidget {
  final _OnboardingSlide slide;
  const _SlideContent({required this.slide});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: slide.color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(slide.icon, size: 56, color: slide.color),
          ),
          const SizedBox(height: AppDimensions.xl),
          Text(
            slide.title,
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.md),
          Text(
            slide.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingSlide {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  const _OnboardingSlide(
      {required this.icon,
      required this.title,
      required this.description,
      required this.color});
}
