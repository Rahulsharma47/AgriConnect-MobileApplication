// import 'package:flutter/material.dart';

// class FertilizerScreen extends StatefulWidget {
//   const FertilizerScreen({super.key});

//   @override
//   State<FertilizerScreen> createState() => _FertilizerScreenState();
// }

// class _FertilizerScreenState extends State<FertilizerScreen> {
//   String selectedCrop = 'Tomato';
//   String soilType = 'Loamy';
//   double landArea = 1.0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Fertilizer Recommendations'),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildInputSection(),
//             const SizedBox(height: 30),
//             _buildRecommendationCard(),
//             const SizedBox(height: 30),
//             _buildNutrientChart(),
//             const SizedBox(height: 30),
//             _buildApplicationSchedule(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildInputSection() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.2),
//             blurRadius: 10,
//             offset: const Offset(0, 5),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Crop & Soil Information',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Color(0xFF2E7D32),
//             ),
//           ),
//           const SizedBox(height: 20),
//           DropdownButtonFormField<String>(
//             value: selectedCrop,
//             decoration: const InputDecoration(
//               labelText: 'Select Crop',
//               border: OutlineInputBorder(),
//             ),
//             items: ['Tomato', 'Wheat', 'Rice', 'Maize', 'Potato']
//                 .map((crop) => DropdownMenuItem(value: crop, child: Text(crop)))
//                 .toList(),
//             onChanged: (value) => setState(() => selectedCrop = value!),
//           ),
//           const SizedBox(height: 15),
//           DropdownButtonFormField<String>(
//             value: soilType,
//             decoration: const InputDecoration(
//               labelText: 'Soil Type',
//               border: OutlineInputBorder(),
//             ),
//             items: ['Loamy', 'Clay', 'Sandy', 'Silt']
//                 .map((soil) => DropdownMenuItem(value: soil, child: Text(soil)))
//                 .toList(),
//             onChanged: (value) => setState(() => soilType = value!),
//           ),
//           const SizedBox(height: 15),
//           TextFormField(
//             initialValue: landArea.toString(),
//             decoration: const InputDecoration(
//               labelText: 'Land Area (acres)',
//               border: OutlineInputBorder(),
//               suffixText: 'acres',
//             ),
//             keyboardType: TextInputType.number,
//             onChanged: (value) => landArea = double.tryParse(value) ?? 1.0,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecommendationCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
//         ),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Recommended Fertilizer',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 15),
//           Text(
//             'NPK 10-10-10',
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               color: Colors.white,
//             ),
//           ),
//           const SizedBox(height: 10),
//           Text(
//             'Quantity: ${(landArea * 50).toInt()} kg',
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.white,
//             ),
//           ),
//           Text(
//             'Application: Split into 3 doses',
//             style: const TextStyle(
//               fontSize: 16,
//               color: Colors.white,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNutrientChart() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Nutrient Requirements',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2E7D32),
//           ),
//         ),
//         const SizedBox(height: 15),
//         _buildNutrientBar('Nitrogen (N)', 0.4, const Color(0xFF4CAF50)),
//         _buildNutrientBar('Phosphorus (P)', 0.3, const Color(0xFF2196F3)),
//         _buildNutrientBar('Potassium (K)', 0.5, const Color(0xFFFF9800)),
//       ],
//     );
//   }

//   Widget _buildNutrientBar(String nutrient, double percentage, Color color) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(nutrient),
//               Text('${(percentage * 100).toInt()}%'),
//             ],
//           ),
//           const SizedBox(height: 5),
//           LinearProgressIndicator(
//             value: percentage,
//             backgroundColor: Colors.grey[300],
//             valueColor: AlwaysStoppedAnimation<Color>(color),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildApplicationSchedule() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Application Schedule',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Color(0xFF2E7D32),
//           ),
//         ),
//         const SizedBox(height: 15),
//         _buildScheduleItem('1st Application', 'At planting', '40% of total'),
//         _buildScheduleItem('2nd Application', 'After 30 days', '30% of total'),
//         _buildScheduleItem('3rd Application', 'At flowering', '30% of total'),
//       ],
//     );
//   }

//   Widget _buildScheduleItem(String title, String timing, String quantity) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 10,
//             height: 10,
//             decoration: const BoxDecoration(
//               color: Color(0xFF4CAF50),
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 Text(
//                   '$timing - $quantity',
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }