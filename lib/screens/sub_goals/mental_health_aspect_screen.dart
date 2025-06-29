import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini

class MentalHealthAspectScreen extends StatelessWidget {
  const MentalHealthAspectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Aspek kesehatan mental apa yang ingin Anda tingkatkan?',
      subtitle: 'Pilih area yang paling penting bagi Anda',
      dbKey: 'mentalHealthAspect', // Key di Firebase
      nextScreen: const NextPageAfterGoal(),
      screenDescription: 'MentalHealthAspectScreen',
      options: [
        {
          'title': 'Manajemen stres',
          'subtitle': 'Mengurangi dan mengelola stres sehari-hari',
          'icon': Icons.home,
          'iconColor': Colors.deepOrange.shade300,
          'valueToSave': 'Manajemen stres',
        },
        {
          'title': 'Kualitas tidur',
          'subtitle': 'Meningkatkan tidur untuk kesehatan mental',
          'icon': Icons.nights_stay,
          'iconColor': Colors.blue.shade300,
          'valueToSave': 'Kualitas tidur',
        },
        {
          'title': 'Fokus dan konsentrasi',
          'subtitle': 'Meningkatkan kemampuan fokus dan produktivitas',
          'icon': Icons.search,
          'iconColor': Colors.cyan.shade300,
          'valueToSave': 'Fokus dan konsentrasi',
        },
        {
          'title': 'Stabilitas suasana hati',
          'subtitle': 'Mengurangi fluktuasi mood dan meningkatkan kebahagiaan',
          'icon': Icons.tag_faces,
          'iconColor': Colors.green.shade300,
          'valueToSave': 'Stabilitas suasana hati',
        },
      ],
    );
  }
}