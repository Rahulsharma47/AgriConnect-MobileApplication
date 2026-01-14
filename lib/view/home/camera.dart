// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../providers/image_provider.dart' as custom_image_provider;
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';


class CameraScreen extends StatefulWidget {
  final String cropName;
  
  const CameraScreen({super.key, required this.cropName});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {

  // API Integration Method for Disease Classification
  Future<Map<String, dynamic>?> _classifyPlantDisease(File imageFile, String cropType) async {
    const String apiUrl = 'https://ml.agri-connect.in/classify_plant_disease';
    
    try {
      var request = http.MultipartRequest('POST', Uri.parse(apiUrl));
      
      // Add image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
      
      // Add form fields
      request.fields['language'] = 'en';
      request.fields['crop_type'] = cropType.toLowerCase();
      
      // Send request with timeout
      var streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );
      
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          return {
            'diseaseDetected': data['diseases_detected'] ?? false,
            'diagnosis': data['diagnosis'] ?? 'No diagnosis available',
            'diseaseName': _extractDiseaseName(data['diagnosis']),
            'confidence': 0.85, // API doesn't provide this, using default
            'severity': data['diseases_detected'] ? 'Medium' : 'None',
            'recommendations': _extractRecommendations(data['diagnosis']),
            'annotatedImage': data['annotated_image'],
            'cropType': data['crop_type'] ?? cropType,
          };
        }
      }
      
