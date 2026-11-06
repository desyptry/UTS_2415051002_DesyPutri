import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/meal.dart';

class MealService {
  static const String baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Fetch meals by category
  Future<List<Meal>> getHealthyMeals({String category = 'Seafood'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/filter.php?c=$category'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final meals = data['meals'] as List<dynamic>?;

        if (meals == null) return [];

        return meals.map((e) {
          final item = Map<String, dynamic>.from(e as Map<String, dynamic>);
          item['strCategory'] = category;
          return Meal.fromJson(item);
        }).toList();
      }
      throw Exception('Failed to load recipes: HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Search meals by query
  Future<List<Meal>> searchMeals(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search.php?s=$query'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final meals = data['meals'] as List<dynamic>?;

        if (meals == null) return [];

        return meals
            .map((e) => Meal.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to search recipes: HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Fetch meal details by ID
  Future<Meal?> getMealById(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/lookup.php?i=$id'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final meals = data['meals'] as List<dynamic>?;

        if (meals == null || meals.isEmpty) return null;

        return Meal.fromJson(meals.first as Map<String, dynamic>);
      }
      throw Exception('Failed to load recipe details: HTTP ${response.statusCode}');
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
