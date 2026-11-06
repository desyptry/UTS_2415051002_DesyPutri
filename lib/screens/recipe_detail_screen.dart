// lib/screens/recipe_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/health_provider.dart';
import '../providers/meal_provider.dart';
import '../theme/app_colors.dart';

class RecipeDetailScreen extends StatefulWidget {
  final String mealId;
  final String initialImage;
  final String initialTitle;

  const RecipeDetailScreen({
    super.key,
    required this.mealId,
    required this.initialImage,
    required this.initialTitle,
  });

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().loadMealDetail(widget.mealId);
    });
  }

  void _copyRecipeToClipboard(dynamic meal) {
    final buffer = StringBuffer();
    buffer.writeln('🍳 Recipe: ${meal.strMeal}');
    buffer.writeln('🏷️ Category: ${meal.strCategory ?? "-"} | Origin: ${meal.strArea ?? "-"}');
    buffer.writeln('🔥 Estimate: ~${meal.estimatedCalories} kcal');
    buffer.writeln('\n📋 Ingredients:');
    meal.ingredients.forEach((key, val) {
      buffer.writeln('- $val $key');
    });
    buffer.writeln('\n👩‍🍳 Instructions:');
    buffer.writeln(meal.strInstructions ?? '-');
    if (meal.strYoutube != null && meal.strYoutube.isNotEmpty) {
      buffer.writeln('\n▶️ Video Tutorial: ${meal.strYoutube}');
    }
    buffer.writeln('\nShared via NutriTrack 🌱');

    Clipboard.setData(ClipboardData(text: buffer.toString()));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Complete recipe copied to clipboard!'),
          ],
        ),
        backgroundColor: AppColors.primaryDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final health = context.watch<HealthProvider>();

    final meal = mealProvider.selectedMeal;
    final isLoading = mealProvider.isLoadingDetail;
    final isFav = health.isFavorite(widget.mealId);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Collapsible Hero AppBar
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withValues(alpha: 0.4),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            actions: [
              if (meal != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.4),
                    child: IconButton(
                      icon: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
                      tooltip: 'Share Recipe',
                      onPressed: () => _copyRecipeToClipboard(meal),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  backgroundColor: Colors.black.withValues(alpha: 0.4),
                  child: IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? Colors.redAccent : Colors.white,
                      size: 22,
                    ),
                    onPressed: () async {
                      if (isFav) {
                        await health.removeFavorite(widget.mealId);
                      } else {
                        await health.addFavorite(
                          mealId: widget.mealId,
                          mealName: widget.initialTitle,
                          mealThumb: widget.initialImage,
                        );
                      }
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFav
                                ? 'Removed from Favorite Recipes'
                                : '❤️ Saved to Favorite Recipes!',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor:
                              isFav ? AppColors.textDark : AppColors.primary,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    meal?.strMealThumb ?? widget.initialImage,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
                    ),
                  ),
                  // Dark gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.75),
                        ],
                      ),
                    ),
                  ),
                  // Title on bottom of header
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 16,
                    child: Text(
                      meal?.strMeal ?? widget.initialTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black54,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Content Details
          SliverToBoxAdapter(
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Column(
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Loading ingredients and instructions...',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  )
                : meal == null
                    ? const Padding(
                        padding: EdgeInsets.all(40),
                        child: Center(
                          child: Text('Failed to load recipe details.'),
                        ),
                      )
                    : _buildContent(context, meal),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic meal) {
    final rawInstructions = meal.strInstructions as String? ?? '';
    final steps = rawInstructions
        .split(RegExp(r'\r\n\r\n|\n\n|\r\n|\n'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty && s.length > 5)
        .toList();

    final hasYoutube = meal.strYoutube != null && (meal.strYoutube as String).trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badges Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildBadge(
                icon: Icons.category_rounded,
                label: meal.strCategory ?? 'Healthy',
                color: AppColors.primary,
              ),
              _buildBadge(
                icon: Icons.public_rounded,
                label: meal.strArea ?? 'International',
                color: AppColors.skyBlue,
              ),
              _buildBadge(
                icon: Icons.check_circle_outline_rounded,
                label: 'Nutritious Choice',
                color: AppColors.emerald,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Nutrition & Cooking Stats Row (Dynamic Calories, Prep & Cook Times)
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  icon: Icons.local_fire_department_rounded,
                  iconColor: Colors.deepOrange,
                  value: '~${meal.estimatedCalories}',
                  unit: 'kcal',
                  label: 'Calories',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.hourglass_top_rounded,
                  iconColor: AppColors.primary,
                  value: '${meal.prepTimeMinutes}',
                  unit: 'mins',
                  label: 'Prep Time',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.soup_kitchen_rounded,
                  iconColor: AppColors.amber,
                  value: '${meal.cookTimeMinutes}',
                  unit: 'mins',
                  label: 'Cook Time',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  icon: Icons.kitchen_rounded,
                  iconColor: AppColors.primaryDark,
                  value: '${meal.ingredients.length}',
                  unit: 'items',
                  label: 'Ingredients',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Total Duration Pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFDCFCE7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_rounded, size: 15, color: Color(0xFF15803D)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Total Duration: ~${meal.totalTimeMinutes} mins  (Prep ${meal.prepTimeMinutes}m + Cook ${meal.cookTimeMinutes}m)',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF166534),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Ingredients Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shopping_basket_rounded, color: AppColors.primaryDark, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Ingredients',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${meal.ingredients.length} items',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 14),
                if (meal.ingredients.isEmpty)
                  const Text(
                    'No ingredient information available.',
                    style: TextStyle(color: AppColors.textLight),
                  )
                else
                  ...meal.ingredients.entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.key,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          if (entry.value.toString().isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Instructions Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cardBorder),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.menu_book_rounded, color: AppColors.coral, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Cooking Steps',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.cardBorder),
                const SizedBox(height: 16),
                if (steps.isEmpty)
                  Text(
                    rawInstructions.isNotEmpty
                        ? rawInstructions
                        : 'Instructions not available.',
                    style: const TextStyle(fontSize: 14, height: 1.6, color: AppColors.textDark),
                  )
                else
                  ...steps.asMap().entries.map((stepEntry) {
                    final index = stepEntry.key + 1;
                    final stepText = stepEntry.value;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                            ),
                            child: Center(
                              child: Text(
                                '$index',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              stepText,
                              style: const TextStyle(
                                fontSize: 14,
                                height: 1.55,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // YouTube Video Card (If Available)
          if (hasYoutube) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFFECDD3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Color(0xFFE11D48),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Video Tutorial Available',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF9F1239),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          meal.strYoutube,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFBE123C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 20, color: Color(0xFFE11D48)),
                    tooltip: 'Copy Video Link',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: meal.strYoutube));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('YouTube video link copied!'),
                          backgroundColor: const Color(0xFFE11D48),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String unit,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          Text(
            unit,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textLight),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
