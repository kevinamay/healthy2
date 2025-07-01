import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart'; // Menggunakan BaseQuestionScreen
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini
import 'package:hitung/screens/diet_screen.dart';

class HungerTimeScreen extends StatelessWidget {
  const HungerTimeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Kapan Anda merasa paling lapar dalam sehari?',
      subtitle: 'Pilih waktu di mana Anda paling sering merasakan lapar yang signifikan.',
      dbKey: 'hungerTime', // Key untuk menyimpan di Firebase Realtime Database
      nextScreen: const DietScreen(), // Ganti dengan halaman final yang sebenarnya nanti
      screenDescription: 'HungerTimeScreen', // Deskripsi untuk debugging
      options: [
        {
          'title': 'Pagi hari',
          'subtitle': 'Merasa sangat lapar setelah bangun tidur atau sebelum sarapan.',
          'icon': Icons.wb_sunny,
          'iconColor': Colors.orange.shade400,
          'valueToSave': 'Pagi hari',
        },
        {
          'title': 'Siang hari',
          'subtitle': 'Lapar di antara waktu sarapan dan makan siang, atau sebelum makan siang.',
          'icon': Icons.lunch_dining,
          'iconColor': Colors.amber.shade400,
          'valueToSave': 'Siang hari',
        },
        {
          'title': 'Malam hari',
          'subtitle': 'Merasa lapar di sore hari atau sebelum tidur.',
          'icon': Icons.nightlight_round,
          'iconColor': Colors.blueGrey.shade400,
          'valueToSave': 'Malam hari',
        },
        {
          'title': 'Sepanjang hari',
          'subtitle': 'Merasa lapar hampir setiap saat, sulit merasa kenyang.',
          'icon': Icons.hourglass_empty,
          'iconColor': Colors.red.shade400,
          'valueToSave': 'Sepanjang hari',
        },
        {
          'title': 'Tidak tentu',
          'subtitle': 'Pola lapar tidak konsisten atau bervariasi setiap hari.',
          'icon': Icons.schedule,
          'iconColor': Colors.grey.shade400,
          'valueToSave': 'Tidak tentu',
        },
      ],
    );
  }
}