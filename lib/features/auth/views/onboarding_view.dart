import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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
      'subtitle': 'Discover latest styles at best prices with curated designer collections.',
      'image': 'https://images.unsplash.com/photo-1483985988355-763728e1935b?w=800',
    },
    {
      'title': 'Curated Designer\nCollections',
      'subtitle': 'Handpicked premium fashion from top global brands with instant try-on.',
      'image': 'https://images.unsplash.com/photo-1490481651871-ab68de25d43d?w=800',
    },
    {
      'title': 'Express Fast\nDoorstep Delivery',
      'subtitle': 'Hassle-free 7-day returns, live order tracking & cash on delivery available.',
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 860;

            if (isDesktop) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Left 50%: Hero Image Slider
                        Expanded(
                          flex: 5,
                          child: Container(
                            height: 520,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x18000000),
                                  blurRadius: 24,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(28),
                              child: PageView.builder(
                                controller: _pageController,
                                itemCount: _slides.length,
                                onPageChanged: (idx) => setState(() => _currentPage = idx),
                                itemBuilder: (context, index) {
                                  return Image.network(
                                    _slides[index]['image']!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(color: AppColors.primaryLight),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 48),

                        // Right 50%: Content & Navigation
                        Expanded(
                          flex: 5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryLight,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'STYLEHUB FASHION',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: AppColors.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                _slides[_currentPage]['title']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0F172A),
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                _slides[_currentPage]['subtitle']!,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  color: const Color(0xFF64748B),
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 28),
                              _buildPageIndicators(),
                              const SizedBox(height: 36),
                              Row(
                                children: [
                                  SizedBox(
                                    width: 220,
                                    height: 50,
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
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                      ),
                                      child: Text(
                                        _currentPage == _slides.length - 1 ? 'Get Started' : 'Next',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  TextButton(
                                    onPressed: _finishOnboarding,
                                    child: Text(
                                      'Skip',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF64748B),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
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

            // Mobile Layout
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  children: [
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
                                  style: GoogleFonts.plusJakartaSans(
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
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                _buildPageIndicators(),
                              ],
                            ),
                            Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
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
                                const SizedBox(height: 12),
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
            );
          },
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
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
    );
  }
}
