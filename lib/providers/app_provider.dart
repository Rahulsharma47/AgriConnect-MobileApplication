// ignore_for_file: prefer_final_fields

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AppProvider extends ChangeNotifier {
  String _selectedCity = 'Delhi';
  double _temperature = 25.0;
  String _weatherCondition = 'Sunny';
  double _humidity = 65.0;
  double _phValue = 7.0; // Added pH value
  double _rainfall = 0.0; // Added rainfall
  double _windSpeed = 12.0;
  List<String> _chatMessages = [];
  String _selectedCrop = 'Tomato';
  double _landArea = 1.0;
  bool _isLoadingWeather = false;
  String? _weatherError;
  
  // API key - Store this securely in production (use flutter_dotenv or similar)
  static const String _apiKey = 'REMOVED_API_KEY';
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  // Getters
  String get selectedCity => _selectedCity;
  double get temperature => _temperature;
  String get weatherCondition => _weatherCondition;
  double get humidity => _humidity;
  double get phValue => _phValue;
  double get rainfall => _rainfall;
  double get windSpeed => _windSpeed;
  List<String> get chatMessages => _chatMessages;
  String get selectedCrop => _selectedCrop;
  double get landArea => _landArea;
  bool get isLoadingWeather => _isLoadingWeather;
  String? get weatherError => _weatherError;
  
  // Setters
  void setSelectedCity(String city) {
    _selectedCity = city;
    notifyListeners();
  }
  
  void setSelectedCrop(String crop) {
    _selectedCrop = crop;
    notifyListeners();
  }
  
  void setLandArea(double area) {
    _landArea = area;
    notifyListeners();
  }
  
  void addChatMessage(String message) {
    _chatMessages.add(message);
    notifyListeners();
  }
  
  // Fetch weather data from API by city name
  Future<bool> fetchWeatherByCity(String cityName) async {
    _isLoadingWeather = true;
    _weatherError = null;
    notifyListeners();
    
    try {
      final url = Uri.parse('$_baseUrl?q=$cityName&appid=$_apiKey&units=metric');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection.');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateWeatherFromApi(data);
        _weatherError = null;
        _isLoadingWeather = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 404) {
        _weatherError = 'City not found';
        _setDefaultWeather();
        _isLoadingWeather = false;
        notifyListeners();
        return false;
      } else {
        _weatherError = 'Unable to fetch weather data';
        _setDefaultWeather();
        _isLoadingWeather = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _weatherError = e.toString().replaceAll('Exception: ', '');
      _setDefaultWeather();
      _isLoadingWeather = false;
      notifyListeners();
      return false;
    }
  }
  
  // Fetch weather data by coordinates (latitude, longitude)
  Future<bool> fetchWeatherByCoordinates(double lat, double lon) async {
    _isLoadingWeather = true;
    _weatherError = null;
    notifyListeners();
    
    try {
      final url = Uri.parse('$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric');
      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Connection timeout. Please check your internet connection.');
        },
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Update city name from API response
        _selectedCity = data['name'] ?? _selectedCity;
        
        _updateWeatherFromApi(data);
        _weatherError = null;
        _isLoadingWeather = false;
        notifyListeners();
        return true;
      } else {
        _weatherError = 'Unable to fetch weather data';
        _setDefaultWeather();
        _isLoadingWeather = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _weatherError = e.toString().replaceAll('Exception: ', '');
      _setDefaultWeather();
      _isLoadingWeather = false;
      notifyListeners();
      return false;
    }
  }
  
  // Update weather data from API response
  void _updateWeatherFromApi(Map<String, dynamic> data) {
    // Temperature
    _temperature = data['main']['temp'].toDouble();
    
    // Humidity
    _humidity = data['main']['humidity'].toDouble();
    
    // Wind speed (convert from m/s to km/h)
    _windSpeed = (data['wind']['speed'].toDouble() * 3.6);
    
    // Weather condition
    _weatherCondition = _getWeatherCondition(data['weather'][0]['main']);
    
    // Rainfall (if available in rain object, otherwise 0)
    if (data.containsKey('rain') && data['rain'] != null) {
      _rainfall = data['rain'].containsKey('1h') 
          ? data['rain']['1h'].toDouble() 
          : (data['rain'].containsKey('3h') 
              ? (data['rain']['3h'].toDouble() / 3) 
              : 0.0);
    } else {
      _rainfall = 0.0;
    }
    
    // Calculate pH based on weather and location
    _phValue = _calculateEstimatedPH(_selectedCity, _rainfall, _humidity, _temperature);
  }
  
  // Convert weather code to readable condition
  String _getWeatherCondition(String mainWeather) {
    switch (mainWeather.toLowerCase()) {
      case 'clear':
        return 'Clear Sky';
      case 'clouds':
        return 'Cloudy';
      case 'rain':
        return 'Rainy';
      case 'drizzle':
        return 'Drizzle';
      case 'thunderstorm':
        return 'Thunderstorm';
      case 'snow':
        return 'Snowy';
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'Hazy';
      default:
        return 'Sunny';
    }
  }
  
  // Calculate estimated pH (simulated - replace with actual soil data API when available)
  double _calculateEstimatedPH(String city, double rainfall, double humidity, double temp) {
    double basePH = 7.0;
    
    // Adjust based on rainfall (more rain = slightly acidic)
    if (rainfall > 5.0) {
      basePH -= 0.5;
    } else if (rainfall > 2.0) {
      basePH -= 0.3;
    } else if (rainfall > 0.5) {
      basePH -= 0.1;
    }
    
    // Adjust based on humidity
    if (humidity > 80) {
      basePH -= 0.3;
    } else if (humidity > 70) {
      basePH -= 0.2;
    } else if (humidity < 40) {
      basePH += 0.3;
    }
    
    // Adjust based on temperature
    if (temp > 35) {
      basePH += 0.2; // Hot and dry tends toward alkaline
    } else if (temp < 15) {
      basePH -= 0.1;
    }
    
    // Regional adjustments (coastal areas)
    final lowerCity = city.toLowerCase();
    if (lowerCity.contains('mumbai') || 
        lowerCity.contains('kolkata') ||
        lowerCity.contains('chennai') ||
        lowerCity.contains('goa') ||
        lowerCity.contains('visakhapatnam')) {
      basePH -= 0.2; // Coastal areas tend to be slightly acidic
    }
    
    // Keep pH in realistic agricultural range (5.5 - 8.5)
    return double.parse(basePH.clamp(5.5, 8.5).toStringAsFixed(1));
  }
  
  // Set default weather when API fails
  void _setDefaultWeather() {
    _temperature = 25.0;
    _weatherCondition = 'Sunny';
    _humidity = 65.0;
    _windSpeed = 12.0;
    _rainfall = 0.0;
    _phValue = 7.0;
  }
}