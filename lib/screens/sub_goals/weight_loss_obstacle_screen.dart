import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini

class WeightLossObstacleScreen extends StatelessWidget {
  const WeightLossObstacleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Apa hambatan terbesar Anda dalam menurunkan berat badan?',
      subtitle: 'Pilih yang paling sesuai dengan Anda',
      dbKey: 'weightLossObstacle', // Key di Firebase
      nextScreen: const NextPageAfterGoal(), // Ganti dengan halaman sebenarnya nanti
      screenDescription: 'WeightLossObstacleScreen',
      options: [
        {
          'title': 'Keinginan terhadap makanan tidak sehat',
          'subtitle': 'Sulit menolak makanan manis atau berlemak',
          'icon': Icons.warning_amber,
          'iconColor': Colors.red.shade300,
          'valueToSave': 'Keinginan terhadap makanan tidak sehat',
        },
        {
          'title': 'Kurangnya kekuatan atau motivasi',
          'subtitle': 'Sulit mempertahankan konsistensi',
          'icon': Icons.flash_on,
          'iconColor': Colors.blue.shade300,
          'valueToSave': 'Kurangnya kekuatan atau motivasi',
        },
        {
          'title': 'Kebiasaan makan emosional',
          'subtitle': 'Makan saat stres atau sedih',
          'icon': Icons.sentiment_dissatisfied,
          'iconColor': Colors.orange.shade300,
          'valueToSave': 'Kebiasaan makan emosional',
        },
        {
          'title': 'Plateau penurunan berat',
          'subtitle': 'Berat badan tidak turun meski sudah berusaha',
          'icon': Icons.show_chart,
          'iconColor': Colors.deepPurple.shade300,
          'valueToSave': 'Plateau penurunan berat',
        },
      ],
    );
  }
}