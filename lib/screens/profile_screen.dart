import 'package:flutter/material.dart';
import '../data/user_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),

          // Profil User 
          CircleAvatar(
            radius: 55,
            backgroundColor: const Color(0xFF00BFA5),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'ID: $userId',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            userInfo,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Health Enthusiast 🌱',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Color(0xFF00BFA5),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),

          // Fitur Tambahan
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Fitur Tambahan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: const Icon(Icons.calculate, color: Color(0xFF00BFA5)),
              title: const Text('Kalkulator BMI'),
              subtitle: const Text('Hitung indeks massa tubuh'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 14),
              onTap: () {},
            ),
          ),

          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: const ListTile(
              leading: Icon(Icons.info_outline, color: Color(0xFF00BFA5)),
              title: Text('Tentang Aplikasi'),
              subtitle: Text('NutriTrack v1.0'),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}