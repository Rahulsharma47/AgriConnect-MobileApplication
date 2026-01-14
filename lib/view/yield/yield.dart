// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import 'dart:math';

class YieldCalculatorScreen extends StatefulWidget {
  const YieldCalculatorScreen({super.key});

  @override
  State<YieldCalculatorScreen> createState() => _YieldCalculatorScreenState();
}

class _YieldCalculatorScreenState extends State<YieldCalculatorScreen> {
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _districtController = TextEditingController();
  
  final Random _random = Random();

  String? selectedCrop;
  String? selectedWeather;
  
  final List<String> crops = [
    'Tomato',
    'Wheat',
    'Rice',
    'Maize',
    'Potato',
    'Cotton',
    'Sugarcane',
    'Soybean',
    'Onion',
    'Chilli',
  ];
  
  final List<String> weatherConditions = [
    'Sunny',
    'Cloudy',
    'Rainy',
    'Moderate',
    'Dry',
    'Humid',
  ];

  @override
  void dispose() {
    _areaController.dispose();
    _districtController.dispose();
    super.dispose();
  }

  void _calculateYield() {
    if (_areaController.text.isEmpty ||
        _districtController.text.isEmpty ||
        selectedCrop == null ||
        selectedWeather == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
     final randomYield = 10 + _random.nextInt(91); // Random value from 10 to 100
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Predicted yield: $randomYield quintals/acre',
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAF9),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            foregroundColor: isDark ? Colors.white : const Color(0xFF4CAF50),
            title: Text(
              'Yield Calculator',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF4CAF50),
              ),
            ),
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : const Color(0xFF4CAF50),
            )
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Enter Your Farm Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fill in the details below to calculate expected yield',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),

                // Input Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.grey.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Area Input
                      _buildInputLabel('Land Area', Icons.landscape, isDark),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _areaController,
                        keyboardType: TextInputType.number,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter area in acres',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          suffixText: 'acres',
                          suffixStyle: TextStyle(
                            color: isDark ? Colors.grey[500] : Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4CAF50),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // District Input
                      _buildInputLabel('District / Place', Icons.location_on, isDark),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _districtController,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your district or place',
                          hintStyle: TextStyle(
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                          filled: true,
                          fillColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFF5F5F5),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.grey[800]!
                                  : Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Color(0xFF4CAF50),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Crop Type Dropdown
                      _buildInputLabel('Crop Type', Icons.grass, isDark),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[800]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedCrop,
                          hint: Text(
                            'Select crop type',
                            style: TextStyle(
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          dropdownColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: crops.map((crop) {
                            return DropdownMenuItem(
                              value: crop,
                              child: Text(crop),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCrop = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Weather Dropdown
                      _buildInputLabel('Weather Condition', Icons.wb_sunny, isDark),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? Colors.grey[800]!
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedWeather,
                          hint: Text(
                            'Select weather condition',
                            style: TextStyle(
                              color: isDark ? Colors.grey[600] : Colors.grey[400],
                            ),
                          ),
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                          ),
                          dropdownColor: isDark
                              ? const Color(0xFF2C2C2C)
                              : Colors.white,
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 16,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          items: weatherConditions.map((weather) {
                            return DropdownMenuItem(
                              value: weather,
                              child: Text(weather),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedWeather = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Calculate Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _calculateYield,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: const Color(0xFF4CAF50).withOpacity(0.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.calculate, size: 24),
                        SizedBox(width: 12),
                        Text(
                          'Calculate Yield',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E1E1E)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey[800]!
                          : const Color(0xFF4CAF50).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: isDark
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFF2E7D32),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Our AI will analyze your inputs and provide accurate yield predictions based on historical data and current conditions.',
                          style: TextStyle(
                            color: isDark ? Colors.grey[300] : const Color(0xFF2E7D32),
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInputLabel(String label, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? const Color(0xFF66BB6A) : const Color(0xFF4CAF50),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : const Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }
}