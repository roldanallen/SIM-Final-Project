import 'package:flutter/material.dart';
import 'package:software_development/screens/home/home_screen.dart';
import 'package:software_development/screens/home/tools_screen.dart';
import 'package:software_development/screens/home/profile_screen.dart';
import 'package:software_development/screens/home/activity_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  MainNavigationScreen({Key? key}) : super(key: _globalKey);
  static final _globalKey = GlobalKey<_MainNavigationScreenState>();

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();

  /// Call this from anywhere to switch to Profile tab
  static void goToProfileTab() {
    _globalKey.currentState?._goToProfile();
  }
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Store pages in a list
  final List<Widget> _pages = [
    const HomeScreen(key: ValueKey('home')),
    const ToolsScreen(key: ValueKey('tools')),
    const ActivityPage(key: ValueKey('activity')),
    const ActivityPage(key: ValueKey('browse')),
    const ProfileScreen(key: ValueKey('profile')),
  ];

  void _goToProfile() {
    setState(() {
      _currentIndex = 3;  // index of Profile screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildPageTransition(_currentIndex), // Apply animation to page transitions
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          setState(() {
            _currentIndex = i;
          });
        },
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.stacked_line_chart), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.interests), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Custom method to add page slide animation
  Widget _buildPageTransition(int index) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _pages[index],  // Return the page widget based on index
      transitionBuilder: (child, animation) {
        const begin = Offset(1.0, 0.0);  // Slide in from right
        const end = Offset.zero;  // End at original position
        const curve = Curves.easeInOut;

        // If we're navigating forward, the direction is right-to-left.
        // If we're navigating backward, the direction is left-to-right.
        final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        final offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    );
  }
}
