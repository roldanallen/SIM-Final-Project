import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:software_development/screens/main_navigation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Future<void> _markWelcomeSeen() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await prefs.setBool('hasSeenWelcome_$userId', true);
    }
  }

  final List<Map<String, String>> _pages = [
    {
      'title': 'Welcome to Bracelyte',
      'description': 'Take control of your health and management with our intuitive app.',
      'image': 'assets/images/handshake.png',
    },
    {
      'title': 'Manage Your Tasks',
      'description': 'Stay organized with easy access to your to-dos, projects, and deadlines.',
      'image': 'assets/images/managetask.png',
    },
    {
      'title': 'Stay on Track',
      'description': 'Get regular updates and notifications to keep your health and tasks in check.',
      'image': 'assets/images/staytrack.png',
    },
    {
      'title': 'Take your first step',
      'description': 'Take control of your health and management with our intuitive app.',
      'image': 'assets/images/stayupdated.png',
    },
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _markWelcomeSeen().then((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigationScreen()),
        );
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final scaleFactor = screenWidth < 360 ? 0.9 : 1.0;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFFFFFFFF),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _pages.length,
              itemBuilder: (context, index) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      _pages[index]['image']!,
                      height: screenHeight * 0.35 * scaleFactor,
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: screenHeight * 0.15 * scaleFactor),
                    Text(
                      _pages[index]['title']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: screenWidth * 0.06 * scaleFactor,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02 * scaleFactor),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05 * scaleFactor),
                      child: Text(
                        _pages[index]['description']!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04 * scaleFactor,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            Positioned(
              bottom: screenHeight * 0.1 * scaleFactor,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                      (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentPage == index ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.03 * scaleFactor,
              left: screenWidth * 0.05 * scaleFactor,
              child: TextButton(
                onPressed: () {
                  _markWelcomeSeen().then((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => MainNavigationScreen()),
                    );
                  });
                },
                child: Text(
                  'SKIP',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04 * scaleFactor,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: screenHeight * 0.03 * scaleFactor,
              right: screenWidth * 0.05 * scaleFactor,
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08 * scaleFactor,
                    vertical: screenHeight * 0.015 * scaleFactor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  _currentPage == _pages.length - 1 ? 'GET STARTED' : 'NEXT',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04 * scaleFactor,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}