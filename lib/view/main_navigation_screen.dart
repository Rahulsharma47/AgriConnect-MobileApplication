// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'package:agrconnect/view/chatbot/chatbot.dart';
import 'package:agrconnect/view/community/community.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home/home.dart';
import 'crop_recommendations/crop_recommendation.dart';
import 'yield/yield.dart';
//import 'home/disease.dart';
import '../providers/bottom_nav_provider.dart';
import '../providers/theme_provider.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late PageController _pageController;

  final List<Widget> _screens = const [
    HomeScreen(),
    CropRecommendationsScreen(),
    ChatbotScreen(),
    YieldCalculatorScreen(),
    CommunityScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseController.repeat(reverse: true);
    
    _pageController = PageController(
      initialPage: context.read<BottomNavProvider>().currentIndex,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Consumer<BottomNavProvider>(
      builder: (context, navProvider, child) {
        return Scaffold(
          body: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              navProvider.setCurrentIndex(index);
            },
            children: _screens
          ),
          bottomNavigationBar: Container(
            height: 90,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDarkMode ? 0.3 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.05),
                  blurRadius: 30,
                  offset: const Offset(0, -10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              child: Stack(
                children: [
                  // Animated wave background
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: WavePainter(
                            _pulseController.value,
                            theme.colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Navigation items
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          _buildNavSection([
                            _buildNavItem(0, Icons.home_rounded, 'Home', navProvider, theme),
                            _buildAnimatedDivider(theme),
                            _buildNavItem(1, Icons.eco_rounded, 'Crops', navProvider, theme),
                          ]),
                          
                          Expanded(
                            child: Center(child: _buildEnhancedAIButton(navProvider, theme)),
                          ),
                          
                          _buildNavSection([
                            _buildNavItem(3, Icons.analytics_rounded, 'Yield', navProvider, theme),
                            _buildAnimatedDivider(theme),
                            _buildNavItem(4, Icons.people_alt_outlined, 'Community', navProvider, theme),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavSection(List<Widget> children) {
    return Expanded(
      flex: 2,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: children,
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, BottomNavProvider navProvider, ThemeData theme) {
    final isSelected = navProvider.currentIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onNavItemTapped(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 90,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: isSelected ? 1.1 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: isSelected ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary,
                      ],
                    ) : null,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ] : [],
                  ),
                  child: Icon(
                    icon,
                    color: isSelected 
                        ? Colors.white 
                        : theme.colorScheme.onSurface.withOpacity(0.5),
                    size: 26,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: isSelected 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.onSurface.withOpacity(0.5),
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedDivider(ThemeData theme) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 1.5,
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                theme.colorScheme.onSurface.withOpacity(
                  0.1 + (_pulseController.value * 0.1)
                ),
                theme.colorScheme.onSurface.withOpacity(
                  0.2 + (_pulseController.value * 0.2)
                ),
                theme.colorScheme.onSurface.withOpacity(
                  0.1 + (_pulseController.value * 0.1)
                ),
                Colors.transparent,
              ],
            ),
            borderRadius: BorderRadius.circular(1),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedAIButton(BottomNavProvider navProvider, ThemeData theme) {
    final isSelected = navProvider.isAISelected;
    
    return GestureDetector(
      onTap: () => _onNavItemTapped(2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected ? [
                  const Color(0xFF2E7D32),
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                ] : [
                  theme.colorScheme.primary,
                  theme.colorScheme.secondary,
                  const Color(0xFF81C784),
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: theme.colorScheme.surface.withOpacity(0.9),
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Ripple effect for selected state
                if (isSelected) ...[
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1 + (_animationController.value * 0.2),
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(
                                0.8 - (_animationController.value * 0.8),
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
                
                // Main icon
                const Icon(
                  Icons.psychology_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 300),
            style: TextStyle(
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.onSurface.withOpacity(0.5),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            child: const Text('Ask AI'),
          ),
        ],
      ),
    );
  }
}

class WavePainter extends CustomPainter {
  final double animationValue;
  final Color primaryColor;

  WavePainter(this.animationValue, this.primaryColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    final path = Path();
    final waveHeight = 4.0;
    final waveLength = size.width / 2;

    path.moveTo(0, size.height);
    
    for (double x = 0; x <= size.width; x++) {
      final y = size.height - 10 + 
          waveHeight * sin((x / waveLength * 2 * 3.14159) + (animationValue * 2 * 3.14159));
      path.lineTo(x, y);
    }
    
    path.lineTo(size.width, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}