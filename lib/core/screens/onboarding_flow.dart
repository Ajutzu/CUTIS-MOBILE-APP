import 'package:flutter/material.dart';
import '../widgets/onboarding_page.dart';
import '../theme/app_styles.dart';
import 'login.dart';

class OnboardingFlowScreen extends StatefulWidget {
  const OnboardingFlowScreen({Key? key}) : super(key: key);

  @override
  State<OnboardingFlowScreen> createState() => _OnboardingFlowScreenState();
}

class _OnboardingFlowScreenState extends State<OnboardingFlowScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Onboarding content
  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/images/ImageOne.png',
      'title': 'Welcome to Cutis',
      'description': 'Your personal skin health companion. Get started by analyzing your skin condition.',
    },
    {
      'image': 'assets/images/ImageTwo.png',
      'title': 'Instant Analysis',
      'description': 'Take a photo and get an instant analysis of your skin condition with our AI technology.',
    },
    {
      'image': 'assets/images/ImageThree.png',
      'title': 'Chat with our A.I.',
      'description': 'Incorporating a Gemini AI-powered chatbot to answer health-related queries and explain results',
    },
  ];

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _skipOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                return OnboardingPage(
                  imagePath: _onboardingData[index]['image']!,
                  title: _onboardingData[index]['title']!,
                  description: _onboardingData[index]['description']!,
                );
              },
            ),
            // Skip Button
            Positioned(
              top: 16,
              right: 16,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text('Skip', style: AppTextStyles.link),
              ),
            ),
            // Bottom Controls (Dots and Buttons)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots Indicator
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 10,
                        width: _currentPage == index ? 30 : 10,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: _currentPage == index ? AppColors.primary : AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  // Next/Done Button
                  FloatingActionButton(
                    onPressed: () {
                      if (_currentPage == _onboardingData.length - 1) {
                        _skipOnboarding(); // Same action as skip
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    backgroundColor: AppColors.primary,
                    child: _currentPage == _onboardingData.length - 1
                        ? Text('Done', style: AppTextStyles.button)
                        : Icon(Icons.arrow_forward, color: AppColors.secondary),
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
