// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/user_constants.dart';
import '../providers/health_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/user_avatar.dart';
import 'recipe_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isTabletOrDesktop = screenWidth >= 720;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: isTabletOrDesktop ? 24 : 18,
        vertical: 16,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: Column(
            children: [
              if (isTabletOrDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left: Profile Card
                    Expanded(
                      flex: 5,
                      child: _buildProfileCard(context),
                    ),
                    const SizedBox(width: 16),
                    // Right: Stats & BMI
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _buildStatsSummary(context, health),
                          const SizedBox(height: 16),
                          _buildBmiLauncherCard(context),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                // 1. Profile Hero Card with Photo Support
                _buildProfileCard(context),
                const SizedBox(height: 18),

                // 2. Health Stats Counter
                _buildStatsSummary(context, health),
                const SizedBox(height: 18),

                // 3. BMI Calculator Card
                _buildBmiLauncherCard(context),
              ],
              const SizedBox(height: 24),

              // 4. Favorite Recipes Section Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Favorite Recipes',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${health.favoriteCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 5. Favorites List
              _buildFavoritesList(context, health),
              const SizedBox(height: 24),

              // 6. About App Card
              _buildAppInfoCard(context, health),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Avatar with circular gradient border
          const UserAvatar(
            radius: 46,
          ),
          const SizedBox(height: 16),

          // User Name
          Text(
            userName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Badges: ID & Class
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.badge_outlined, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 4),
                    Text(
                      'ID: $userId',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.school_outlined, size: 14, color: AppColors.primaryDark),
                    const SizedBox(width: 4),
                    Text(
                      userInfo,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Wellness Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: const Text(
              '🌱 Health Enthusiast',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF166534),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSummary(BuildContext context, HealthProvider health) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: '${health.uniqueDaysTracked} ${health.uniqueDaysTracked == 1 ? "Day" : "Days"}',
            subtitle: '${health.logs.length} ${health.logs.length == 1 ? "Log" : "Logs"}',
            icon: Icons.calendar_month_rounded,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            title: '${health.favoriteCount}',
            subtitle: 'Favorites',
            icon: Icons.favorite_rounded,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            title: '${health.dailyAverageWater} ml',
            subtitle: 'Daily Avg',
            icon: Icons.water_drop_rounded,
            color: const Color(0xFF0288D1),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildBmiLauncherCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE0F2F1), Color(0xFFE8F5E9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF80CBC4).withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showBmiDialog(context),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.calculate_rounded,
                    color: AppColors.primaryDark,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Ideal BMI Calculator',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Calculate body mass index & view healthy ranges',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFavoritesList(BuildContext context, HealthProvider health) {
    if (health.isLoadingFavorites) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (health.favorites.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Column(
          children: [
            Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.textLight),
            SizedBox(height: 10),
            Text(
              'No favorite recipes yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tap the heart icon on any recipe to save it here.',
              style: TextStyle(fontSize: 12, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      children: health.favorites.map((fav) {
        final mealId = fav['meal_id'] ?? '';
        final mealName = fav['meal_name'] ?? 'Recipe';
        final mealThumb = fav['meal_thumb'];

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(
                      mealId: mealId,
                      initialImage: mealThumb ?? '',
                      initialTitle: mealName,
                    ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: mealThumb != null
                          ? Image.network(
                              mealThumb,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 60,
                                height: 60,
                                color: const Color(0xFFF1F5F9),
                                child: const Icon(Icons.restaurant, color: AppColors.textLight),
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: const Color(0xFFF1F5F9),
                              child: const Icon(Icons.restaurant, color: AppColors.textLight),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mealName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Row(
                            children: [
                              Icon(Icons.check_circle_rounded, size: 12, color: AppColors.primary),
                              SizedBox(width: 4),
                              Text(
                                'Saved to Favorites',
                                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                      tooltip: 'Remove',
                      onPressed: () => _confirmRemoveFavorite(context, mealId, mealName),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAppInfoCard(BuildContext context, HealthProvider health) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppLogo(
                size: 26,
                borderRadius: 8,
                padding: EdgeInsets.all(3),
                showShadow: false,
                borderColor: AppColors.cardBorder,
              ),
              SizedBox(width: 8),
              Text(
                'NutriTrack v1.0.0',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Information Technology Education • PTI Undiksha',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: () => _exportHealthSummary(context, health),
            icon: const Icon(Icons.copy_all_rounded, size: 16),
            label: const Text('Export Health Summary'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ),
    );
  }

  void _exportHealthSummary(BuildContext context, HealthProvider health) {
    final totalWater = health.totalWaterAllTime;
    final avgWater = health.dailyAverageWater;
    final uniqueDays = health.uniqueDaysTracked;
    final latestWeight = health.latestWeight;
    final weightStr = latestWeight != null ? '$latestWeight kg' : 'Not recorded';

    final text = '''
🌿 NutriTrack - Personal Health Summary
👤 User: $userName (ID: $userId | Class: $userInfo)
📅 Tracked Days: $uniqueDays ${uniqueDays == 1 ? "day" : "days"} (${health.logs.length} logs)
💧 Daily Average Water: $avgWater ml/day (Total: $totalWater ml | Goal: 2,000 ml)
⚖️ Latest Weight: $weightStr
❤️ Favorite Recipes: ${health.favoriteCount}
🌱 Lifestyle: Health Enthusiast
Generated via NutriTrack 💚
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Health summary copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _confirmRemoveFavorite(BuildContext context, String mealId, String mealName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Favorite?'),
        content: Text('Remove "$mealName" from your favorite recipes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<HealthProvider>().removeFavorite(mealId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Recipe removed from favorites' : 'Failed to remove recipe'),
          backgroundColor: success ? AppColors.primary : Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showBmiDialog(BuildContext context) {
    final heightCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    double? bmi;
    String status = '';
    String suggestion = '';
    Color statusColor = AppColors.primary;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.calculate_rounded, color: AppColors.primary),
              SizedBox(width: 10),
              Text('BMI Calculator', style: TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Enter your height and weight to calculate your Body Mass Index (BMI):',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: heightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Height (cm)',
                    hintText: 'e.g. 165',
                    prefixIcon: Icon(Icons.height_rounded, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: weightCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Weight (kg)',
                    hintText: 'e.g. 55',
                    prefixIcon: Icon(Icons.scale_rounded, color: AppColors.coral),
                  ),
                ),
                if (bmi != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Your BMI Score:',
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          bmi!.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Visual BMI Meter Bar
                        Row(
                          children: [
                            Expanded(child: _buildBarSegment(color: const Color(0xFF0288D1), label: '<18.5')),
                            const SizedBox(width: 3),
                            Expanded(child: _buildBarSegment(color: const Color(0xFF10B981), label: '18.5-24.9')),
                            const SizedBox(width: 3),
                            Expanded(child: _buildBarSegment(color: const Color(0xFFFFA000), label: '25-29.9')),
                            const SizedBox(width: 3),
                            Expanded(child: _buildBarSegment(color: Colors.redAccent, label: '≥30')),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Text(
                          suggestion,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: statusColor.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                final h = double.tryParse(heightCtrl.text) ?? 0;
                final w = double.tryParse(weightCtrl.text) ?? 0;
                if (h > 0 && w > 0) {
                  final calculated = w / ((h / 100) * (h / 100));
                  String newStatus;
                  String newSuggestion;
                  Color newColor;
                  if (calculated < 18.5) {
                    newStatus = 'Underweight';
                    newSuggestion = 'Focus on balanced caloric intake and nutrient-rich meals.';
                    newColor = const Color(0xFF0288D1);
                  } else if (calculated < 25) {
                    newStatus = 'Normal / Ideal ✨';
                    newSuggestion = 'Great job! Your body weight is in a healthy, optimal range.';
                    newColor = const Color(0xFF10B981);
                  } else if (calculated < 30) {
                    newStatus = 'Overweight';
                    newSuggestion = 'Consider regular physical exercise and monitor daily caloric balance.';
                    newColor = const Color(0xFFFFA000);
                  } else {
                    newStatus = 'Obese';
                    newSuggestion = 'Consult with a health professional or dietitian for guided wellness.';
                    newColor = Colors.redAccent;
                  }
                  setState(() {
                    bmi = calculated;
                    status = newStatus;
                    suggestion = newSuggestion;
                    statusColor = newColor;
                  });
                }
              },
              child: const Text('Calculate BMI'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildBarSegment({required Color color, required String label}) {
    return Column(
      children: [
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 8.5, color: AppColors.textMuted, fontWeight: FontWeight.w600),
          maxLines: 1,
        ),
      ],
    );
  }
}
