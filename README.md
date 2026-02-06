# 🌾 AgriConnect - Smart Agriculture Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue)](https://github.com/Rahulsharma47/AgriConnect-MobileApplication)

A comprehensive Flutter-based mobile application designed to empower farmers with AI-driven insights, real-time weather data, crop recommendations, and disease detection capabilities.

## ✨ Features

### 🌡️ **Real-time Weather Monitoring**
- Live weather data integration using OpenWeatherMap API
- Temperature, humidity, wind speed, and rainfall tracking
- Location-based weather updates
- Estimated soil pH calculations based on environmental factors

### 🌱 **Crop Recommendations**
- AI-powered crop suggestions based on soil and weather conditions
- Input parameters: N, P, K values, temperature, humidity, pH, and rainfall
- Machine learning model integration for accurate predictions

### 🦠 **Plant Disease Detection**
- Camera-based disease identification
- AI-powered image classification
- Real-time disease diagnosis with confidence scores
- Treatment recommendations for detected diseases

### 💬 **Agricultural Chatbot**
- Interactive AI assistant for farming queries
- Expert advice on crops, diseases, and best practices
- Natural language processing for user-friendly interactions

### 📊 **Yield Calculator**
- Estimate crop yields based on land area and crop type
- Data-driven predictions for better planning

### 🌍 **Multi-language Support**
- Localization support for broader accessibility
- Easy language switching

### 🎨 **Modern UI/UX**
- Dark mode support
- Responsive design
- Intuitive navigation
- Custom Google Fonts integration

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.7.2 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- OpenWeatherMap API key ([Get one here](https://openweathermap.org/api))

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Rahulsharma47/AgriConnect-MobileApplication.git
   cd agrconnect
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys**
   
   Create a `.env` file in the root directory:
   ```env
   OPENWEATHER_API_KEY=your_openweathermap_api_key_here
   ```

   > ⚠️ **Important:** Never commit your `.env` file to version control. It's already included in `.gitignore`.

4. **Update the code to use environment variables**
   
   Install the `flutter_dotenv` package:
   ```bash
   flutter pub add flutter_dotenv
   ```

   Update `lib/providers/app_provider.dart`:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';
   
   static final String _apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
   ```

   Update `lib/main.dart` to load the environment:
   ```dart
   import 'package:flutter_dotenv/flutter_dotenv.dart';

   Future<void> main() async {
     await dotenv.load(fileName: ".env");
     runApp(const MyApp());
   }
   ```

5. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Supported Platforms

- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ macOS
- ✅ Windows
- ✅ Web

## 🛠️ Tech Stack

### Frontend
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **Google Fonts** - Typography

### APIs & Services
- **OpenWeatherMap API** - Real-time weather data
- **Custom ML APIs** - Crop recommendations and disease detection
  - Crop Recommendation: `https://nfc-api-l2z3.onrender.com/crop_rec`
  - Disease Classification: `https://ml.agri-connect.in/classify_plant_disease`
  - Chatbot: `https://ml.agri-connect.in/chat`

### Key Packages
- `http` - API communication
- `geolocator` - Location services
- `geocoding` - Address lookup
- `camera` - Camera integration
- `image_picker` - Image selection
- `file_picker` - File selection
- `speech_to_text` - Voice input
- `shared_preferences` - Local storage
- `pdf` - PDF generation
- `flutter_svg` - SVG rendering
- `permission_handler` - Runtime permissions

## 📂 Project Structure

```
agrconnect/
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── routes.dart               # Navigation routes
│   ├── providers/                # State management
│   │   ├── app_provider.dart     # Main app state
│   │   ├── theme_provider.dart   # Theme management
│   │   └── image_provider.dart   # Image handling
│   ├── view/                     # UI screens
│   │   ├── home/                 # Home and disease detection
│   │   ├── chatbot/              # AI chatbot interface
│   │   ├── crop_recommendations/ # Crop suggestion screen
│   │   ├── yield/                # Yield calculator
│   │   ├── fertilizers/          # Fertilizer recommendations
│   │   └── community/            # Community features
│   └── l10n/                     # Localization files
├── assets/                       # Images, icons, SVGs
├── android/                      # Android-specific code
├── ios/                          # iOS-specific code
└── pubspec.yaml                  # Dependencies
```

## 🔐 Security

This project follows security best practices:
- API keys are stored in environment variables
- Sensitive data is not committed to version control
- See `SECURITY_REVIEW.md` for detailed security analysis

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👨‍💻 Author

**Rahul Sharma**
- GitHub: [@Rahulsharma47](https://github.com/Rahulsharma47)

## 🙏 Acknowledgments

- OpenWeatherMap for weather data API
- Flutter team for the amazing framework
- All contributors and testers

## 📞 Support

For support, please open an issue in the GitHub repository or contact the maintainer.

---

<div align="center">
Made with ❤️ for farmers everywhere
</div>
