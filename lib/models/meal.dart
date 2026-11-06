class Meal {
  final String idMeal;
  final String strMeal;
  final String? strCategory;
  final String? strArea;
  final String? strInstructions;
  final String? strMealThumb;
  final String? strYoutube;
  final Map<String, String> ingredients;

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
    // Parse ingredients from strIngredient1..20 & strMeasure1..20
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

  /// Calculates dynamic, realistic, and distinct calorie estimates per portion
  int get estimatedCalories {
    
    if (ingredients.isNotEmpty) {
      int base = 280;
      final cat = (strCategory ?? '').toLowerCase();
      if (cat.contains('vegan')) {
        base = 250;
      } else if (cat.contains('vegetarian')) {
        base = 280;
      } else if (cat.contains('seafood') || cat.contains('fish')) {
        base = 330;
      } else if (cat.contains('chicken')) {
        base = 410;
      } else if (cat.contains('beef') || cat.contains('meat') || cat.contains('lamb')) {
        base = 490;
      } else if (cat.contains('breakfast')) {
        base = 310;
      } else if (cat.contains('dessert')) {
        base = 350;
      }

      int ingredientCalories = ingredients.length * 16;
      for (final ing in ingredients.keys) {
        final lower = ing.toLowerCase();
        if (lower.contains('oil') ||
            lower.contains('butter') ||
            lower.contains('cheese') ||
            lower.contains('cream') ||
            lower.contains('mayo')) {
          ingredientCalories += 35;
        } else if (lower.contains('sugar') ||
            lower.contains('honey') ||
            lower.contains('syrup') ||
            lower.contains('chocolate')) {
          ingredientCalories += 25;
        } else if (lower.contains('rice') ||
            lower.contains('pasta') ||
            lower.contains('noodle') ||
            lower.contains('bread') ||
            lower.contains('flour') ||
            lower.contains('potato')) {
          ingredientCalories += 30;
        } else if (lower.contains('egg') ||
            lower.contains('milk') ||
            lower.contains('yogurt') ||
            lower.contains('bacon')) {
          ingredientCalories += 20;
        }
      }
      final total = base + ingredientCalories;
      return ((total / 5).round() * 5).clamp(210, 890);
    }

    
    final nameHash = strMeal.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    final idNum = int.tryParse(idMeal) ?? 0;
    final combinedSeed = (idNum * 31 + nameHash).abs();

    int base = 360;
    int variance = 160;

    final cat = (strCategory ?? '').toLowerCase();
    if (cat.contains('vegan')) {
      base = 260;
      variance = 110;
    } else if (cat.contains('vegetarian')) {
      base = 290;
      variance = 120;
    } else if (cat.contains('seafood') || cat.contains('fish')) {
      base = 340;
      variance = 130;
    } else if (cat.contains('chicken')) {
      base = 420;
      variance = 140;
    } else if (cat.contains('beef') || cat.contains('meat') || cat.contains('pork') || cat.contains('lamb')) {
      base = 510;
      variance = 160;
    } else if (cat.contains('breakfast')) {
      base = 320;
      variance = 130;
    } else if (cat.contains('dessert')) {
      base = 360;
      variance = 150;
    }

    final offset = (combinedSeed % variance);
    final rawCalories = base + offset;
    // Round to nearest 5 kcal (e.g. 345, 380, 425, 465, 510)
    return ((rawCalories / 5).round() * 5).clamp(220, 850);
  }

  /// Realistic, dynamic preparation time (in minutes)
  int get prepTimeMinutes {
    // 1. If detailed ingredients are loaded:
    if (ingredients.isNotEmpty) {
      int basePrep = 10;
      final cat = (strCategory ?? '').toLowerCase();
      if (cat.contains('breakfast')) {
        basePrep = 8;
      } else if (cat.contains('vegan') || cat.contains('vegetarian')) {
        basePrep = 12; // Chopping & washing fresh produce
      } else if (cat.contains('seafood')) {
        basePrep = 10;
      } else if (cat.contains('chicken') || cat.contains('beef') || cat.contains('lamb')) {
        basePrep = 15;
      } else if (cat.contains('dessert')) {
        basePrep = 15;
      } else if (cat.contains('pasta')) {
        basePrep = 10;
      }

      final ingCount = ingredients.length;
      if (ingCount > 12) {
        basePrep += 10;
      } else if (ingCount > 7) {
        basePrep += 5;
      }

      final inst = (strInstructions ?? '').toLowerCase();
      if (inst.contains('marinate') || inst.contains('marinade')) {
        basePrep += 10;
      }
      if (inst.contains('chop') || inst.contains('dice') || inst.contains('grate')) {
        basePrep += 5;
      }

      return ((basePrep / 5).round() * 5).clamp(5, 40);
    }

    // 2. Fallback using category baseline + deterministic hash
    final nameHash = strMeal.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    final idNum = int.tryParse(idMeal) ?? 0;
    final seed = (idNum * 17 + nameHash).abs();

    int base = 10;
    final cat = (strCategory ?? '').toLowerCase();
    if (cat.contains('breakfast')) {
      base = 10;
    } else if (cat.contains('vegan') || cat.contains('vegetarian')) {
      base = 15;
    } else if (cat.contains('chicken') || cat.contains('beef') || cat.contains('lamb')) {
      base = 20;
    } else if (cat.contains('dessert')) {
      base = 20;
    } else if (cat.contains('seafood')) {
      base = 15;
    }

    final variance = (seed % 3) * 5; // 0, 5, or 10
    final prep = (base + variance - 5).clamp(5, 35);
    return (prep / 5).round() * 5;
  }

  /// Realistic, dynamic cooking time (in minutes)
  int get cookTimeMinutes {
    // 1. If instructions are loaded:
    if (strInstructions != null && strInstructions!.isNotEmpty) {
      final inst = strInstructions!.toLowerCase();
      int baseCook = 20;
      final cat = (strCategory ?? '').toLowerCase();

      if (cat.contains('breakfast')) {
        baseCook = 15;
      } else if (cat.contains('seafood')) {
        baseCook = 15; // Quick to keep tender
      } else if (cat.contains('vegan') || cat.contains('vegetarian')) {
        baseCook = 20;
      } else if (cat.contains('pasta')) {
        baseCook = 15;
      } else if (cat.contains('chicken')) {
        baseCook = 25;
      } else if (cat.contains('beef') || cat.contains('lamb') || cat.contains('meat') || cat.contains('pork')) {
        baseCook = 40;
      } else if (cat.contains('dessert')) {
        baseCook = 30;
      }

      if (inst.contains('roast') ||
          inst.contains('bake') ||
          inst.contains('oven') ||
          inst.contains('simmer') ||
          inst.contains('stew') ||
          inst.contains('slow cook') ||
          inst.contains('braise')) {
        baseCook += 15;
      } else if (inst.contains('stir fry') ||
          inst.contains('skillet') ||
          inst.contains('quick') ||
          inst.contains('toast')) {
        baseCook -= 5;
      }

      return ((baseCook / 5).round() * 5).clamp(10, 80);
    }

    // 2. Fallback using category baseline + deterministic hash
    final nameHash = strMeal.codeUnits.fold<int>(0, (prev, elem) => prev + elem);
    final idNum = int.tryParse(idMeal) ?? 0;
    final seed = (idNum * 23 + nameHash).abs();

    int base = 25;
    final cat = (strCategory ?? '').toLowerCase();
    if (cat.contains('breakfast')) {
      base = 15;
    } else if (cat.contains('seafood')) {
      base = 20;
    } else if (cat.contains('vegan') || cat.contains('vegetarian')) {
      base = 25;
    } else if (cat.contains('chicken')) {
      base = 35;
    } else if (cat.contains('beef') || cat.contains('meat') || cat.contains('pork') || cat.contains('lamb')) {
      base = 45;
    } else if (cat.contains('dessert')) {
      base = 35;
    }

    final variance = (seed % 4) * 5; // 0, 5, 10, or 15
    final cook = (base + variance - 5).clamp(10, 75);
    return (cook / 5).round() * 5;
  }

  /// Total time in minutes (prep + cook)
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  /// Formatted summary string
  String get prepCookSummary => 'Prep: ${prepTimeMinutes}m • Cook: ${cookTimeMinutes}m';
}
