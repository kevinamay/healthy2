import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/health_condition_screen.dart'; // <-- Import ini ditambahkan

class EnergyLevelScreen extends StatelessWidget {
  const EnergyLevelScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Kapan Anda merasa paling kekurangan energi?',
      subtitle: 'Pilih waktu yang paling sering Anda merasa lelah',
      dbKey: 'energyDeficiencyTime', // Key di Firebase
      nextScreen: const HealthConditionScreen(), // <-- Ini diubah
      screenDescription: 'EnergyLevelScreen',
      options: [
        {
          'title': 'Pagi hari',
          'subtitle': 'Sulit bangun dan memulai hari',
          'icon': Icons.wb_sunny,
          'iconColor': Colors.amber,
          'valueToSave': 'Pagi hari',
        },
        {
          'title': 'Siang hari (setelah makan siang)',
          'subtitle': 'Mengalami penurunan energi di tengah hari',
          'icon': Icons.access_time,
          'iconColor': Colors.orange,
          'valueToSave': 'Siang hari (setelah makan siang)',
        },
        {
          'title': 'Malam hari',
          'subtitle': 'Terlalu lelah untuk aktivitas setelah kerja',
          'icon': Icons.nightlight_round,
          'iconColor': Colors.indigo,
          'valueToSave': 'Malam hari',
        },
        {
          'title': 'Sepanjang hari',
          'subtitle': 'Selalu merasa lelah dan kurang energi',
          'icon': Icons.do_not_disturb_alt,
          'iconColor': Colors.red,
          'valueToSave': 'Sepanjang hari',
        },
      ],
    );
  }
}