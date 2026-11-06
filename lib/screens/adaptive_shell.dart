// lib/screens/adaptive_shell.dart
import 'package:flutter/material.dart';
import '../data/user_constants.dart';
import 'home_screen.dart';
import 'log_screen.dart';
import 'recipes_screen.dart';
import 'profile_screen.dart';

class AdaptiveShell extends StatefulWidget {
  const AdaptiveShell({super.key});

  @override
  State<AdaptiveShell> createState() => _AdaptiveShellState();
}

class _AdaptiveShellState extends State<AdaptiveShell> {
  int currentIndex = 0;

  // Callback untuk pindah tab dari Home ke Log
  void _navigateToHistory() {
    setState(() => currentIndex = 1); // 1 adalah index untuk Log
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(onNavigateToHistory: _navigateToHistory), // Kirim callback
      const LogScreen(),
      const RecipesScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('NutriTrack'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 840) {
            return _buildCompactLayout(pages);
          }
          return _buildExpandedLayout(pages);
        },
      ),
    );
  }

  Widget _buildCompactLayout(List<Widget> pages) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: 'Log'),
          NavigationDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: 'Recipes'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildExpandedLayout(List<Widget> pages) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: currentIndex,
          onDestinationSelected: (i) => setState(() => currentIndex = i),
          labelType: NavigationRailLabelType.all,
          leading: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CircleAvatar(
              backgroundColor: Color(0xFF00BFA5),
              child: Icon(Icons.eco, color: Colors.white),
            ),
          ),
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('Home')),
            NavigationRailDestination(icon: Icon(Icons.list_alt_outlined), selectedIcon: Icon(Icons.list_alt), label: Text('Log')),
            NavigationRailDestination(icon: Icon(Icons.restaurant_outlined), selectedIcon: Icon(Icons.restaurant), label: Text('Recipes')),
            NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('Profile')),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: pages[currentIndex]),
      ],
    );
  }
}