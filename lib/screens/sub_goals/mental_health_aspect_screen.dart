import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/health_condition_screen.dart'; // <-- Import ini ditambahkan

class MentalHealthAspectScreen extends StatelessWidget {
  const MentalHealthAspectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Aspek kesehatan mental apa yang ingin Anda tingkatkan?',
      subtitle: 'Pilih area yang paling penting bagi Anda',
      dbKey: 'mentalHealthAspect', // Key di Firebase
      nextScreen: const HealthConditionScreen(), // <-- Ini diubah
      screenDescription: 'MentalHealthAspectScreen',
      options: [
        {
          'title': 'Mengurangi stres dan kecemasan',
          'subtitle': 'Mencari ketenangan dan keseimbangan emosional',
          'icon': Icons.self_improvement,
          'iconColor': Colors.purple.shade200,
          'valueToSave': 'Mengurangi stres dan kecemasan',
        },
        {
          'title': 'Meningkatkan kualitas tidur',
          'subtitle': 'Mendapatkan istirahat yang cukup dan berkualitas',
          'icon': Icons.bedtime,
          'iconColor': Colors.deepPurple.shade200,
          'valueToSave': 'Meningkatkan kualitas tidur',
        },
        {
          'title': 'Meningkatkan fokus dan konsentrasi',
          'subtitle': 'Mempertajam pikiran dan produktivitas',
          'icon': Icons.lightbulb,
          'iconColor': Colors.blue.shade200,
          'valueToSave': 'Meningkatkan fokus dan konsentrasi',
        },
        {
          'title': 'Meningkatkan mood dan kebahagiaan',
          'subtitle': 'Merasa lebih positif dan bersemangat',
          'icon': Icons.sentiment_satisfied_alt,
          'iconColor': Colors.green.shade200,
          'valueToSave': 'Meningkatkan mood dan kebahagiaan',
        },
        {
          'title': 'Mengelola emosi',
          'subtitle': 'Mengembangkan resiliensi emosional',
          'icon': Icons.psychology,
          'iconColor': Colors.orange.shade200,
          'valueToSave': 'Mengelola emosi',
        },
      ],
    );
  }
}