      debugPrint('API Error: ${response.statusCode}');
      return null;
      
    } catch (e) {
      debugPrint('API Exception: $e');
      return null;
    }
  }

  // Helper to extract disease name from diagnosis
  String _extractDiseaseName(String diagnosis) {
    // Try to extract disease name from the diagnosis text
    if (diagnosis.toLowerCase().contains('anthracnose')) return 'Anthracnose';
    if (diagnosis.toLowerCase().contains('blight')) return 'Blight';
    if (diagnosis.toLowerCase().contains('rust')) return 'Rust';
    if (diagnosis.toLowerCase().contains('mildew')) return 'Mildew';
    if (diagnosis.toLowerCase().contains('spot')) return 'Leaf Spot';
    if (diagnosis.toLowerCase().contains('healthy')) return 'Healthy';
    
    // If no specific disease found, try to extract first sentence
    List<String> sentences = diagnosis.split('.');
    if (sentences.isNotEmpty) {
      String firstSentence = sentences[0].trim();
      if (firstSentence.length < 50) {
        return firstSentence;
      }
    }
    
    return 'Disease Detected';
  }

  // Helper to extract recommendations from diagnosis
  List<String> _extractRecommendations(String diagnosis) {
    List<String> recommendations = [];
    
    // Split by common recommendation indicators
    List<String> sentences = diagnosis.split(RegExp(r'[.!]'));
    
    for (String sentence in sentences) {
      String trimmed = sentence.trim();
      if (trimmed.isEmpty) continue;
      
      // Look for recommendation keywords
      if (trimmed.toLowerCase().contains('recommend') ||
          trimmed.toLowerCase().contains('apply') ||
          trimmed.toLowerCase().contains('use') ||
          trimmed.toLowerCase().contains('treat') ||
          trimmed.toLowerCase().contains('spray') ||
          trimmed.toLowerCase().contains('remove') ||
          trimmed.toLowerCase().contains('avoid')) {
        recommendations.add(trimmed);
      }
    }
    
    // If no specific recommendations found, split diagnosis into chunks
    if (recommendations.isEmpty) {
      List<String> allSentences = diagnosis.split(RegExp(r'[.!]'));
      for (int i = 0; i < allSentences.length && recommendations.length < 3; i++) {
        String sentence = allSentences[i].trim();
        if (sentence.isNotEmpty && sentence.length > 20) {
          recommendations.add(sentence);
        }
      }
    }
    
    // Limit to 5 recommendations
    return recommendations.take(5).toList();
  }

  Future<void> _takePicture() async {
    final imageProvider = Provider.of<custom_image_provider.ImageProvider>(context, listen: false);
    
    final success = await imageProvider.captureFromCamera();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Photo captured successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Photo capture cancelled'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    final imageProvider = Provider.of<custom_image_provider.ImageProvider>(context, listen: false);
    
    final success = await imageProvider.pickFromGallery();
    
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Image selected successfully!'),
            ],
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('No image selected'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  void _showFullScreenImage() {
    final imageProvider = Provider.of<custom_image_provider.ImageProvider>(context, listen: false);
    
    if (imageProvider.selectedImage == null) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('Full View'),
            actions: [
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Share functionality coming soon!'),
                      backgroundColor: const Color(0xFF4CAF50),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Center(
            child: InteractiveViewer(
              child: Image.file(
                imageProvider.selectedImage!,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _analyzeImage() async {
    final imageProvider = Provider.of<custom_image_provider.ImageProvider>(context, listen: false);
    
    if (imageProvider.selectedImage == null) {
      _showModernSnackBar(
        'No image selected for analysis',
        Colors.red,
        Icons.error_outline,
      );
      return;
    }

    // Show loading state
    setState(() {
      imageProvider.setLoading(true);
    });

    _showModernSnackBar(
      'Analyzing ${widget.cropName} for diseases...',
      const Color(0xFF4CAF50),
      Icons.analytics,
      isLoading: true,
      duration: 30,
    );

    // Call the real API
    final results = await _classifyPlantDisease(
      imageProvider.selectedImage!,
      widget.cropName,
    );

    setState(() {
      imageProvider.setLoading(false);
    });

    if (mounted) {
      // Dismiss the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      if (results != null) {
        _showAnalysisResults(results);
      } else {
        // API failed, show error
        _showModernSnackBar(
          'Analysis failed. Please check your internet connection and try again.',
          Colors.red,
          Icons.error_outline,
        );
      }
    }
  }

  void _showModernSnackBar(String message, Color color, IconData icon, {bool isLoading = false, int duration = 2}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            isLoading 
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Icon(icon, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: Duration(seconds: duration),
      ),
    );
  }

  void _showAnalysisResults(Map<String, dynamic> results) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 16,
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                : [Colors.white, const Color(0xFFF8FAF9)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: results['diseaseDetected'] 
                      ? [Colors.orange.shade200, Colors.orange.shade400]
                      : [const Color(0xFF4CAF50), const Color(0xFF66BB6A)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        results['diseaseDetected'] ? Icons.warning_rounded : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            results['diseaseDetected'] ? 'Disease Detected' : 'Healthy Crop',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (results['diseaseDetected'])
                            Text(
                              results['diseaseName'],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content - with proper constraints to prevent overflow
              Flexible(
                child: Container(
                  constraints: const BoxConstraints(maxHeight: 400),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (results['diseaseDetected']) ...[
                          _buildInfoCard('Crop Type', results['cropType'], Icons.eco),
                          const SizedBox(height: 12),
                          _buildInfoCard('Confidence Level', '${(results['confidence'] * 100).toInt()}%', Icons.analytics),
                          const SizedBox(height: 12),
                          _buildInfoCard('Severity', results['severity'], Icons.health_and_safety),
                          const SizedBox(height: 20),
                          
                          // Full Diagnosis
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.blue.shade900.withOpacity(0.3) : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? Colors.blue.shade700 : Colors.blue.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.description, color: Colors.blue.shade700, size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'AI Diagnosis',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue.shade700,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  results['diagnosis'],
                                  style: TextStyle(
                                    color: isDark ? Colors.blue.shade300 : Colors.blue.shade900,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Treatment Recommendations Container
                          if (results['recommendations'].isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isDark ? Colors.red.shade900.withOpacity(0.3) : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? Colors.red.shade700 : Colors.red.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.medical_services, color: Colors.red.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Treatment Recommendations',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red.shade700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  ...List.generate(
                                    results['recommendations'].length,
                                    (index) => Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 6,
                                            height: 6,
                                            margin: const EdgeInsets.only(top: 6, right: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.red.shade400,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              results['recommendations'][index],
                                              style: TextStyle(
                                                color: isDark ? Colors.red.shade300 : Colors.red.shade700,
                                                height: 1.4,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ] else ...[
                          // Healthy Crop Container
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.green.shade900.withOpacity(0.3) : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? Colors.green.shade700 : Colors.green.shade200),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.eco, color: Colors.green.shade600, size: 40),
                                const SizedBox(height: 12),
                                Text(
                                  'Your ${results['cropType']} appears to be healthy!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.green.shade400 : Colors.green.shade700,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  results['diagnosis'],
                                  style: TextStyle(
                                    color: isDark ? Colors.green.shade300 : Colors.green.shade600,
                                    height: 1.5,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              
              // Actions
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                        label: const Text('Close'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.grey[300] : Colors.grey[600],
                          side: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey[300]!),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _downloadAnalysisReport(results);
                        },
                        icon: const Icon(Icons.download),
                        label: const Text('Download PDF'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A2A2A) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey[600], size: 20),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadAnalysisReport(Map<String, dynamic> results) async {
    try {
      _showModernSnackBar(
        'Generating PDF report...',
        const Color(0xFF4CAF50),
        Icons.picture_as_pdf,
        isLoading: true,
        duration: 2,
      );

      final pdf = pw.Document();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'Plant Disease Analysis Report',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 16),

                pw.Text('Crop Type: ${results['cropType']}'),
                pw.Text('Status: ${results['diseaseDetected'] ? 'Disease Detected' : 'Healthy'}'),

                if (results['diseaseDetected']) ...[
                  pw.Text('Disease Name: ${results['diseaseName']}'),
                  pw.Text('Severity: ${results['severity']}'),
                  pw.Text('Confidence: ${(results['confidence'] * 100).toInt()}%'),
                ],

                pw.SizedBox(height: 16),

                pw.Text(
                  'Diagnosis',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(results['diagnosis']),

                pw.SizedBox(height: 16),

                if (results['recommendations'] != null &&
                    results['recommendations'].isNotEmpty) ...[
                  pw.Text(
                    'Treatment Recommendations',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 8),
                  ...results['recommendations']
                      .map<pw.Widget>((rec) => pw.Bullet(text: rec))
                      .toList(),
                ],
              ],
            );
          },
        ),
      );

      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/plant_disease_report_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final file = File(filePath);
      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        _showModernSnackBar(
          'PDF downloaded successfully!',
          const Color(0xFF4CAF50),
          Icons.check_circle,
        );

        // Optional: auto-open the file
        await OpenFile.open(file.path);
      }
    } catch (e) {
      if (mounted) {
        _showModernSnackBar(
          'Failed to generate PDF',
          Colors.red,
          Icons.error_outline,
        );
      }
    }
  }


  void _retakePhoto() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark; 
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark 
                ? [const Color(0xFF1E1E1E), const Color(0xFF2A2A2A)]
                : [Colors.white, const Color(0xFFF8FAF9)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.refresh, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      'Retake Photo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'How would you like to retake the photo?',
                      style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface,),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _takePicture();
                            },
                            icon: const Icon(Icons.camera_alt),
                            label: const Text('Camera'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _pickFromGallery();
                            },
                            icon: const Icon(Icons.photo_library),
                            label: const Text('Gallery'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4CAF50),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearImage() {
    final imageProvider = Provider.of<custom_image_provider.ImageProvider>(context, listen: false);
    imageProvider.clearImage();
    
    _showModernSnackBar(
      'Image cleared',
      Colors.grey,
      Icons.delete_outline,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark; 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        title: Text(
          '${widget.cropName} Disease Detection',
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<custom_image_provider.ImageProvider>(
        builder: (context, imageProvider, child) {
          if (imageProvider.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: theme.colorScheme.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing ${widget.cropName}...',
                    style: TextStyle(fontSize: 16, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This may take a few seconds',
                    style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Crop info banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.eco, color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Selected Crop',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              widget.cropName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Image container
                GestureDetector(
                  onTap: imageProvider.hasImage ? _showFullScreenImage : null,
                  child: Container(
                    width: double.infinity,
                    height: 300,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: imageProvider.hasImage
                        ? Stack(
                            children: [
                              Image.file(
                                imageProvider.selectedImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.zoom_in, color: Colors.white, size: 16),
                                      SizedBox(width: 4),
                                      Text(
                                        'Tap to view',
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_outlined, size: 80, color: isDark ? Colors.grey[600] : Colors.grey),
                              const SizedBox(height: 16),
                              Text(
                                'No image selected',
                                style: TextStyle(fontSize: 18, color: isDark ? Colors.grey[400] : Colors.grey, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Take a photo or select from gallery',
                                style: TextStyle(fontSize: 14, color: isDark ? Colors.grey[500] : Colors.grey,),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                if (!imageProvider.hasImage) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: imageProvider.isLoading ? null : _takePicture,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            disabledBackgroundColor: Colors.grey[400],
                            elevation: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: imageProvider.isLoading ? null : _pickFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            disabledBackgroundColor: Colors.grey[400],
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                
                if (imageProvider.hasImage) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearImage,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Clear Image'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _retakePhoto,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retake'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _analyzeImage,
                      icon: const Icon(Icons.analytics, size: 24),
                      label: const Text(
                        'Analyze for Disease',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}