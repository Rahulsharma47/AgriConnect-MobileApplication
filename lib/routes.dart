import 'package:agrconnect/view/community/community.dart';
import 'package:flutter/material.dart';
import 'view/home/camera.dart';
import 'view/chatbot/chatbot.dart';
import 'view/crop_recommendations/crop_recommendation.dart';
import 'view/home/disease.dart';
//import 'view/fertlizers/fertilizer.dart';
import 'view/yield/yield.dart';
import 'view/splash.dart';
import 'view/main_navigation_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/splash': (context) => const SplashScreen(),
  '/home': (context) => const MainNavigationScreen(),
  '/camera': (context) => const CameraScreen(cropName: '',),
  '/chatbot': (context) => const ChatbotScreen(),
  '/crop-recommendations': (context) => const CropRecommendationsScreen(),
  //'/fertilizer': (context) => const FertilizerScreen(),
  '/community': (context) => const CommunityScreen(),
  '/yield-calculator': (context) => const YieldCalculatorScreen(),
  '/disease-guide': (context) => const CropSelectorScreen(),
};
