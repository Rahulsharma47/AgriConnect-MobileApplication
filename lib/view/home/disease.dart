// ignore_for_file: deprecated_member_use

import 'package:agrconnect/view/home/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CropSelectorScreen extends StatefulWidget {
  const CropSelectorScreen({super.key});

  @override
  State<CropSelectorScreen> createState() => _CropSelectorScreenState();
}

class _CropSelectorScreenState extends State<CropSelectorScreen> {
  String? selectedCrop;

  final List<String> crops = ['Tomato', 'Cashew', 'Ghana', 'Grape', 'Rice'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        title: Text(
          'Diseases',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Your Crop',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Choose the crop you want to diagnose',
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.2,
                ),
                itemCount: crops.length,
                itemBuilder: (context, index) {
                  final crop = crops[index];
                  final isSelected = selectedCrop == crop;
                  return GestureDetector(
                    onTap: () => setState(() => selectedCrop = crop),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.colorScheme.primary.withOpacity(0.2)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withOpacity(0.2),
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _getCropIcon(
                            crop,
                            size: 40,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            crop,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                          if (isSelected)
                            Container(
                              margin: const EdgeInsets.only(top: 5),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Selected',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedCrop != null
                    ? () {
                        // Navigate to CameraScreen with the selected crop
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraScreen(
                              cropName: selectedCrop!,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  disabledBackgroundColor: theme.colorScheme.onSurface.withOpacity(0.12),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      selectedCrop != null ? Icons.camera_alt : Icons.select_all,
                      color: selectedCrop != null 
                          ? Colors.white 
                          : theme.colorScheme.onSurface.withOpacity(0.38),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      selectedCrop != null
                          ? 'Open Camera'
                          : 'Select a Crop First',
                      style: TextStyle(
                        color: selectedCrop != null
                            ? Colors.white
                            : theme.colorScheme.onSurface.withOpacity(0.38),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getCropIcon(String crop, {double size = 40, Color? color}) {
    switch (crop) {
      case 'Tomato':
        return SvgPicture.asset(
          'assets/SVG/tomato.svg',
          width: size,
          height: size,
          colorFilter: color != null
              ? ColorFilter.mode(color, BlendMode.srcIn)
              : null,
        );
      case 'Cashew':
        return SvgPicture.asset(
          'assets/SVG/cashew.svg',
          width: size,
          height: size,
          colorFilter: color != null
              ? ColorFilter.mode(color, BlendMode.srcIn)
              : null,
        );
      case 'Grape':
        return SvgPicture.asset(
          'assets/SVG/grape.svg',
          width: size,
          height: size,
          colorFilter: color != null
              ? ColorFilter.mode(color, BlendMode.srcIn)
              : null,
        );
      case 'Rice':
        return SvgPicture.asset(
          'assets/SVG/corn.svg',
          width: size,
          height: size,
          colorFilter: color != null
              ? ColorFilter.mode(color, BlendMode.srcIn)
              : null,
        );
      case 'Ghana': // no SVG, use Material icon
        return Icon(
          Icons.grass,
          size: size,
          color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        );
      default: // fallback
        return Icon(
          Icons.agriculture,
          size: size,
          color: color ?? Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        );
    }
  }
}