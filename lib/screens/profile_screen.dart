// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/user_constants.dart';
import '../providers/health_provider.dart';

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
              subtitle: const Text('Calculate your body mass index'),
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
            child: Text('Favorites (${health.favoriteCount})',
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
                  child: ListTile(
                    leading: fav['meal_thumb'] != null
                        ? Image.network(fav['meal_thumb'],
                            width: 50, height: 50, fit: BoxFit.cover)
                        : const Icon(Icons.restaurant),
                    title: Text(fav['meal_name'] ?? ''),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () {
                        context
                            .read<HealthProvider>()
                            .removeFavorite(fav['meal_id']);
                      },
                    ),
                  ),
                )),
          const SizedBox(height: 32),
        ],
      ),
    );
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
                              : 'Obesity',
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