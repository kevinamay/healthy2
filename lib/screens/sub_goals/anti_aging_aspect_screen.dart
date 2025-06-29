import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini

class AntiAgingAspectScreen extends StatelessWidget {
  const AntiAgingAspectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Aspek anti-penuaan mana yang paling Anda prioritaskan?',
      subtitle: 'Pilih fokus utama Anda untuk umur panjang',
      dbKey: 'antiAgingAspect', // Key di Firebase
      nextScreen: const NextPageAfterGoal(),
      screenDescription: 'AntiAgingAspectScreen',
      options: [
        {
          'title': 'Kesehatan kulit dan penampilan',
          'subtitle': 'Menjaga kulit tetap sehat dan awet muda',
          'icon': Icons.spa,
          'iconColor': Colors.pink.shade300,
          'valueToSave': 'Kesehatan kulit dan penampilan',
        },
        {
          'title': 'Fungsi kognitif',
          'subtitle': 'Menjaga ketajaman pikiran dan memori',
          'icon': Icons.lightbulb_outline,
          'iconColor': Colors.yellow.shade700,
          'valueToSave': 'Fungsi kognitif',
        },
        {
          'title': 'Kesehatan seluler',
          'subtitle': 'Memperlambat penuaan di tingkat sel',
          'icon': Icons.science,
          'iconColor': Colors.green.shade300,
          'valueToSave': 'Kesehatan seluler',
        },
        {
          'title': 'Mobilitas dan fleksibilitas',
          'subtitle': 'Menjaga kemampuan bergerak dengan baik',
          'icon': Icons.directions_run,
          'iconColor': Colors.blue.shade300,
          'valueToSave': 'Mobilitas dan fleksibilitas',
        },
      ],
    );
  }
}