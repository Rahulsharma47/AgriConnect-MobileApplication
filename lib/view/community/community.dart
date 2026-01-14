// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  String selectedCategory = 'All';
  
  final List<String> categories = [
    'All',
    'Crop Management',
    'Pest Control',
    'Organic Farming',
    'Modern Tech',
    'Success Stories',
  ];

  final List<VideoContent> videos = [
    VideoContent(
      title: 'Modern Drip Irrigation System Setup',
      thumbnail: 'https://via.placeholder.com/320x180/4CAF50/FFFFFF?text=Drip+Irrigation',
      channel: 'AgriTech India',
      views: '125K',
      duration: '15:30',
      uploadedAgo: '2 days ago',
      category: 'Modern Tech',
      videoUrl: 'https://youtube.com/watch?v=example1',
    ),
    VideoContent(
      title: 'Organic Pest Control Methods for Vegetables',
      thumbnail: 'https://via.placeholder.com/320x180/66BB6A/FFFFFF?text=Pest+Control',
      channel: 'Organic Farming Hub',
      views: '89K',
      duration: '12:45',
      uploadedAgo: '5 days ago',
      category: 'Pest Control',
      videoUrl: 'https://youtube.com/watch?v=example2',
    ),
    VideoContent(
      title: 'How I Earned 5 Lakhs in 6 Months - Success Story',
      thumbnail: 'https://via.placeholder.com/320x180/8BC34A/FFFFFF?text=Success+Story',
      channel: 'Farmer Connect',
      views: '250K',
      duration: '20:15',
      uploadedAgo: '1 week ago',
      category: 'Success Stories',
      videoUrl: 'https://youtube.com/watch?v=example3',
    ),
    VideoContent(
      title: 'Soil Testing at Home - Complete Guide',
      thumbnail: 'https://via.placeholder.com/320x180/689F38/FFFFFF?text=Soil+Testing',
      channel: 'Smart Farming',
      views: '67K',
      duration: '10:22',
      uploadedAgo: '3 days ago',
      category: 'Crop Management',
      videoUrl: 'https://youtube.com/watch?v=example4',
    ),
    VideoContent(
      title: 'Vermicomposting Setup Guide for Beginners',
      thumbnail: 'https://via.placeholder.com/320x180/7CB342/FFFFFF?text=Vermicomposting',
      channel: 'Organic Farming Hub',
      views: '142K',
      duration: '18:40',
      uploadedAgo: '4 days ago',
      category: 'Organic Farming',
      videoUrl: 'https://youtube.com/watch?v=example5',
    ),
    VideoContent(
      title: 'Drone Technology in Agriculture',
      thumbnail: 'https://via.placeholder.com/320x180/558B2F/FFFFFF?text=Drone+Tech',
      channel: 'AgriTech India',
      views: '95K',
      duration: '14:55',
      uploadedAgo: '1 week ago',
      category: 'Modern Tech',
      videoUrl: 'https://youtube.com/watch?v=example6',
    ),
    VideoContent(
      title: 'Natural Fertilizers from Kitchen Waste',
      thumbnail: 'https://via.placeholder.com/320x180/9CCC65/FFFFFF?text=Natural+Fertilizer',
      channel: 'Green Farming',
      views: '178K',
      duration: '11:30',
      uploadedAgo: '6 days ago',
      category: 'Organic Farming',
      videoUrl: 'https://youtube.com/watch?v=example7',
    ),
    VideoContent(
      title: 'Identifying and Treating Leaf Blight',
      thumbnail: 'https://via.placeholder.com/320x180/AED581/FFFFFF?text=Leaf+Blight',
      channel: 'Plant Doctor',
      views: '53K',
      duration: '9:15',
      uploadedAgo: '2 days ago',
      category: 'Pest Control',
      videoUrl: 'https://youtube.com/watch?v=example8',
    ),
    VideoContent(
      title: 'Crop Rotation for Maximum Yield',
      thumbnail: 'https://via.placeholder.com/320x180/C5E1A5/333333?text=Crop+Rotation',
      channel: 'Smart Farming',
      views: '112K',
      duration: '16:20',
      uploadedAgo: '1 week ago',
      category: 'Crop Management',
      videoUrl: 'https://youtube.com/watch?v=example9',
    ),
    VideoContent(
      title: 'IoT Sensors for Smart Irrigation',
      thumbnail: 'https://via.placeholder.com/320x180/4CAF50/FFFFFF?text=IoT+Irrigation',
      channel: 'AgriTech India',
      views: '78K',
      duration: '13:45',
      uploadedAgo: '3 days ago',
      category: 'Modern Tech',
      videoUrl: 'https://youtube.com/watch?v=example10',
    ),
  ];

  List<VideoContent> get filteredVideos {
    if (selectedCategory == 'All') {
      return videos;
    }
    return videos.where((video) => video.category == selectedCategory).toList();
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
              'Community',
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
          body: Column(
            children: [
              // Category Filter
              Container(
                height: 50,
                margin: const EdgeInsets.symmetric(vertical: 12),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategory == category;
                    
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedCategory = category;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                                )
                              : null,
                          color: isSelected
                              ? null
                              : isDark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.white,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.3)
                                  : Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            category,
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                      ? Colors.white
                                      : const Color(0xFF2E2E2E),
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Video Grid
              Expanded(
                child: filteredVideos.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.video_library_outlined,
                              size: 80,
                              color: isDark ? Colors.grey[700] : Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No videos in this category',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredVideos.length,
                        itemBuilder: (context, index) {
                          return _buildVideoCard(filteredVideos[index], isDark);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVideoCard(VideoContent video, bool isDark) {
    return GestureDetector(
      onTap: () {
        // TODO: Implement deep linking to YouTube
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening: ${video.title}'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    color: isDark ? Colors.grey[900] : Colors.grey[200],
                    child: Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        size: 60,
                        color: isDark ? Colors.grey[700] : Colors.grey[400],
                      ),
                    ),
                  ),
                ),
                // Duration badge
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      video.duration,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            // Video details
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    video.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF2E2E2E),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Channel and stats
                  Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              video.channel,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: isDark ? Colors.grey[300] : Colors.grey[700],
                              ),
                            ),
                            Text(
                              '${video.views} views • ${video.uploadedAgo}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? Colors.grey[500] : Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2C2C2C)
                              : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          video.category,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.grey[400] : const Color(0xFF4CAF50),
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
    );
  }
}

class VideoContent {
  final String title;
  final String thumbnail;
  final String channel;
  final String views;
  final String duration;
  final String uploadedAgo;
  final String category;
  final String videoUrl;

  VideoContent({
    required this.title,
    required this.thumbnail,
    required this.channel,
    required this.views,
    required this.duration,
    required this.uploadedAgo,
    required this.category,
    required this.videoUrl,
  });
}