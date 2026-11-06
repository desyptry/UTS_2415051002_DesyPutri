// lib/screens/recipe_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal.dart';
import '../providers/health_provider.dart';
import '../providers/meal_provider.dart';

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
    // Panggil API detail saat layar dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MealProvider>().loadMealDetail(widget.mealId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealProvider = context.watch<MealProvider>();
    final health = context.watch<HealthProvider>();

    final meal = mealProvider.selectedMeal;
    final isLoading = mealProvider.isLoadingDetail;
    final isFav = health.isFavorite(widget.mealId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recipe Detail'),
        backgroundColor: const Color(0xFF00BFA5),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () async {
              final provider = context.read<HealthProvider>();
              if (isFav) {
                await provider.removeFavorite(widget.mealId);
              } else {
                await provider.addFavorite(
                  mealId: widget.mealId,
                  mealName: widget.initialTitle,
                  mealThumb: widget.initialImage,
                );
              }
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(isFav ? 'Removed from favorites' : 'Added to favorites'),
                  backgroundColor: isFav ? Colors.orange : Colors.green,
                ),
              );
            },
            icon: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              color: isFav ? Colors.red : Colors.white,
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : meal == null
              ? const Center(child: Text('Failed to load details'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        meal.strMealThumb ?? widget.initialImage,
                        width: double.infinity,
                        height: 250,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 250,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.restaurant, size: 80, color: Colors.grey),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(meal.strMeal, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Chip(
                                  label: Text(meal.strCategory ?? '-'),
                                  backgroundColor: const Color(0xFF00BFA5).withValues(alpha: 0.2),
                                ),
                                const SizedBox(width: 8),
                                Chip(
                                  label: Text(meal.strArea ?? '-'),
                                  backgroundColor: Colors.orange.shade100,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            Row(
                              children: [
                                const Icon(Icons.local_fire_department, color: Colors.deepOrange),
                                const SizedBox(width: 8),
                                Text(
                                  'Estimate: ~${meal.estimatedCalories} kkal per portion',
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Divider(),
                            const Text('Ingredients', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (meal.ingredients.isEmpty)
                              const Text('Ingredients not available.', style: TextStyle(color: Colors.grey))
                            else
                              ...meal.ingredients.entries.map((entry) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.check_circle, size: 16, color: Color(0xFF00BFA5)),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${entry.value.isEmpty ? '' : '${entry.value} '}${entry.key}',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            const SizedBox(height: 16),
                            const Divider(),
                            const Text('Instructions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(meal.strInstructions ?? 'Instructions not available.', style: const TextStyle(fontSize: 14, height: 1.5)),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}