// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _plantController;
  late AnimationController _glowController;
  late AnimationController _leafController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _plantGrowAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _leafRotation;

  @override
  void initState() {
    super.initState();

    // Transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    _fadeController =
        AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _scaleController =
        AnimationController(duration: const Duration(milliseconds: 1200), vsync: this);
    _slideController =
        AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _plantController =
        AnimationController(duration: const Duration(milliseconds: 2000), vsync: this)
          ..repeat(reverse: true);
    _glowController =
        AnimationController(duration: const Duration(seconds: 2), vsync: this)
          ..repeat(reverse: true);
    _leafController =
        AnimationController(duration: const Duration(milliseconds: 3000), vsync: this)
          ..repeat();

    _fadeAnimation = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _plantGrowAnimation = Tween(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _plantController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _leafRotation = Tween(begin: 0.0, end: 2 * 3.14159).animate(
      CurvedAnimation(parent: _leafController, curve: Curves.linear),
    );

    _startAnimations();

    // Navigate to home
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _scaleController.forward();
    _fadeController.forward();

    await Future.delayed(const Duration(milliseconds: 500));
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _plantController.dispose();
    _glowController.dispose();
    _leafController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A), Color(0xFFA5D6A7)],
          ),
        ),
        child: Stack(
          children: [
            // Animated background elements
            _buildBackgroundElements(),
            
            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Enhanced Logo
                  _buildEnhancedLogo(),
                  
                  const SizedBox(height: 50),

                  // App name with glow
                  _buildAppTitle(),

                  const SizedBox(height: 80),

                  // Enhanced growing elements
                  _buildGrowingElements(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundElements() {
    return AnimatedBuilder(
      animation: _leafController,
      builder: (context, child) {
        return Stack(
          children: [
            // Floating leaves
            Positioned(
              top: 100 + (30 * _plantGrowAnimation.value),
              left: 50,
              child: Transform.rotate(
                angle: _leafRotation.value * 0.5,
                child: Icon(
                  Icons.eco,
                  size: 20,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              top: 200 + (20 * _plantGrowAnimation.value),
              right: 80,
              child: Transform.rotate(
                angle: -_leafRotation.value * 0.3,
                child: Icon(
                  Icons.local_florist,
                  size: 16,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              bottom: 150 + (40 * _plantGrowAnimation.value),
              left: 30,
              child: Transform.rotate(
                angle: _leafRotation.value * 0.2,
                child: Icon(
                  Icons.grass,
                  size: 24,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),
            Positioned(
              bottom: 100 + (25 * _plantGrowAnimation.value),
              right: 40,
              child: Transform.rotate(
                angle: -_leafRotation.value * 0.4,
                child: Icon(
                  Icons.nature,
                  size: 18,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEnhancedLogo() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  // Outer glow
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4 * _glowAnimation.value),
                    blurRadius: 30,
                    spreadRadius: 8,
                  ),
                  // Inner glow
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2 * _glowAnimation.value),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF66BB6A).withOpacity(0.9),
                    Color(0xFF43A047).withOpacity(0.95),
                    Color(0xFF2E7D32).withOpacity(1.0),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                ),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Main plant icon
                  Transform.scale(
                    scale: _plantGrowAnimation.value,
                    child: const Icon(
                      Icons.eco,
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Smaller decorative elements around the main icon
                  Positioned(
                    top: 25,
                    right: 25,
                    child: Transform.rotate(
                      angle: _leafRotation.value * 0.5,
                      child: Icon(
                        Icons.local_florist,
                        size: 16,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ),
                  
                  Positioned(
                    bottom: 30,
                    left: 30,
                    child: Transform.rotate(
                      angle: -_leafRotation.value * 0.3,
                      child: Icon(
                        Icons.grass,
                        size: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.appTitle,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          blurRadius: 20 * _glowAnimation.value,
                          color: Colors.black.withOpacity(0.5),
                          offset: const Offset(2, 2),
                        ),
                        Shadow(
                          blurRadius: 10 * _glowAnimation.value,
                          color: Colors.white.withOpacity(0.3),
                          offset: const Offset(-1, -1),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.smartFarming,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGrowingElements() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left plant
          AnimatedBuilder(
            animation: _plantController,
            builder: (context, child) {
              return Transform.scale(
                scale: _plantGrowAnimation.value,
                child: Transform.rotate(
                  angle: _leafRotation.value * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.local_florist,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 30),
          
          // Center seedling
          AnimatedBuilder(
            animation: _plantController,
            builder: (context, child) {
              return Transform.scale(
                scale: _plantGrowAnimation.value * 1.2,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.white.withOpacity(0.1),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.spa,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(width: 30),
          
          // Right plant
          AnimatedBuilder(
            animation: _plantController,
            builder: (context, child) {
              return Transform.scale(
                scale: _plantGrowAnimation.value,
                child: Transform.rotate(
                  angle: -_leafRotation.value * 0.1,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                    ),
                    child: const Icon(
                      Icons.eco,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}