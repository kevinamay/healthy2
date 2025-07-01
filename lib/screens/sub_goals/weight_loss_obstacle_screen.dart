import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/health_condition_screen.dart'; // <-- Import ini ditambahkan

class WeightLossObstacleScreen extends StatelessWidget {
  const WeightLossObstacleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Apa hambatan terbesar Anda dalam menurunkan berat badan?',
      subtitle: 'Pilih yang paling sesuai dengan Anda',
      dbKey: 'weightLossObstacle', // Key di Firebase
      nextScreen: const HealthConditionScreen(), // <-- Ini diubah
      screenDescription: 'WeightLossObstacleScreen',
      options: [
        {
          'title': 'Kurangnya motivasi',
          'subtitle': 'Sulit konsisten dalam diet dan olahraga',
          'icon': Icons.trending_down,
          'iconColor': Colors.red.shade300,
          'valueToSave': 'Kurangnya motivasi',
        },
        {
          'title': 'Pola makan tidak sehat',
          'subtitle': 'Sering ngemil atau makan berlebihan',
          'icon': Icons.cookie,
          'iconColor': Colors.orange.shade300,
          'valueToSave': 'Pola makan tidak sehat',
        },
        {
          'title': 'Kurangnya waktu',
          'subtitle': 'Sibuk dengan pekerjaan/aktivitas lain',
          'icon': Icons.timer_off,
          'iconColor': Colors.blueGrey.shade300,
          'valueToSave': 'Kurangnya waktu',
        },
        {
          'title': 'Kondisi medis',
          'subtitle': 'Memiliki masalah kesehatan yang memengaruhi berat badan',
          'icon': Icons.medical_services,
          'iconColor': Colors.lightBlue.shade300,
          'valueToSave': 'Kondisi medis',
        },
        {
          'title': 'Stres atau emosi',
          'subtitle': 'Makan berlebihan saat stres atau sedih',
          'icon': Icons.sentiment_dissatisfied,
          'iconColor': Colors.purple.shade300,
          'valueToSave': 'Stres atau emosi',
        },
      ],
    );
  }
}