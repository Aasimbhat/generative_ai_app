// ignore_for_file: deprecated_member_use

import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

void main() {
  runApp(const MyAppWrapper());
}

// Add this new wrapper class to manage theme state
class MyAppWrapper extends StatefulWidget {
  const MyAppWrapper({super.key});

  @override
  State<MyAppWrapper> createState() => _MyAppWrapperState();
}

class _MyAppWrapperState extends State<MyAppWrapper> {
  bool isDarkMode = false;

  void toggleTheme() {
    print("Toggle theme called, current: $isDarkMode");
    setState(() {
      isDarkMode = !isDarkMode;
    });
    print("New theme state: $isDarkMode");
  }

  @override
  Widget build(BuildContext context) {
    // Don't return MyApp directly - create an instance with proper parameters
    return MyApp(isDarkMode: isDarkMode, toggleTheme: toggleTheme);
  }
}

// Update MyApp to accept parameters
class MyApp extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const MyApp({super.key, required this.isDarkMode, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nebula AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7), // Modern purple
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(), // More modern font
        scaffoldBackgroundColor: Colors.white,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C5CE7),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
        scaffoldBackgroundColor: const Color(0xFF10101D),
      ),
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, // Change here
      home: NebulaPromptScreen(toggleTheme: toggleTheme), // Pass toggleTheme
    );
  }
}

// Update NebulaPromptScreen to accept toggleTheme
class NebulaPromptScreen extends StatefulWidget {
  final VoidCallback toggleTheme;

  const NebulaPromptScreen({super.key, required this.toggleTheme});

  @override
  State<NebulaPromptScreen> createState() => _NebulaPromptScreenState();
}

