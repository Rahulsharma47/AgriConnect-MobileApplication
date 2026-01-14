import 'package:flutter/material.dart';

class BottomNavProvider extends ChangeNotifier {
  int _currentIndex = 0;
  
  // Getter for current selected index
  int get currentIndex => _currentIndex;
  
  // Screen names for better debugging and analytics
  final List<String> _screenNames = [
    'Home',
    'Crops',
    'Ask AI',
    'Yield',
    'Diseases',
  ];
  
  // Get current screen name
  String get currentScreenName => _screenNames[_currentIndex];
  
  // Check if specific screens are selected
  bool get isHomeSelected => _currentIndex == 0;
  bool get isCropsSelected => _currentIndex == 1;
  bool get isAISelected => _currentIndex == 2;
  bool get isYieldSelected => _currentIndex == 3;
  bool get isDiseasesSelected => _currentIndex == 4;
  
  // Method to change current index
  void setCurrentIndex(int index) {
    if (index >= 0 && index < _screenNames.length && _currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
      
      // Optional: Add analytics or logging here
      debugPrint('Navigation changed to: ${_screenNames[index]} (Index: $index)');
    }
  }
  
  // Method to navigate by screen name (useful for deep linking)
  void navigateToScreen(String screenName) {
    final index = _screenNames.indexOf(screenName);
    if (index != -1) {
      setCurrentIndex(index);
    }
  }
  
  // Method to go to next screen (useful for onboarding flows)
  void goToNext() {
    if (_currentIndex < _screenNames.length - 1) {
      setCurrentIndex(_currentIndex + 1);
    }
  }
  
  // Method to go to previous screen
  void goToPrevious() {
    if (_currentIndex > 0) {
      setCurrentIndex(_currentIndex - 1);
    }
  }
  
  // Reset to home screen
  void resetToHome() {
    setCurrentIndex(0);
  }
  
  // Get screen name by index
  String getScreenName(int index) {
    if (index >= 0 && index < _screenNames.length) {
      return _screenNames[index];
    }
    return 'Unknown';
  }
  
  // Check if can navigate to next
  bool get canGoNext => _currentIndex < _screenNames.length - 1;
  
  // Check if can navigate to previous
  bool get canGoPrevious => _currentIndex > 0;
}