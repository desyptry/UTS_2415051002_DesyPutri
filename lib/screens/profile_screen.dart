// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/user_constants.dart';
import '../providers/health_provider.dart';
import 'recipe_detail_screen.dart'; // Import untuk navigasi ke detail

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final health = context.watch<HealthProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Profil
          CircleAvatar(
            radius: 55,
            backgroundColor: const Color(0xFF00BFA5),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(userName,
              style: const TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('ID: $userId',
              style: const TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(userInfo,
              style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 8),
          const Text('Health Enthusiast 🌱',
              style: TextStyle(
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: Color(0xFF00BFA5))),
          const SizedBox(height: 24),
          const Divider(),

          // Tombol BMI
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: const Icon(Icons.calculate, color: Color(0xFF00BFA5)),
              title: const Text('BMI Calculator'),
              subtitle: const Text('Calculate Body Mass Index'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () => _showBmiDialog(context),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),

          // Favorit
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text('Favorite Recipes (${health.favoriteCount})',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 12),
          if (health.isLoadingFavorites)
            const Center(child: CircularProgressIndicator())
          else if (health.favorites.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No favorite recipes yet',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else
            ...health.favorites.map((fav) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    // Klik item untuk buka detail resep
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RecipeDetailScreen(
                            mealId: fav['meal_id'],
                            initialImage: fav['meal_thumb'] ?? '',
                            initialTitle: fav['meal_name'] ?? '',
                          ),
                        ),
                      );
                    },
                    leading: fav['meal_thumb'] != null
                        ? Image.network(fav['meal_thumb'],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.restaurant, size: 50),
                    title: Text(fav['meal_name'] ?? ''),
                    // Tombol hapus dengan konfirmasi
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmRemoveFavorite(context, fav['meal_id'], fav['meal_name']),
                    ),
                  ),
                )),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // Dialog konfirmasi hapus favorit
  Future<void> _confirmRemoveFavorite(BuildContext context, String mealId, String mealName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Favorite?'),
        content: Text('Remove "$mealName" from your favorites?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await context.read<HealthProvider>().removeFavorite(mealId);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Removed from favorites' : 'Failed to remove'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _showBmiDialog(BuildContext context) {
    final heightCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    double? bmi;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('BMI Calculator'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: heightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Height (cm)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: weightCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'Weight (kg)', border: OutlineInputBorder()),
              ),
              if (bmi != null) ...[
                const SizedBox(height: 16),
                Text('BMI: ${bmi!.toStringAsFixed(1)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                Text(
                  bmi! < 18.5
                      ? 'Underweight'
                      : bmi! < 25
                          ? 'Normal'
                          : bmi! < 30
                              ? 'Overweight'
                              : 'Obese',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                final h = double.tryParse(heightCtrl.text) ?? 0;
                final w = double.tryParse(weightCtrl.text) ?? 0;
                if (h > 0 && w > 0) {
                  setState(() => bmi = w / ((h / 100) * (h / 100)));
                }
              },
              child: const Text('Calculate'),
            ),
          ],
        ),
      ),
    );
  }
}