import 'package:flutter/material.dart';
import 'package:software_development/screens/home/home_screen.dart';
import 'package:software_development/screens/home/tools_screen.dart';
import 'package:software_development/screens/home/profile_screen.dart';
import 'package:software_development/screens/home/web_browse.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),       // from home_screen.dart
    const ToolsScreen(),       // your To‑Do page
    //const BrowseScreen(),
    const ToolsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(               // keeps each page’s state alive
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Tools'),
          BottomNavigationBarItem(icon: Icon(Icons.web), label: 'Browse'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
