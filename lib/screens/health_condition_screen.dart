import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart'; // Menggunakan BaseQuestionScreen
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini

class HealthConditionScreen extends StatelessWidget {
  const HealthConditionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Apakah Anda memiliki kondisi kesehatan berikut?',
      subtitle: 'Pilih yang paling sesuai dengan Anda',
      dbKey: 'healthCondition', // Key untuk menyimpan di Firebase
      nextScreen: const NextPageAfterGoal(), // Ganti dengan halaman final yang sebenarnya nanti
      screenDescription: 'HealthConditionScreen', // Deskripsi untuk debugging
      options: [
        {
          'title': 'Tidak ada',
          'subtitle': '', // Subtitle kosong sesuai gambar
          'icon': Icons.block, // Ikon lingkaran dengan garis miring
          'iconColor': Colors.grey.shade600,
          'valueToSave': 'Tidak ada',
        },
        {
          'title': 'Risiko kardiovaskular',
          'subtitle': '',
          'icon': Icons.favorite, // Ikon hati
          'iconColor': Colors.red.shade400,
          'valueToSave': 'Risiko kardiovaskular',
        },
        {
          'title': 'Gangguan metabolik',
          'subtitle': '',
          'icon': Icons.whatshot, // Ikon api (menunjukkan metabolisme)
          'iconColor': Colors.orange.shade400,
          'valueToSave': 'Gangguan metabolik',
        },
        {
          'title': 'Masalah pernapasan',
          'subtitle': '',
          'icon': Icons.masks, // Ikon masker atau paru-paru
          'iconColor': Colors.lightBlue.shade400,
          'valueToSave': 'Masalah pernapasan',
        },
        {
          'title': 'Masalah kesehatan mental', // Tambahan yang relevan
          'subtitle': '',
          'icon': Icons.self_improvement, // Ikon orang meditasi
          'iconColor': Colors.deepPurple.shade400,
          'valueToSave': 'Masalah kesehatan mental',
        },
        // Anda bisa menambahkan opsi lain jika relevan:
        {
          'title': 'Masalah pencernaan',
          'subtitle': '',
          'icon': Icons.set_meal,
          'iconColor': Colors.brown.shade400,
          'valueToSave': 'Masalah pencernaan',
        },
        {
          'title': 'Masalah sendi/tulang',
          'subtitle': '',
          'icon': Icons.accessibility_new,
          'iconColor': Colors.green.shade400,
          'valueToSave': 'Masalah sendi/tulang',
        },
      ],
    );
  }
}