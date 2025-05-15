import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../utils/colors.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback onFinish;
  final bool isDark;

  const OnboardingScreen({
    super.key,
    required this.onFinish,
    required this.isDark,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Returns black or white depending on background brightness for best contrast
  Color _getTextColor(Color background) {
    // Calculate luminance (0.0 = black, 1.0 = white)
    return background.computeLuminance() > 0.5 ? Colors.white : Colors.white;
  }

  final List<_OnboardPage> _pages = [
    _OnboardPage(
      imagePath: 'assets/onboarding/todo_list.svg',
      title: 'Task Management',
      desc: 'View all your current to-dos, add new, and track completion.',
      backgroundColor: AppColors.onboardingBlue,
    ),
    _OnboardPage(
      imagePath: 'assets/onboarding/prioritise_task.svg',
      title: 'Priorities Your Important Task',
      desc: 'Assign low, medium, or high priority badges to your tasks.',
      backgroundColor: AppColors.onboardingYellow,
    ),
    _OnboardPage(
      imagePath: 'assets/onboarding/reminder.svg',
      title: 'Get Notify On Time',
      desc: 'Set deadlines and get reminders for important tasks.',
      backgroundColor: AppColors.onboardingPurple,
    ),
    _OnboardPage(
      imagePath: 'assets/onboarding/swipe_options.svg',
      title: 'Swipe Gestures',
      desc: 'Swipe left to delete or edit, right to complete tasks quickly.',
      backgroundColor: AppColors.onboardingGreen,
    ),
  ];
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final page = _pages[_pageIndex];
    return Scaffold(
      backgroundColor: page.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top empty space for better centering on tall screens
            const SizedBox(height: 24),
            // Centered content
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      page.imagePath,
                      height: 180,
                      width: 180,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      page.title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(page.backgroundColor),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page.desc,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.normal,
                        color: _getTextColor(page.backgroundColor),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            // Bottom controls
            Column(
              children: [
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: _pageIndex == 0
                          ? null
                          : () {
                              setState(() => _pageIndex--);
                            },
                      child: const Text('Previous'),
                    ),
                    Expanded(
                      child: Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(
                            _pages.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: i == _pageIndex
                                    ? Colors.white
                                    : theme.disabledColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: _pageIndex == _pages.length - 1
                          ? widget.onFinish
                          : () {
                              setState(() => _pageIndex++);
                            },
                      child: Text(
                        _pageIndex == _pages.length - 1 ? 'Get Start' : 'Next',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String imagePath;
  final String title;
  final String desc;
  final Color backgroundColor;

  const _OnboardPage({
    required this.imagePath,
    required this.title,
    required this.desc,
    required this.backgroundColor,
  });
}
