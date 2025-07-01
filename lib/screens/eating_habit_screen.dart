import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart'; // Menggunakan BaseQuestionScreen
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini
import 'package:hitung/screens/meal_time_screen.dart';

class EatingHabitScreen extends StatelessWidget {
  const EatingHabitScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Seberapa sering Anda biasanya makan?',
      subtitle: '', // Subtitle kosong sesuai gambar
      dbKey: 'eatingFrequency', // Key untuk menyimpan di Firebase
      nextScreen: const MealTimeScreen(), // Ganti dengan halaman final yang sebenarnya nanti
      screenDescription: 'EatingHabitScreen', // Deskripsi untuk debugging
      options: [
        {
          'title': 'Satu kali makan sehari',
          'subtitle': '',
          'icon': Icons.looks_one,
          'iconColor': Colors.green.shade400,
          'valueToSave': 'Satu kali makan sehari',
        },
        {
          'title': 'Dua kali makan sehari',
          'subtitle': '',
          'icon': Icons.looks_two,
          'iconColor': Colors.lightGreen.shade400,
          'valueToSave': 'Dua kali makan sehari',
        },
        {
          'title': 'Makan tiga kali sehari',
          'subtitle': '',
          'icon': Icons.looks_3,
          'iconColor': Colors.amber.shade400,
          'valueToSave': 'Makan tiga kali sehari',
        },
        {
          'title': 'Lebih dari tiga kali sehari',
          'subtitle': '',
          'icon': Icons.more_horiz, // Atau Icons.looks_4 untuk 4+
          'iconColor': Colors.red.shade400,
          'valueToSave': 'Lebih dari tiga kali sehari',
        },
        // Anda bisa menambahkan opsi lain jika relevan:
        {
          'title': 'Jadwal makan tidak teratur',
          'subtitle': 'Waktu makan sering berubah-ubah',
          'icon': Icons.schedule,
          'iconColor': Colors.blueGrey.shade400,
          'valueToSave': 'Jadwal makan tidak teratur',
        },
      ],
    );
  }
}