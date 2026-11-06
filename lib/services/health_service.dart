import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/daily_log.dart';

class HealthService {
  final supabase = Supabase.instance.client;

  //READ: Ambil semua log 
  Future<List<DailyLog>> getAllLogs() async {
    final data = await supabase
        .from('daily_logs')
        .select()
        .order('date', ascending: false);

    return (data as List)
        .map((e) => DailyLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // CREATE: Tambah log baru 
  Future<DailyLog> createLog(DailyLog log) async {
    final row = await supabase
        .from('daily_logs')
        .insert(log.toJson())
        .select()
        .single();

    return DailyLog.fromJson(row);
  }

  // UPDATE: Ubah log berdasarkan id 
  Future<void> updateLog(int id, DailyLog log) async {
    await supabase
        .from('daily_logs')
        .update(log.toJson())
        .eq('id', id);
  }

  // DELETE: Hapus log berdasarkan id 
  Future<void> deleteLog(int id) async {
    await supabase
        .from('daily_logs')
        .delete()
        .eq('id', id);
  }

  
  // READ: Ambil semua favorit 
  Future<List<Map<String, dynamic>>> getAllFavorites() async {
    final data = await supabase
        .from('favorite_meals')
        .select()
        .order('created_at', ascending: false);

    return (data as List).cast<Map<String, dynamic>>();
  }

  // CREATE: Tambah favorit 
  Future<void> addFavorite({
    required String mealId,
    required String mealName,
    String? mealThumb,
  }) async {
    await supabase.from('favorite_meals').insert({
      'meal_id': mealId,
      'meal_name': mealName,
      'meal_thumb': mealThumb,
    });
  }

  // DELETE: Hapus favorit berdasarkan meal_id 
  Future<void> removeFavorite(String mealId) async {
    await supabase
        .from('favorite_meals')
        .delete()
        .eq('meal_id', mealId);
  }

  // READ: Cek apakah meal sudah difavoritkan
  Future<bool> isFavorite(String mealId) async {
    final data = await supabase
        .from('favorite_meals')
        .select()
        .eq('meal_id', mealId)
        .limit(1);

    return (data as List).isNotEmpty;
  }
}