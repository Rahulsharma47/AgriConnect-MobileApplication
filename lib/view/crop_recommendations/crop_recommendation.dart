// ignore_for_file: deprecated_member_use, use_build_context_synchronously, avoid_print

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';

class CropRecommendationsScreen extends StatefulWidget {
  const CropRecommendationsScreen({super.key});

  @override
  State<CropRecommendationsScreen> createState() => _CropRecommendationsScreenState();
}

class _CropRecommendationsScreenState extends State<CropRecommendationsScreen> {
  final TextEditingController _nitrogenController = TextEditingController();
  final TextEditingController _phosphorusController = TextEditingController();
  final TextEditingController _potassiumController = TextEditingController();
  
  bool _isLoading = false;
  String? _recommendedCrop;
  String? _errorMessage;

  // Corrected API endpoint
  static const String _apiUrl = 'https://nfc-api-l2z3.onrender.com/crop_rec';

  @override
  void dispose() {
    _nitrogenController.dispose();
    _phosphorusController.dispose();
    _potassiumController.dispose();
    super.dispose();
  }

  Future<void> _getRecommendations() async {
    // Validate inputs
    if (_nitrogenController.text.isEmpty ||
        _phosphorusController.text.isEmpty ||
        _potassiumController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all soil nutrient values'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Get weather data from provider
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    
    // Validate weather data is available
    if (appProvider.selectedCity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please set your location first from the home screen'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _recommendedCrop = null;
    });

    try {
      // Parse input values
      final nitrogen = double.parse(_nitrogenController.text);
      final phosphorus = double.parse(_phosphorusController.text);
      final potassium = double.parse(_potassiumController.text);

      // Prepare request body with lowercase keys as API expects
      final requestBody = {
        'n': nitrogen,
        'p': phosphorus,
        'k': potassium,
        'temperature': appProvider.temperature,
        'humidity': appProvider.humidity,
        'ph': appProvider.phValue,
        'rainfall': appProvider.rainfall,
      };

      print('Sending request to: $_apiUrl');
      print('Request body: ${json.encode(requestBody)}');

      // Make API request
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection.');
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // API returns {"predictions": ["rice"]}
        if (data['predictions'] != null && data['predictions'].isNotEmpty) {
          setState(() {
            _recommendedCrop = data['predictions'][0];
            _isLoading = false;
          });

          // Show success dialog
          _showRecommendationDialog();
        } else {
          setState(() {
            _errorMessage = 'No recommendation received from server';
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to get recommendation. Status: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } on FormatException {
      setState(() {
        _errorMessage = 'Please enter valid numbers for NPK values';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  void _showRecommendationDialog() {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.agriculture,
                  size: 48,
                  color: Color(0xFF4CAF50),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Recommended Crop',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),
              
              // Crop name
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _recommendedCrop!.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              // Info text
              Text(
                'This crop is best suited for your current soil and weather conditions',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, AppProvider>(
      builder: (context, themeProvider, appProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8FAF9),
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            foregroundColor: isDark ? Colors.white : const Color(0xFF4CAF50),
            title: Text(
              'Crop Recommendations',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : const Color(0xFF4CAF50),
              ),
            ),
            centerTitle: true,
            elevation: 0,
            iconTheme: IconThemeData(
              color: isDark ? Colors.white : const Color(0xFF4CAF50),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Current Conditions',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on your location and weather',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                // Weather Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Location
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: Colors.white,
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              appProvider.selectedCity.isNotEmpty 
                                  ? appProvider.selectedCity 
                                  : 'Set location from home',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.wb_sunny,
                            color: Colors.white70,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            appProvider.weatherCondition,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Colors.white30,
                        height: 30,
                        thickness: 1,
                      ),
                      // Weather Parameters Grid
                      Row(
                        children: [
                          Expanded(
                            child: _buildWeatherParam(
                              icon: Icons.thermostat,
                              label: 'Temperature',
                              value: '${appProvider.temperature.toStringAsFixed(1)}°C',
                            ),
                          ),
                          Expanded(
                            child: _buildWeatherParam(
                              icon: Icons.water_drop,
                              label: 'Humidity',
                              value: '${appProvider.humidity.toStringAsFixed(0)}%',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildWeatherParam(
                              icon: Icons.science,
                              label: 'pH Value',
                              value: appProvider.phValue.toStringAsFixed(1),
                            ),
                          ),
                          Expanded(
                            child: _buildWeatherParam(
                              icon: Icons.water,
                              label: 'Rainfall',
                              value: '${appProvider.rainfall.toStringAsFixed(1)} mm',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Soil Information Section
                Text(
                  'Soil Nutrient Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter NPK values for accurate recommendations',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 20),

                // Soil Input Container
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
                      // Nitrogen (N)
                      _buildSoilInputLabel(
                        'Nitrogen (N)',
                        Icons.science,
                        isDark,
                        Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      _buildSoilTextField(
                        controller: _nitrogenController,
                        hintText: 'Enter nitrogen content (0-140)',
                        suffix: 'mg/kg',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),

                      // Phosphorus (P)
                      _buildSoilInputLabel(
                        'Phosphorus (P)',
                        Icons.science,
                        isDark,
                        Colors.orange,
                      ),
                      const SizedBox(height: 8),
                      _buildSoilTextField(
                        controller: _phosphorusController,
                        hintText: 'Enter phosphorus content (5-145)',
                        suffix: 'mg/kg',
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),

                      // Potassium (K)
                      _buildSoilInputLabel(
                        'Potassium (K)',
                        Icons.science,
                        isDark,
                        Colors.purple,
                      ),
                      const SizedBox(height: 8),
                      _buildSoilTextField(
                        controller: _potassiumController,
                        hintText: 'Enter potassium content (5-205)',
                        suffix: 'mg/kg',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Error message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Get Recommendations Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _getRecommendations,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      shadowColor: const Color(0xFF4CAF50).withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.agriculture, size: 24),
                              SizedBox(width: 12),
                              Text(
                                'Get Crop Recommendations',
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: isDark
                            ? const Color(0xFF66BB6A)
                            : const Color(0xFF2E7D32),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'How to measure NPK?',
                              style: TextStyle(
                                color: isDark ? Colors.white : const Color(0xFF2E7D32),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Use a soil testing kit or visit your nearest agricultural center for accurate NPK measurements. Typical ranges: N (0-140), P (5-145), K (5-205) mg/kg.',
                              style: TextStyle(
                                color: isDark ? Colors.grey[400] : const Color(0xFF2E7D32),
                                fontSize: 12,
                                height: 1.4,
                              ),
                            ),
                          ],
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

  Widget _buildWeatherParam({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSoilInputLabel(
    String label,
    IconData icon,
    bool isDark,
    Color accentColor,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: accentColor,
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

  Widget _buildSoilTextField({
    required TextEditingController controller,
    required String hintText,
    required String suffix,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        color: isDark ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: isDark ? Colors.grey[600] : Colors.grey[400],
          fontSize: 14,
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: isDark ? Colors.grey[500] : Colors.grey[600],
          fontWeight: FontWeight.w600,
        ),
        filled: true,
        fillColor: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[800]! : Colors.grey[200]!,
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
    );
  }
}