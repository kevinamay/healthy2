import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/health_condition_screen.dart'; // <-- Import ini ditambahkan

class AntiAgingAspectScreen extends StatelessWidget {
  const AntiAgingAspectScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Aspek anti-penuaan mana yang paling Anda prioritaskan?',
      subtitle: 'Pilih fokus utama Anda untuk umur panjang',
      dbKey: 'antiAgingAspect', // Key di Firebase
      nextScreen: const HealthConditionScreen(), // <-- Ini diubah
      screenDescription: 'AntiAgingAspectScreen',
      options: [
        {
          'title': 'Kesehatan kulit',
          'subtitle': 'Mengurangi kerutan dan meningkatkan elastisitas kulit',
          'icon': Icons.spa,
          'iconColor': Colors.pink.shade200,
          'valueToSave': 'Kesehatan kulit',
        },
        {
          'title': 'Kesehatan otak',
          'subtitle': 'Menjaga fungsi kognitif dan mencegah penurunan memori',
          'icon': Icons.lightbulb_outline,
          'iconColor': Colors.blue.shade200,
          'valueToSave': 'Kesehatan otak',
        },
        {
          'title': 'Kesehatan sendi dan tulang',
          'subtitle': 'Mempertahankan mobilitas dan kekuatan tulang',
          'icon': Icons.accessibility_new,
          'iconColor': Colors.green.shade200,
          'valueToSave': 'Kesehatan sendi dan tulang',
        },
        {
          'title': 'Kesehatan jantung',
          'subtitle': 'Menjaga sistem kardiovaskular yang kuat',
          'icon': Icons.favorite,
          'iconColor': Colors.red.shade200,
          'valueToSave': 'Kesehatan jantung',
        },
        {
          'title': 'Tingkat energi',
          'subtitle': 'Mempertahankan vitalitas dan stamina',
          'icon': Icons.flash_on,
          'iconColor': Colors.amber.shade200,
          'valueToSave': 'Tingkat energi',
        },
      ],
    );
  }
}