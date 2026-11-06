// lib/models/meal.dart
class Meal {
  final String idMeal;
  final String strMeal;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strMealThumb;
  final String? strYoutube;
  final Map<String, String> ingredients; // ← BARU

  const Meal({
    required this.idMeal,
    required this.strMeal,
    this.strCategory,
    this.strArea,
    this.strInstructions,
    this.strMealThumb,
    this.strYoutube,
    this.ingredients = const {},
  });

  factory Meal.fromJson(Map<String, dynamic> json) {
    // Parse bahan-bahan dari strIngredient1..20 & strMeasure1..20
    final ingredientsMap = <String, String>{};
    for (int i = 1; i <= 20; i++) {
      final ing = json['strIngredient$i'] as String?;
      final measure = json['strMeasure$i'] as String?;
      if (ing != null && ing.trim().isNotEmpty) {
        ingredientsMap[ing.trim()] = (measure ?? '').trim();
      }
    }

    return Meal(
      idMeal: json['idMeal'] as String,
      strMeal: json['strMeal'] as String,
      strCategory: json['strCategory'] as String?,
      strArea: json['strArea'] as String?,
      strInstructions: json['strInstructions'] as String?,
      strMealThumb: json['strMealThumb'] as String?,
      strYoutube: json['strYoutube'] as String?,
      ingredients: ingredientsMap,
    );
  }

  // Estimasi kalori kasar (TheMealDB tidak sediakan kalori)
  // Nilai ini hanya perkiraan berdasarkan jumlah bahan
  int get estimatedCalories {
    // Rata-rata kalori per bahan: ~50 kkal
    // Total kalori per porsi: ~400-600 kkal
    return 400 + (ingredients.length * 15);
  }
}