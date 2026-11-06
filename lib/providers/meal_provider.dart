// lib/providers/meal_provider.dart
import 'package:flutter/foundation.dart';
import '../models/meal.dart';
import '../services/meal_service.dart';

class MealProvider extends ChangeNotifier {
  final MealService _service = MealService();

  // State untuk List Resep
  List<Meal> meals = [];
  bool isLoading = false;
  String? error;
  String currentCategory = 'Seafood';
  String currentQuery = '';

  // State untuk Detail Resep (BARU)
  Meal? selectedMeal;
  bool isLoadingDetail = false;

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

  Future<void> searchMeals(String query) async {
    if (query.trim().isEmpty) return loadMeals();
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

  // ===== BARU: Load Detail Resep =====
  Future<void> loadMealDetail(String id) async {
    isLoadingDetail = true;
    selectedMeal = null;
    notifyListeners();

    try {
      selectedMeal = await _service.getMealById(id);
    } catch (e) {
      error = e.toString();
    } finally {
      isLoadingDetail = false;
      notifyListeners();
    }
  }
}