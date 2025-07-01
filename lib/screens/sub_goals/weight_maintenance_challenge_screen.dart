import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/health_condition_screen.dart'; // <-- Import ini ditambahkan

class WeightMaintenanceChallengeScreen extends StatelessWidget {
  const WeightMaintenanceChallengeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Apa tantangan terbesar dalam mempertahankan berat badan Anda?',
      subtitle: 'Pilih yang paling sesuai dengan situasi Anda',
      dbKey: 'weightMaintenanceChallenge', // Key di Firebase
      nextScreen: const HealthConditionScreen(), // <-- Ini diubah
      screenDescription: 'WeightMaintenanceChallengeScreen',
      options: [
        {
          'title': 'Godaan makanan',
          'subtitle': 'Sulit menahan diri dari makanan tidak sehat',
          'icon': Icons.cake,
          'iconColor': Colors.pink.shade300,
          'valueToSave': 'Godaan makanan',
        },
        {
          'title': 'Kurangnya aktivitas fisik',
          'subtitle': 'Jarang berolahraga atau bergerak aktif',
          'icon': Icons.directions_run,
          'iconColor': Colors.green.shade300,
          'valueToSave': 'Kurangnya aktivitas fisik',
        },
        {
          'title': 'Perubahan gaya hidup',
          'subtitle': 'Perjalanan, pekerjaan baru, atau perubahan rutin',
          'icon': Icons.work,
          'iconColor': Colors.blueGrey.shade300,
          'valueToSave': 'Perubahan gaya hidup',
        },
        {
          'title': 'Fluktuasi hormonal',
          'subtitle': 'Perubahan berat badan karena hormon',
          'icon': Icons.science,
          'iconColor': Colors.purple.shade300,
          'valueToSave': 'Fluktuasi hormonal',
        },
        {
          'title': 'Lingkungan sosial',
          'subtitle': 'Tekanan dari teman/keluarga untuk makan berlebihan',
          'icon': Icons.people,
          'iconColor': Colors.teal.shade300,
          'valueToSave': 'Lingkungan sosial',
        },
      ],
    );
  }
}