import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
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

  void _navigateToHistory() {
    setState(() => currentIndex = 1);
  }

  void _navigateToRecipes() {
    setState(() => currentIndex = 2);
  }

  void _navigateToProfile() {
    setState(() => currentIndex = 3);
  }

  final List<({String title, String subtitle})> _tabHeaders = const [
    (title: 'NutriTrack', subtitle: 'Daily Wellness & Nutrition Tracker'),
    (title: 'Health Logs', subtitle: 'Track Daily Water & Weight Progress'),
    (title: 'Healthy Recipes', subtitle: 'Explore Delicious & Nutritious Meals'),
    (title: 'My Profile', subtitle: 'Account Info & Wellness Summary'),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onNavigateToHistory: _navigateToHistory,
        onNavigateToRecipes: _navigateToRecipes,
        onNavigateToProfile: _navigateToProfile,
      ),
      const LogScreen(),
      const RecipesScreen(),
      const ProfileScreen(),
    ];

    final isCompact = MediaQuery.of(context).size.width < 840;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const AppLogo(size: 44, borderRadius: 14),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _tabHeaders[currentIndex].title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tabHeaders[currentIndex].subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: isCompact ? pages[currentIndex] : _buildExpandedLayout(pages),
      bottomNavigationBar: isCompact ? _buildBottomNavBar() : null,
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => setState(() => currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long_rounded),
            label: 'History',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant_rounded),
            label: 'Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
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
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primaryLight,
          leading: const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: AppLogo(size: 42, borderRadius: 12),
          ),
          destinations: const [
            NavigationRailDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primaryDark),
              label: Text('Home'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long_rounded, color: AppColors.primaryDark),
              label: Text('History'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.restaurant_outlined),
              selectedIcon: Icon(Icons.restaurant_rounded, color: AppColors.primaryDark),
              label: Text('Recipes'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primaryDark),
              label: Text('Profile'),
            ),
          ],
        ),
        const VerticalDivider(thickness: 1, width: 1, color: AppColors.cardBorder),
        Expanded(child: pages[currentIndex]),
      ],
    );
  }
}
