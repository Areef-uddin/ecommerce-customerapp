import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/storage_service.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Trendy Fashion\nFor Every You',
      'subtitle': 'Discover latest styles at best prices',
      'image': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
    },
    {
      'title': 'Curated Designer\nCollections',
      'subtitle': 'Handpicked premium fashion from top global brands',
      'image': 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
    },
    {
      'title': 'Express Fast\nDoorstep Delivery',
      'subtitle': 'Hassle-free 7-day returns & cash on delivery',
      'image': 'https://images.unsplash.com/photo-1492707892479-7bc8d5a4ee93?w=800',
    },
  ];

  void _finishOnboarding() async {
    await StorageService.setOnboarded(true);
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
          children: [
            // Top Image Carousel
            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        _slides[index]['image']!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Bottom Content
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text(
                          _slides[_currentPage]['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _slides[_currentPage]['subtitle']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Page indicator dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _slides.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: _currentPage == index ? 24 : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _currentPage == index ? AppColors.primary : const Color(0xFFE5E7EB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Buttons
                    Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_currentPage < _slides.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _finishOnboarding();
                              }
                            },
                            child: Text(_currentPage == _slides.length - 1 ? 'Get Started' : 'Next'),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _finishOnboarding,
                          child: const Text(
                            'Skip',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    ),
  );
}
}
