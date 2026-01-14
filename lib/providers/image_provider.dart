import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageProvider extends ChangeNotifier {
  final ImagePicker _picker = ImagePicker();
  
  // Current selected image
  File? _selectedImage;
  File? get selectedImage => _selectedImage;
  
  // Loading state for image operations
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  // Error state
  String? _error;
  String? get error => _error;
  
  // Image analysis result (for future ML integration)
  Map<String, dynamic>? _analysisResult;
  Map<String, dynamic>? get analysisResult => _analysisResult;

  /// Pick image from gallery
  Future<bool> pickFromGallery({
    double maxWidth = 1000,
    double maxHeight = 1000,
    int imageQuality = 80,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _clearAnalysisResult(); // Clear previous analysis
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error selecting image: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Capture image from camera
  Future<bool> captureFromCamera({
    double maxWidth = 1000,
    double maxHeight = 1000,
    int imageQuality = 80,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (image != null) {
        _selectedImage = File(image.path);
        _clearAnalysisResult(); // Clear previous analysis
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error capturing photo: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Set image directly (useful for testing or other sources)
  void setImage(File image) {
    _selectedImage = image;
    _clearAnalysisResult();
    _clearError();
    notifyListeners();
  }

  /// Set selected image (alias for setImage for compatibility)
  void setSelectedImage(File image) {
    setImage(image);
  }

  /// Clear selected image
  void clearImage() {
    _selectedImage = null;
    _clearAnalysisResult();
    _clearError();
    notifyListeners();
  }

  /// Check if image is selected
  bool get hasImage => _selectedImage != null;

  /// Get image file name
  String? get imageName {
    if (_selectedImage == null) return null;
    return _selectedImage!.path.split('/').last;
  }

  /// Get image size in bytes
  Future<int?> getImageSize() async {
    if (_selectedImage == null) return null;
    try {
      return await _selectedImage!.length();
    } catch (e) {
      return null;
    }
  }

  /// Simulate disease analysis (replace with actual ML model)
  Future<void> analyzeCropDisease() async {
    if (_selectedImage == null) {
      _setError('No image selected for analysis');
      return;
    }

    try {
      _setLoading(true);
      _clearError();
      
      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock analysis result - replace with actual ML model call
      _analysisResult = {
        'diseaseDetected': true,
        'diseaseName': 'Leaf Blight',
        'confidence': 0.85,
        'severity': 'Moderate',
        'recommendations': [
          'Apply copper-based fungicide',
          'Improve air circulation',
          'Remove affected leaves',
          'Water at soil level to avoid wetting leaves'
        ],
        'treatmentPriority': 'High',
        'analysisDate': DateTime.now().toIso8601String(),
      };
      
      notifyListeners();
    } catch (e) {
      _setError('Error analyzing image: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Pick image with choice dialog (camera or gallery)
  Future<bool> pickImageWithChoice(BuildContext context) async {
    final choice = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Select Image Source',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
        ),
        content: const Text('Choose how you want to select the image'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt, color: Color(0xFF4CAF50)),
            label: const Text('Camera', style: TextStyle(color: Color(0xFF4CAF50))),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library, color: Color(0xFF4CAF50)),
            label: const Text('Gallery', style: TextStyle(color: Color(0xFF4CAF50))),
          ),
        ],
      ),
    );

    if (choice != null) {
      if (choice == ImageSource.camera) {
        return await captureFromCamera();
      } else {
        return await pickFromGallery();
      }
    }
    return false;
  }

  /// Multiple image selection (for future features)
  List<File> _multipleImages = [];
  List<File> get multipleImages => List.unmodifiable(_multipleImages);

  Future<bool> pickMultipleImages({int limit = 5}) async {
    try {
      _setLoading(true);
      _clearError();
      
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (images.isNotEmpty) {
        // Limit the number of images
        final limitedImages = images.take(limit).toList();
        _multipleImages = limitedImages.map((xFile) => File(xFile.path)).toList();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError('Error selecting multiple images: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearMultipleImages() {
    _multipleImages.clear();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void _clearAnalysisResult() {
    _analysisResult = null;
  }
  
  // Add this method to the ImageProvider class
  void setLoading(bool loading) {
    _setLoading(loading);
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}