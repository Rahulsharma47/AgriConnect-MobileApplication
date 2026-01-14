// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class DiseaseListScreen extends StatelessWidget {
  final String crop;
  const DiseaseListScreen({super.key, required this.crop});

  // Temporary static disease data (replace with API later)
  static final Map<String, List<Map<String, String>>> cropDiseases = {
    'Tomato': [
      {
        'name': 'Early Blight',
        'symptoms': 'Brown spots with concentric rings on leaves',
        'treatment': 'Apply copper-based fungicide, ensure good air circulation',
        'prevention': 'Crop rotation, avoid overhead watering',
      },
      {
        'name': 'Late Blight',
        'symptoms': 'Water-soaked lesions on leaves and stems',
        'treatment': 'Apply systemic fungicide immediately',
        'prevention': 'Plant resistant varieties, avoid wet conditions',
      },
    ],
    'Cashew': [
      {
        'name': 'Anthracnose',
        'symptoms': 'Dark brown spots on leaves and nuts',
        'treatment': 'Apply copper fungicide during flowering',
        'prevention': 'Proper pruning for air circulation',
      },
    ],
    'Ghana': [
      {
        'name': 'Leaf Spot',
        'symptoms': 'Circular brown spots on leaves',
        'treatment': 'Remove infected leaves, apply fungicide',
        'prevention': 'Proper drainage and air circulation',
      },
    ],
    'Grape': [
      {
        'name': 'Downy Mildew',
        'symptoms': 'Yellow spots on upper leaf surface',
        'treatment': 'Apply systemic fungicide like metalaxyl',
        'prevention': 'Proper canopy management, avoid moisture',
      },
    ],
    'Rice': [
      {
        'name': 'Blast',
        'symptoms': 'Oval lesions with gray centers on leaves',
        'treatment': 'Apply systemic fungicides like tricyclazole',
        'prevention': 'Balanced fertilization, avoid excess nitrogen',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final diseases = cropDiseases[crop] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4CAF50)),
        ),
        centerTitle: true,
        title: Text(
          '$crop Diseases',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: diseases.length,
        itemBuilder: (context, index) {
          final disease = diseases[index];
          return _buildDiseaseCard(disease);
        },
      ),
    );
  }

  Widget _buildDiseaseCard(Map<String, String> disease) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        backgroundColor: Colors.white,
        title: Text(
          disease['name']!,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2E7D32),
          ),
        ),
        leading: const Icon(
          Icons.medical_services,
          color: Color(0xFF4CAF50),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoSection('Symptoms', disease['symptoms']!, Icons.visibility),
                const SizedBox(height: 15),
                _buildInfoSection('Treatment', disease['treatment']!, Icons.healing),
                const SizedBox(height: 15),
                _buildInfoSection('Prevention', disease['prevention']!, Icons.shield),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                content,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
