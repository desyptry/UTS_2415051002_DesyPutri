// lib/screens/recipes_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/meal_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/meal_card.dart';
import '../widgets/error_view.dart';
import 'recipe_detail_screen.dart';

class RecipesScreen extends StatefulWidget {
  const RecipesScreen({super.key});

  @override
  State<RecipesScreen> createState() => _RecipesScreenState();
}

class _RecipesScreenState extends State<RecipesScreen> {
  final _searchCtrl = TextEditingController();

  final List<({String key, String label})> _categories = const [
    (key: 'Seafood', label: '🐟 Seafood'),
    (key: 'Vegetarian', label: '🥗 Vegetarian'),
    (key: 'Vegan', label: '🌱 Vegan'),
    (key: 'Chicken', label: '🍗 Chicken'),
    (key: 'Beef', label: '🥩 Beef'),
    (key: 'Breakfast', label: '🍳 Breakfast'),
    (key: 'Dessert', label: '🍓 Dessert'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.trim().isNotEmpty) {
      context.read<MealProvider>().searchMeals(query);
    } else {
      context.read<MealProvider>().loadMeals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MealProvider>();

    return Column(
      children: [
        // 1. Search Bar & Filter Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppColors.cardBorder, width: 1),
            ),
          ),
          child: Column(
            children: [
              // Search Input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _onSearch,
                  decoration: InputDecoration(
                    hintText: 'Search healthy recipes, ingredients...',
                    hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryDark),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded, color: AppColors.textLight, size: 20),
                            onPressed: () {
                              _searchCtrl.clear();
                              context.read<MealProvider>().loadMeals();
                              setState(() {});
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.transparent,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                  ),
                  onChanged: (val) {
                    setState(() {});
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Categories Chips
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = provider.currentCategory == cat.key;

                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      child: ChoiceChip(
                        label: Text(cat.label),
                        selected: isSelected,
                        onSelected: (_) {
                          _searchCtrl.clear();
                          context.read<MealProvider>().loadMeals(category: cat.key);
                        },
                        showCheckmark: false,
                        selectedColor: AppColors.primary,
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: isSelected ? AppColors.primary : AppColors.cardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textDark,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 12.5,
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // 2. Grid & State Views
        Expanded(
          child: _buildGrid(provider),
        ),
      ],
    );
  }

  Widget _buildGrid(MealProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading nutritious & delicious meals...',
              style: TextStyle(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (provider.error != null) {
      return ErrorView(
        message: provider.error!,
        onRetry: () => context.read<MealProvider>().loadMeals(),
      );
    }

    if (provider.meals.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.no_meals_rounded,
                  size: 56,
                  color: AppColors.textLight,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'No Recipes Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Try searching with another keyword or explore categories above.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _searchCtrl.clear();
                  context.read<MealProvider>().loadMeals(category: 'Seafood');
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Reset Search'),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 600
            ? 2
            : constraints.maxWidth < 840
                ? 3
                : 4;

        return GridView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.72,
          ),
          itemCount: provider.meals.length,
          itemBuilder: (context, index) {
            final meal = provider.meals[index];
            return MealCard(
              meal: meal,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecipeDetailScreen(
                      mealId: meal.idMeal,
                      initialImage: meal.strMealThumb ?? '',
                      initialTitle: meal.strMeal,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
