# NutriTrack - Personal Health & Nutrition Tracker 🌿

**NutriTrack** is a modern Flutter mobile application designed to help individuals monitor their daily health habits, track hydration and body weight, calculate Body Mass Index (BMI), and explore nutritious meals and recipes.

---

## 👤 Student Profile
* **Name**: Luh Desy Putri Yanti
* **Student ID (NIM)**: 2415051002
* **Class**: PTI-5A
* **Course**: Pemrograman Teknologi Informasi (PTI Semester 5)
* **Institution**: Universitas Pendidikan Ganesha (Undiksha)

---

## ✨ Key Features

1. **Dashboard & Daily Summary**:
   * Interactive water intake tracker with customizable quick presets (`+250 ml`, `+500 ml`).
   * Latest recorded weight card with date tracking.
   * Daily nutrition and wellness tips.
   * Quick action shortcuts to log entries, view history, and search recipes.

2. **Healthy Recipes Catalog**:
   * Explore dishes categorized into Seafood, Vegetarian, Vegan, Chicken, Beef, Breakfast, and Dessert.
   * Real-time recipe search powered by TheMealDB API.
   * Direct favorite toggle from the recipe grid.
   * Estimated calorie calculation per portion.

3. **Detailed Cooking Guide**:
   * Parallax hero image header with collapsible toolbar.
   * Ingredient checklist with precise measurements.
   * Numbered, step-by-step cooking instructions.
   * YouTube tutorial video link with instant copy capability.
   * Share full recipe summary to clipboard.

4. **Health History & Logs**:
   * Historical overview with days tracked, daily average hydration, and latest weight.
   * Add, edit, or delete daily logs backed by Supabase database.
   * Visual progress bars for water goals.

5. **Profile & Ideal BMI Calculator**:
   * Personalized student profile with custom photo support.
   * Interactive Body Mass Index (BMI) calculator with visual 4-color meter and tailored health advice.
   * Favorite recipes management.
   * One-click health report export.
ce.
   * Favorite recipes management.
   * One-click health report export.

---

## 🌐 REST API & Database

### REST API
- **Provider:** [TheMealDB](https://www.themealdb.com/api.php)
- **Base URL:** `https://www.themealdb.com/api/json/v1/1/`
- **Endpoints Used:**
  - `filter.php?c={category}` — Ambil resep berdasarkan kategori (Seafood, Vegetarian, Vegan, Chicken, dll).
  - `search.php?s={query}` — Cari resep berdasarkan kata kunci.
  - `lookup.php?i={id}` — Ambil detail resep berdasarkan ID.
- **Data:** Nama resep, kategori, instruksi, gambar, bahan-bahan.

### Database (Supabase)
- **Provider:** [Supabase](https://supabase.com) (PostgreSQL)
- **Tables:**
  - **`daily_logs`** — Menyimpan catatan harian (air, berat, catatan).
    - Kolom: `id`, `date`, `water_ml`, `weight_kg`, `notes`, `created_at`.
  - **`favorite_meals`** — Menyimpan resep favorit pengguna.
    - Kolom: `id`, `meal_id`, `meal_name`, `meal_thumb`, `created_at`.
- **Security:** Menggunakan **anon key** (bukan `service_role`), dengan RLS policy untuk praktikum.

---

## 🏗️ Application Architecture

NutriTrack menerapkan **Clean Architecture** dengan pemisahan tanggung jawab:

```text
┌─────────────────┐
│   UI Layer      │  Screens, Widgets
│   (Presentation)│  (HomeScreen, LogScreen, etc.)
└────────┬────────┘
         │ context.watch / context.read
         ▼
┌─────────────────┐
│  State Layer    │  Providers (ChangeNotifier)
│  (Provider)     │  (HealthProvider, MealProvider)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Data Layer     │  Services (API, Database)
│  (Service)      │  (MealService, HealthService)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  External       │  REST API (TheMealDB)
│  Sources        │  Database (Supabase)
└─────────────────┘
Struktur Folder:

text
lib/
├── main.dart
├── config/
│   └── supabase_config.dart      # Konfigurasi Supabase
├── data/
│   └── user_constants.dart       # Data user (nama, NIM, kelas)
├── models/
│   ├── daily_log.dart            # Model DailyLog
│   └── meal.dart                 # Model Meal
├── providers/
│   ├── health_provider.dart      # State log & favorit
│   └── meal_provider.dart        # State resep
├── screens/
│   ├── adaptive_shell.dart       # Navigasi utama
│   ├── home_screen.dart          # Dashboard
│   ├── log_screen.dart           # Riwayat log
│   ├── log_form_screen.dart      # Form create/edit log
│   ├── recipes_screen.dart       # Katalog resep
│   ├── recipe_detail_screen.dart # Detail resep
│   └── profile_screen.dart       # Profil & BMI
├── services/
│   ├── health_service.dart       # CRUD Supabase
│   └── meal_service.dart         # REST API TheMealDB
└── widgets/
    ├── error_view.dart           # Widget error reusable
    └── meal_card.dart            # Card resep reusable
Alur Data:

UI (Screen) meminta data ke Provider.

Provider memanggil Service.

Service mengambil data dari REST API atau Database.

Data kembali ke Provider, lalu UI di-rebuild otomatis.

🛠️ Technology Stack
Framework: Flutter 3 (Material Design 3)

Language: Dart 3

State Management: Provider (ChangeNotifier)

Backend Database: Supabase (PostgreSQL)

External API: TheMealDB REST API

Icons: Cupertino Icons & Material Symbols


---

## 🚀 Getting Started

### Prerequisites
* Flutter SDK (3.13+ or higher)
* Android Studio / VS Code with Flutter extension
* Chrome / Android Emulator / Physical Device

### Installation
1. Clone the repository:
   ```bash
   git clone <repository_url>
   cd uts_nutritrack2
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## 📸 Profile Photo Configuration
Profile pictures are located in `assets/images/`:
* File name: `assets/images/profile.jpg`
* Configured in `pubspec.yaml` under `assets:` and `lib/data/user_constants.dart`.

---
*Built with ❤️ for UTS PTI Semester 5*
