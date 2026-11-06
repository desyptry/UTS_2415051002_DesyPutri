import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

class MealProvider extends ChangeNotifier {
  final MealService _service = MealService();

  List<Meal> meals = [];
  bool isLoading = false;
  String? error;
  String currentCategory = 'Seafood';
  String currentQuery = '';

  //  Load resep berdasarkan kategori 
  Future<void> loadMeals({String? category}) async {
    if (category != null) currentCategory = category;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      meals = await _service.getHealthyMeals(category: currentCategory);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  //  Search resep 
  Future<void> searchMeals(String query) async {
    if (query.trim().isEmpty) {
      return loadMeals();
    }
    currentQuery = query;
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      meals = await _service.searchMeals(query);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Ambil detail resep by id 
  Future<Meal?> getMealById(String id) async {
    try {
      return await _service.getMealById(id);
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return null;
    }
  }
}