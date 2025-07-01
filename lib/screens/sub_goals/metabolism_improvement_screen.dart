import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/health_condition_screen.dart'; // <-- Import ini ditambahkan

class MetabolismImprovementScreen extends StatelessWidget {
  const MetabolismImprovementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Bagaimana pola makan Anda saat ini?',
      subtitle: 'Pilih yang paling menggambarkan kebiasaan Anda',
      dbKey: 'currentDietPattern', // Key di Firebase
      nextScreen: const HealthConditionScreen(), // <-- Ini diubah
      screenDescription: 'MetabolismImprovementScreen',
      options: [
        {
          'title': 'Tinggi karbohidrat olahan',
          'subtitle': 'Banyak roti putih, pasta, dan makanan manis',
          'icon': Icons.bakery_dining,
          'iconColor': Colors.brown,
          'valueToSave': 'Tinggi karbohidrat olahan',
        },
        {
          'title': 'Tinggi lemak tidak sehat',
          'subtitle': 'Sering konsumsi gorengan dan makanan cepat saji',
          'icon': Icons.fastfood,
          'iconColor': Colors.red,
          'valueToSave': 'Tinggi lemak tidak sehat',
        },
        {
          'title': 'Seimbang dan bervariasi',
          'subtitle': 'Mengandung protein, karbohidrat kompleks, dan serat',
          'icon': Icons.restaurant_menu,
          'iconColor': Colors.green,
          'valueToSave': 'Seimbang dan bervariasi',
        },
        {
          'title': 'Vegetarian/Vegan',
          'subtitle': 'Berbasis tumbuhan, tanpa produk hewani',
          'icon': Icons.eco,
          'iconColor': Colors.lightGreen,
          'valueToSave': 'Vegetarian/Vegan',
        },
        {
          'title': 'Tidak teratur',
          'subtitle': 'Sering melewatkan makan atau makan tidak tepat waktu',
          'icon': Icons.schedule,
          'iconColor': Colors.grey,
          'valueToSave': 'Tidak teratur',
        },
      ],
    );
  }
}