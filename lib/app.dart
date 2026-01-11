import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/search/search_screen.dart';
import 'presentation/screens/saved/saved_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';

class GitTrendApp extends StatelessWidget {
  const GitTrendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GitTrend JP',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    SavedScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.cardBorder, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_outline),
              activeIcon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}