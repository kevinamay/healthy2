import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart'; // Menggunakan BaseQuestionScreen
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini
import 'package:hitung/screens/diet_duration_screen.dart';

class DietScreen extends StatelessWidget {
  const DietScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Diet apa yang Anda ikuti?',
      subtitle: 'Pilih jenis diet yang sedang atau pernah Anda jalani.',
      dbKey: 'currentDiet', // Key untuk menyimpan di Firebase Realtime Database
      nextScreen: const DietDurationScreen(), // Ganti dengan halaman final yang sebenarnya nanti
      screenDescription: 'DietScreen', // Deskripsi untuk debugging
      options: [
        {
          'title': 'Tidak ada',
          'subtitle': 'Tidak mengikuti diet tertentu.',
          'icon': Icons.block,
          'iconColor': Colors.grey.shade600,
          'valueToSave': 'Tidak ada',
        },
        {
          'title': 'Diet Mediterania',
          'subtitle': 'Fokus pada buah, sayur, biji-bijian, minyak zaitun, dan ikan.',
          'icon': Icons.restaurant_menu,
          'iconColor': Colors.blue.shade400,
          'valueToSave': 'Diet Mediterania',
        },
        {
          'title': 'Diet Keto',
          'subtitle': 'Rendah karbohidrat, tinggi lemak.',
          'icon': Icons.local_fire_department,
          'iconColor': Colors.orange.shade400,
          'valueToSave': 'Diet Keto',
        },
        {
          'title': 'Diet Vegan',
          'subtitle': 'Hanya mengonsumsi makanan nabati, tanpa produk hewani.',
          'icon': Icons.eco,
          'iconColor': Colors.green.shade400,
          'valueToSave': 'Diet Vegan',
        },
        {
          'title': 'Diet Vegetarian',
          'subtitle': 'Tidak makan daging, tetapi bisa mengonsumsi produk susu/telur.',
          'icon': Icons.grass,
          'iconColor': Colors.lightGreen.shade400,
          'valueToSave': 'Diet Vegetarian',
        },
        {
          'title': 'Diet Rendah Karbohidrat',
          'subtitle': 'Membatasi asupan karbohidrat.',
          'icon': Icons.no_food,
          'iconColor': Colors.red.shade400,
          'valueToSave': 'Diet Rendah Karbohidrat',
        },
        {
          'title': 'Diet Puasa Intermiten',
          'subtitle': 'Membatasi waktu makan dalam sehari atau seminggu.',
          'icon': Icons.timer,
          'iconColor': Colors.purple.shade400,
          'valueToSave': 'Diet Puasa Intermiten',
        },
        {
          'title': 'Diet Paleo',
          'subtitle': 'Makan seperti manusia gua: daging, ikan, buah, sayur, kacang-kacangan.',
          'icon': Icons.forest,
          'iconColor': Colors.brown.shade400,
          'valueToSave': 'Diet Paleo',
        },
      ],
    );
  }
}