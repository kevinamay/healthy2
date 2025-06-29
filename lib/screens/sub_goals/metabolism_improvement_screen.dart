import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini

class MetabolismImprovementScreen extends StatelessWidget {
  const MetabolismImprovementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Bagaimana pola makan Anda saat ini?',
      subtitle: 'Pilih yang paling menggambarkan kebiasaan Anda',
      dbKey: 'currentDietPattern', // Key di Firebase
      nextScreen: const NextPageAfterGoal(),
      screenDescription: 'MetabolismImprovementScreen',
      options: [
        {
          'title': 'Jadwal makan tidak teratur',
          'subtitle': 'Sering melewatkan waktu makan atau makan larut malam',
          'icon': Icons.access_time,
          'iconColor': Colors.orange,
          'valueToSave': 'Jadwal makan tidak teratur',
        },
        {
          'title': 'Banyak makanan olahan',
          'subtitle': 'Sering mengonsumsi makanan cepat saji atau kemasan',
          'icon': Icons.warning_amber,
          'iconColor': Colors.red,
          'valueToSave': 'Banyak makanan olahan',
        },
        {
          'title': 'Cukup seimbang',
          'subtitle': 'Berusaha makan teratur dengan makanan sehat',
          'icon': Icons.check_circle,
          'iconColor': Colors.green,
          'valueToSave': 'Cukup seimbang',
        },
        {
          'title': 'Pola makan terbatas',
          'subtitle': 'Sering diet ketat atau puasa',
          'icon': Icons.block,
          'iconColor': Colors.blue,
          'valueToSave': 'Pola makan terbatas',
        },
      ],
    );
  }
}