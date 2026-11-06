import 'package:flutter/foundation.dart';
import '../models/daily_log.dart';
import '../services/health_service.dart';

class HealthProvider extends ChangeNotifier {
  final HealthService _service = HealthService();

  // State: Logs 
  List<DailyLog> logs = [];
  bool isLoadingLogs = false;
  String? errorLogs;

  // State: Favorites
  List<Map<String, dynamic>> favorites = [];
  bool isLoadingFavorites = false;
  String? errorFavorites;

  // State: Saving 
  bool isSaving = false;

  // READ: Load semua log
  Future<void> loadLogs() async {
    isLoadingLogs = true;
    errorLogs = null;
    notifyListeners();

    try {
      logs = await _service.getAllLogs();
    } catch (e) {
      errorLogs = e.toString();
    } finally {
      isLoadingLogs = false;
      notifyListeners();
    }
  }

  //CREATE: Tambah log baru 
  Future<bool> createLog(DailyLog log) async {
    isSaving = true;
    errorLogs = null;
    notifyListeners();

    try {
      await _service.createLog(log);
      await loadLogs(); // Refresh list
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorLogs = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  //UPDATE: Ubah log
  Future<bool> updateLog(int id, DailyLog log) async {
    isSaving = true;
    errorLogs = null;
    notifyListeners();

    try {
      await _service.updateLog(id, log);
      await loadLogs();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorLogs = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  //DELETE: Hapus log
  Future<bool> deleteLog(int id) async {
    isSaving = true;
    errorLogs = null;
    notifyListeners();

    try {
      await _service.deleteLog(id);
      await loadLogs();
      isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorLogs = e.toString();
      isSaving = false;
      notifyListeners();
      return false;
    }
  }

  
  // READ: Load semua favorit 
  Future<void> loadFavorites() async {
    isLoadingFavorites = true;
    errorFavorites = null;
    notifyListeners();

    try {
      favorites = await _service.getAllFavorites();
    } catch (e) {
      errorFavorites = e.toString();
    } finally {
      isLoadingFavorites = false;
      notifyListeners();
    }
  }

  // CREATE: Tambah favorit
  Future<bool> addFavorite({
    required String mealId,
    required String mealName,
    String? mealThumb,
  }) async {
    try {
      await _service.addFavorite(
        mealId: mealId,
        mealName: mealName,
        mealThumb: mealThumb,
      );
      await loadFavorites();
      return true;
    } catch (e) {
      errorFavorites = e.toString();
      notifyListeners();
      return false;
    }
  }

  // DELETE: Hapus favorit 
  Future<bool> removeFavorite(String mealId) async {
    try {
      await _service.removeFavorite(mealId);
      await loadFavorites();
      return true;
    } catch (e) {
      errorFavorites = e.toString();
      notifyListeners();
      return false;
    }
  }

  // CEK: Apakah meal favorit 
  bool isFavorite(String mealId) {
    return favorites.any((f) => f['meal_id'] == mealId);
  }

  // GET: Total favorit 
  int get favoriteCount => favorites.length;

  
  int get todayWaterIntake {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final todayEntries = logs.where((l) => l.date == todayStr).toList();
    if (todayEntries.isNotEmpty) {
      return todayEntries.fold<int>(0, (sum, l) => sum + l.waterMl);
    }
    
    if (logs.isNotEmpty) {
      final latestDate = logs.first.date;
      return logs
          .where((l) => l.date == latestDate)
          .fold<int>(0, (sum, l) => sum + l.waterMl);
    }
    return 0;
  }

  
  int get todayWaterLogCount {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final todayEntries = logs.where((l) => l.date == todayStr).toList();
    if (todayEntries.isNotEmpty) {
      return todayEntries.length;
    }
    if (logs.isNotEmpty) {
      final latestDate = logs.first.date;
      return logs.where((l) => l.date == latestDate).length;
    }
    return 0;
  }

  
  String get activeWaterDate {
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final hasToday = logs.any((l) => l.date == todayStr);
    if (hasToday) return 'Today';
    if (logs.isNotEmpty) return logs.first.date;
    return 'Today';
  }

  
  double? get latestWeight {
    for (final log in logs) {
      if (log.weightKg != null && log.weightKg! > 0) {
        return log.weightKg;
      }
    }
    return null;
  }

  // Date of the latest weight recorded
  String? get latestWeightDate {
    for (final log in logs) {
      if (log.weightKg != null && log.weightKg! > 0) {
        return log.date;
      }
    }
    return null;
  }

  
  int get totalWaterAllTime {
    return logs.fold<int>(0, (sum, l) => sum + l.waterMl);
  }

  // Number of distinct calendar days tracked in history
  int get uniqueDaysTracked {
    return logs.map((l) => l.date).toSet().length;
  }

  
  int get dailyAverageWater {
    final days = uniqueDaysTracked;
    if (days == 0) return 0;
    return (totalWaterAllTime / days).round();
  }

  // Total water aggregated per calendar date
  Map<String, int> get dailyWaterByDate {
    final map = <String, int>{};
    for (final log in logs) {
      map[log.date] = (map[log.date] ?? 0) + log.waterMl;
    }
    return map;
  }
}