import 'package:flutter/material.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini

class WeightMaintenanceChallengeScreen extends StatelessWidget {
  const WeightMaintenanceChallengeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseQuestionScreen(
      title: 'Apa tantangan terbesar dalam mempertahankan berat badan Anda?',
      subtitle: 'Pilih yang paling sesuai dengan situasi Anda',
      dbKey: 'weightMaintenanceChallenge', // Key di Firebase
      nextScreen: const NextPageAfterGoal(),
      screenDescription: 'WeightMaintenanceChallengeScreen',
      options: [
        {
          'title': 'Fluktuasi berat badan',
          'subtitle': 'Berat badan naik turun secara signifikan',
          'icon': Icons.auto_graph,
          'iconColor': Colors.blue.shade300,
          'valueToSave': 'Fluktuasi berat badan',
        },
        {
          'title': 'Konsistensi kebiasaan',
          'subtitle': 'Sulit mempertahankan pola makan dan olahraga',
          'icon': Icons.check_circle_outline,
          'iconColor': Colors.green.shade300,
          'valueToSave': 'Konsistensi kebiasaan',
        },
        {
          'title': 'Acara sosial dan liburan',
          'subtitle': 'Sulit menjaga pola makan saat acara khusus',
          'icon': Icons.calendar_today,
          'iconColor': Colors.amber.shade300,
          'valueToSave': 'Acara sosial dan liburan',
        },
        {
          'title': 'Perubahan metabolisme',
          'subtitle': 'Metabolisme melambat seiring bertambahnya usia',
          'icon': Icons.cached,
          'iconColor': Colors.orange.shade300,
          'valueToSave': 'Perubahan metabolisme',
        },
      ],
    );
  }
}