class _NebulaPromptScreenState extends State<NebulaPromptScreen>
    with SingleTickerProviderStateMixin {
  final _aiService = AIService();
  final _promptController = TextEditingController();
  String _response = '';
  bool _isLoading = false;
  bool _hasResponse = false;
  late AnimationController _animationController;
  late Animation<double> _fadeInAnimation;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  Future<void> _generateContent() async {
    if (_promptController.text.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasResponse = false;
    });

    final response = await _aiService.generateContent(_promptController.text);

    setState(() {
      _response = response;
      _isLoading = false;
      _hasResponse = true;
    });

    _animationController.reset();
    _animationController.forward();

    // Scroll down after response is received
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;
    final secondaryColor = colorScheme.secondary;
    final surfaceColor = isDarkMode ? const Color(0xFF1E1E2E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Modern App Bar
            _buildAppBar(isDarkMode, textColor, primaryColor),

            // Main Content
            Expanded(
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Modernized decorative elements
                          _buildHeroSection(
                            primaryColor,
                            secondaryColor,
                            isDarkMode,
                          ),

                          const SizedBox(height: 32),

                          // Modernized input container
                          _buildInputContainer(
                            isDarkMode,
                            surfaceColor,
                            textColor,
                            primaryColor,
                          ),

                          const SizedBox(height: 40),

                          // Response area
                          if (_hasResponse)
                            _buildResponseArea(
                              isDarkMode,
                              surfaceColor,
                              textColor,
                              primaryColor,
                            ),

                          if (!_hasResponse && !_isLoading)
                            _buildSuggestionArea(
                              primaryColor,
                              isDarkMode,
                              textColor,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Loading indicator
            if (_isLoading)
              _buildLoadingIndicator(primaryColor, secondaryColor),

            // Bottom text
            Padding(
              padding: const EdgeInsets.all(16.0), // Add some padding if needed
              child: Text(
                "Made With ❤️ By Asim Bhat",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600], // Adjust color as needed
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isDarkMode, Color textColor, Color primaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color:
            isDarkMode
                ? Colors.black.withOpacity(0.2)
                : Colors.white.withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color:
                isDarkMode
                    ? Colors.black.withOpacity(0.1)
                    : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(Icons.auto_awesome, color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  "AI Buddy",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    foreground:
                        Paint()
                          ..shader = LinearGradient(
                            colors:
                                isDarkMode
                                    ? [
                                      Colors.white,
                                      Colors.purpleAccent.shade100,
                                    ]
                                    : [primaryColor, Colors.purpleAccent],
                          ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: textColor.withOpacity(0.7),
                  ),
                  onPressed: () {},
                ),
                IconButton(
                  icon: Icon(
                    isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode, // Toggle icon
                    color: textColor.withOpacity(0.7),
                  ),
                  onPressed:
                      widget.toggleTheme, // Use the passed toggleTheme function
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroSection(
    Color primaryColor,
    Color secondaryColor,
    bool isDarkMode,
  ) {
    return Center(
      child: SizedBox(
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Modern glowing orb
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    primaryColor,
                    secondaryColor.withOpacity(0.7),
                    primaryColor.withOpacity(0.0),
                  ],
                  stops: const [0.1, 0.4, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),

            // Double ring effect
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(seconds: 20),
              builder: (context, value, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.rotate(
                      angle: value * 2 * 3.14,
                      child: Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: primaryColor.withOpacity(0.3),
                            width: 2,
                          ),
                          gradient: SweepGradient(
                            colors: [
                              primaryColor.withOpacity(0.1),
                              primaryColor.withOpacity(0.3),
                              primaryColor.withOpacity(0.1),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                            transform: const GradientRotation(3.14 / 4),
                          ),
                        ),
                      ),
                    ),
                    Transform.rotate(
                      angle: -value * 2 * 3.14,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: secondaryColor.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Particles effect
            for (int i = 0; i < 10; i++)
              TweenAnimationBuilder(
                tween: Tween<double>(begin: 0, end: 1),
                duration: Duration(seconds: 2 + i),
                builder: (context, value, child) {
                  final size = 4.0 + (i % 3) * 2.0;
                  final angle = (i * 36) * (3.14 / 180);
                  final radius = 80.0 + (sin(value * 2 * 3.14) * 20);

                  return Positioned(
                    left: 100 + radius * cos(angle + (value * 2 * 3.14)),
                    top: 110 + radius * sin(angle + (value * 2 * 3.14)),
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i % 2 == 0 ? primaryColor : secondaryColor,
                        boxShadow: [
                          BoxShadow(
                            color: (i % 2 == 0 ? primaryColor : secondaryColor)
                                .withOpacity(0.6),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

            // Welcome text with light effect
            Positioned(
              bottom: 0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          isDarkMode
                              ? Colors.black.withOpacity(0.3)
                              : Colors.white.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            isDarkMode
                                ? Colors.white.withOpacity(0.1)
                                : Colors.black.withOpacity(0.05),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      "What would you like to explore today?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color:
                            isDarkMode
                                ? Colors.white.withOpacity(0.9)
                                : Colors.black.withOpacity(0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputContainer(
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
    Color primaryColor,
  ) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.1),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color:
                  isDarkMode
                      ? const Color(0xFF1E1E2E).withOpacity(0.7)
                      : Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color:
                    isDarkMode
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _promptController,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: 'Ask me anything...',
                    hintStyle: TextStyle(
                      color: textColor.withOpacity(0.4),
                      fontWeight: FontWeight.w300,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 18,
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w400,
                  ),
                  onSubmitted: (_) => _generateContent(),
                ),
                Divider(
                  color:
                      isDarkMode
                          ? Colors.white.withOpacity(0.05)
                          : Colors.black.withOpacity(0.05),
                  height: 1,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildFeatureButton(
                            Icons.mic_rounded,
                            'Voice',
                            textColor.withOpacity(0.6),
                            isDarkMode,
                          ),
                          _buildFeatureButton(
                            Icons.image_rounded,
                            'Image',
                            textColor.withOpacity(0.6),
                            isDarkMode,
                          ),
                          _buildFeatureButton(
                            Icons.attach_file_rounded,
                            'File',
                            textColor.withOpacity(0.6),
                            isDarkMode,
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _generateContent,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.0,
                                    color: Colors.white,
                                  ),
                                )
                                : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Text(
                                      'Generate',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(Icons.rocket_launch_rounded, size: 18),
                                  ],
                                ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    IconData icon,
    String label,
    Color iconColor,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: label,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
      ),
    );
  }

  Widget _buildResponseArea(
    bool isDarkMode,
    Color surfaceColor,
    Color textColor,
    Color primaryColor,
  ) {
    return FadeTransition(
      opacity: _fadeInAnimation,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color:
                    isDarkMode
                        ? const Color(0xFF1E1E2E).withOpacity(0.7)
                        : Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color:
                      isDarkMode
                          ? primaryColor.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  primaryColor.withOpacity(0.7),
                                  Colors.purpleAccent.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Ai Buddy Response',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              foreground:
                                  Paint()
                                    ..shader = LinearGradient(
                                      colors: [
                                        primaryColor,
                                        Colors.purpleAccent,
                                      ],
                                    ).createShader(
                                      const Rect.fromLTWH(0, 0, 200, 70),
                                    ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          _buildActionButton(
                            Icons.thumb_up_alt_outlined,
                            'Like',
                            textColor.withOpacity(0.6),
                            isDarkMode,
                          ),
                          _buildActionButton(
                            Icons.copy_rounded,
                            'Copy',
                            textColor.withOpacity(0.6),
                            isDarkMode,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    _response,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.7,
                      color: textColor.withOpacity(0.8),
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color iconColor,
    bool isDarkMode,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Tooltip(
        message: label,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color:
                isDarkMode
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
      ),
    );
  }

  Widget _buildSuggestionArea(
    Color primaryColor,
    bool isDarkMode,
    Color textColor,
  ) {
    return Center(
      child: Row(
        children: [
          const SizedBox(height: 10),
          // Modern suggestion cards instead of chips
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 10,
            runSpacing: 10,
            children: [],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(Color primaryColor, Color secondaryColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          // Modern loading animation
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0, end: 1),
            duration: const Duration(milliseconds: 1500),
            builder: (context, value, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  final delay = index * 0.2;
                  final position = (value + delay) % 1.0;
                  final size = 4 + (sin(position * 3.14) * 6);

                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: size,
                    width: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [primaryColor, secondaryColor],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(height: 12),
          Text(
            "Generating your response...",
            style: TextStyle(
              color: primaryColor.withOpacity(0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _promptController.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

// AI Service to handle API requests
class AIService {
  final String apiKey = 'AIzaSyC5FN-im75Vbp4eGkIIK4mC4h3qZGfRE2Y';
  late GenerativeModel model;

  AIService() {
    model = GenerativeModel(model: 'gemini-1.5-pro', apiKey: apiKey);
  }

  Future<String> generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? 'No response generated';
    } catch (e) {
      return 'Error generating content: $e';
    }
  }
}
