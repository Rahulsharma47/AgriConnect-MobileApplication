// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../providers/app_provider.dart';
import '../../providers/theme_provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _hasInitialized = false;
  bool _isLoadingResponse = false;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addWelcomeMessage();
    });
  }

  void _addWelcomeMessage() {
    if (!_hasInitialized) {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      if (provider.chatMessages.isEmpty) {
        provider.addChatMessage(
          "🌱 Namaste! Welcome to AgriConnect AI Assistant! I'm here to help you with all your farming questions - from crop diseases and pest control to fertilizers and weather advice. How can I assist you today?",
        );
      }
      _hasInitialized = true;
    }
  }

  // API Integration Method
  Future<String> _getApiResponse(String query) async {
    const String apiUrl = 'https://ml.agri-connect.in/chat';
    
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'query': query,
          'language': 'en',
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        
        if (data['status'] == 'success' && data['response'] != null) {
          return data['response'];
        } else {
          return _getFallbackResponse(query);
        }
      } else {
        debugPrint('API Error: ${response.statusCode}');
        return _getFallbackResponse(query);
      }
    } catch (e) {
      debugPrint('API Exception: $e');
      return _getFallbackResponse(query);
    }
  }

  // Fallback response when API fails
  String _getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('hello') || message.contains('hi') || message.contains('namaste')) {
      return 'Hello there! 🌾 I\'m excited to help you with your farming journey. What agricultural topic would you like to explore today?';
    } else if (message.contains('disease') || message.contains('pest') || message.contains('infection')) {
      return '🦠 Plant diseases can be challenging! Common issues include leaf blight, powdery mildew, and root rot. Prevention through proper spacing, good air circulation, and regular inspection is key. Could you describe what symptoms you\'re seeing on your plants?';
    } else if (message.contains('fertilizer') || message.contains('nutrient') || message.contains('npk')) {
      return '🌱 Nutrition is crucial for healthy crops! NPK ratios vary by crop type - leafy vegetables need more nitrogen, while fruiting plants benefit from higher phosphorus and potassium. A soil test can give you precise recommendations. What crops are you growing?';
    } else if (message.contains('weather') || message.contains('rain') || message.contains('irrigation')) {
      return '🌦️ Weather management is essential for successful farming! Monitor forecasts for irrigation planning and disease prevention. Too much moisture can promote fungal issues, while drought stress weakens plants. Are you dealing with any specific weather challenges?';
    } else if (message.contains('crop') || message.contains('plant') || message.contains('grow') || message.contains('seed')) {
      return '🌿 Crop selection depends on your climate, soil type, water availability, and market demand. Consider seasonal variations and local growing conditions. What type of crops are you interested in cultivating?';
    } else if (message.contains('soil') || message.contains('ph') || message.contains('compost')) {
      return '🏞️ Healthy soil is the foundation of good farming! Soil pH, organic matter, and drainage all affect plant growth. Regular soil testing and adding compost can improve soil health significantly. What soil concerns do you have?';
    } else if (message.contains('organic') || message.contains('natural') || message.contains('pesticide')) {
      return '🌿 Organic farming focuses on natural methods! Companion planting, beneficial insects, neem oil, and compost can help manage pests and diseases naturally. Are you looking to transition to organic methods?';
    } else if (message.contains('thank') || message.contains('thanks')) {
      return '🙏 You\'re very welcome! I\'m here whenever you need agricultural advice. Happy farming, and feel free to ask me anything else!';
    } else {
      return '🤖 I\'m here to help with all your agricultural questions! You can ask me about crop diseases, fertilizers, pest control, weather effects, soil management, organic farming, planting schedules, and much more. What would you like to know?';
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (status) => debugPrint('STATUS: $status'),
        onError: (error) => debugPrint('ERROR: $error'),
      );

      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        
        return Scaffold(
          appBar: AppBar(
            backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            title: const Row(
              children: [
                SizedBox(width: 8),
                Text(
                  'AI Assistant',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            centerTitle: false,
            elevation: 0,
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        const Color(0xFF1E1E1E),
                        const Color(0xFF121212),
                        const Color(0xFF000000),
                      ]
                    : [
                        const Color(0xFF4CAF50),
                        const Color(0xFFF8FAF9),
                        Colors.white,
                      ],
                stops: const [0.0, 0.1, 1.0],
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: Consumer<AppProvider>(
                    builder: (context, provider, child) {
                      return Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.black.withOpacity(0.2)
                              : Colors.white.withOpacity(0.1),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(30),
                            topRight: Radius.circular(30),
                          ),
                        ),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                          itemCount: provider.chatMessages.length + (_isLoadingResponse ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == provider.chatMessages.length) {
                              return _buildTypingIndicator(isDark);
                            }
                            final isUser = index % 2 != 0;
                            return _buildChatBubble(
                              provider.chatMessages[index],
                              isUser,
                              isDark,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                _buildMessageInput(isDark),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: 32,
            height: 32,
            margin: const EdgeInsets.only(right: 8, bottom: 4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.smart_toy,
              color: Colors.white,
              size: 18,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(20),
              ),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(isDark, 0),
                const SizedBox(width: 4),
                _buildTypingDot(isDark, 1),
                const SizedBox(width: 4),
                _buildTypingDot(isDark, 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(bool isDark, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.grey[400]!.withOpacity(0.3 + (value * 0.7))
                : Colors.grey[600]!.withOpacity(0.3 + (value * 0.7)),
            shape: BoxShape.circle,
          ),
        );
      },
      onEnd: () {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Widget _buildChatBubble(String message, bool isUser, bool isDark) {
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 8, bottom: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4CAF50).withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 18,
              ),
            ),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              margin: EdgeInsets.only(
                left: isUser ? 40 : 0,
                right: isUser ? 0 : 40,
              ),
              decoration: BoxDecoration(
                gradient: isUser 
                  ? const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    )
                  : null,
                color: isUser 
                    ? null 
                    : isDark 
                        ? const Color(0xFF2C2C2C)
                        : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
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
              child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      message,
                      style: TextStyle(
                        color: isUser 
                            ? Colors.white 
                            : isDark 
                                ? Colors.white 
                                : const Color(0xFF2E2E2E),
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
            ),
          ),
          if (isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(left: 8, bottom: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Colors.grey[300],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.person,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                size: 18,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput(bool isDark) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: isDark 
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              enabled: !_isLoadingResponse,
              style: TextStyle(
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black,
              ),
              decoration: InputDecoration(
                hintText: 'Ask about farming, crops, diseases...',
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: _isListening 
                  ? Colors.red[50] 
                  : isDark 
                      ? Colors.grey[800]
                      : Colors.grey[50],
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              icon: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                color: _isListening 
                    ? Colors.red 
                    : isDark 
                        ? Colors.grey[400]
                        : Colors.grey[600],
              ),
              onPressed: _isLoadingResponse ? null : _startListening,
              splashRadius: 20,
            ),
          ),

          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _isLoadingResponse ? null : _sendMessage,
              icon: _isLoadingResponse
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              splashRadius: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty || _isLoadingResponse) return;
    
    final provider = Provider.of<AppProvider>(context, listen: false);
    
    // Add user message
    provider.addChatMessage(message);
    _controller.clear();
    _scrollToBottom();
    
    // Show loading indicator
    setState(() {
      _isLoadingResponse = true;
    });
    _scrollToBottom();
    
    // Get API response
    final botResponse = await _getApiResponse(message);
    
    // Hide loading indicator and add bot response
    setState(() {
      _isLoadingResponse = false;
    });
    
    provider.addChatMessage(botResponse);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}