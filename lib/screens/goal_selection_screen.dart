import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitung/screens/login_screen.dart';
import 'package:hitung/screens/next_page_after_goal.dart';
import 'package:hitung/screens/sub_goals/weight_loss_obstacle_screen.dart';
import 'package:hitung/screens/sub_goals/metabolism_improvement_screen.dart';
import 'package:hitung/screens/sub_goals/energy_level_screen.dart';
import 'package:hitung/screens/sub_goals/anti_aging_aspect_screen.dart';
import 'package:hitung/screens/sub_goals/weight_maintenance_challenge_screen.dart';
import 'package:hitung/screens/sub_goals/mental_health_aspect_screen.dart';


class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Menurunkan berat badan',
      'subtitle': 'Turunkan berat badan dengan cara sehat',
      'icon': Icons.scale,
      'iconColor': Colors.pink.shade300,
      'valueToSave': 'Menurunkan berat badan',
      'nextPage': const WeightLossObstacleScreen(),
    },
    {
      'title': 'Meningkatkan kesehatan metabolisme',
      'subtitle': 'Optimalkan metabolisme tubuh Anda',
      'icon': Icons.cached,
      'iconColor': Colors.orange.shade300,
      'valueToSave': 'Meningkatkan kesehatan metabolisme',
      'nextPage': const MetabolismImprovementScreen(),
    },
    {
      'title': 'Dapatkan energi',
      'subtitle': 'Tingkatkan stamina dan kekuatan Anda',
      'icon': Icons.flash_on,
      'iconColor': Colors.amber.shade300,
      'valueToSave': 'Dapatkan energi',
      'nextPage': const EnergyLevelScreen(),
    },
    {
      'title': 'Anti-penuaan dan umur panjang',
      'subtitle': 'Jaga kesehatan dan vitalitas jangka panjang',
      'icon': Icons.star_border,
      'iconColor': Colors.lightGreen.shade300,
      'valueToSave': 'Anti-penuaan dan umur panjang',
      'nextPage': const AntiAgingAspectScreen(),
    },
    {
      'title': 'Mempertahankan berat badan',
      'subtitle': 'Jaga berat badan ideal Anda',
      'icon': Icons.loop,
      'iconColor': Colors.blue.shade300,
      'valueToSave': 'Mempertahankan berat badan',
      'nextPage': const WeightMaintenanceChallengeScreen(),
    },
    {
      'title': 'Meningkatkan kesehatan mental',
      'subtitle': 'Fokus pada kesejahteraan pikiran',
      'icon': Icons.lightbulb_outline,
      'iconColor': Colors.deepPurple.shade300,
      'valueToSave': 'Meningkatkan kesehatan mental',
      'nextPage': const MentalHealthAspectScreen(),
    },
  ];

  Future<void> _saveGoalAndNavigate() async {
    print('DEBUG: GoalSelectionScreen - _saveGoalAndNavigate called.');

    if (_selectedGoal == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih salah satu tujuan Anda.')),
      );
      print('DEBUG: GoalSelectionScreen - No goal selected.');
      return;
    }

    User? user = _auth.currentUser;
    print('DEBUG: GoalSelectionScreen - Current User UID: ${user?.uid}');

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna tidak ditemukan. Harap login kembali.')),
      );
      print('DEBUG: GoalSelectionScreen - User is null, redirecting to login.');
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
      return;
    }

    try {
      print('DEBUG: GoalSelectionScreen - Attempting to save healthGoal: $_selectedGoal for UID: ${user.uid}');
      await _database.child('users').child(user.uid).update({
        'healthGoal': _selectedGoal,
        'goalSelectionTimestamp': ServerValue.timestamp,
      });
      print('DEBUG: GoalSelectionScreen - Data saved successfully for healthGoal!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tujuan Anda berhasil disimpan!')),
      );

      Widget? nextPageWidget;
      for (var goal in _goals) {
        if (goal['valueToSave'] == _selectedGoal) {
          nextPageWidget = goal['nextPage'] as Widget?;
          break;
        }
      }

      if (nextPageWidget != null) {
        print('DEBUG: GoalSelectionScreen - Navigating to ${nextPageWidget.runtimeType}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPageWidget!),
        );
      } else {
        print('DEBUG: GoalSelectionScreen - No specific next page found. Navigating to default.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const NextPageAfterGoal()),
        );
      }

    } on FirebaseException catch (e) {
      print('DEBUG: GoalSelectionScreen - Firebase Exception: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan tujuan (Firebase): ${e.message}')),
      );
    } catch (e) {
      print('DEBUG: GoalSelectionScreen - General Error saving goal: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan tujuan: ${e.toString()}')),
      );
    }
  }

  // Fungsi Logout
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil logout.')),
      );
      Navigator.pushAndRemoveUntil( // Kembali ke LoginScreen dan hapus semua rute sebelumnya
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      print('Error during logout: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal logout: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apa tujuan Anda?'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        // --- TAMBAHKAN TOMBOL LOGOUT INI ---
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
        // --- AKHIR TAMBAHAN TOMBOL LOGOUT ---
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih tujuan utama Anda untuk pengalaman yang dipersonalisasi',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _goals.length,
                itemBuilder: (context, index) {
                  final goal = _goals[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _selectedGoal == goal['valueToSave']
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedGoal = goal['valueToSave'];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (goal['iconColor'] as Color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                goal['icon'] as IconData,
                                size: 30,
                                color: goal['iconColor'] as Color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    goal['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedGoal == goal['valueToSave'])
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
                                size: 24,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveGoalAndNavigate,
                child: const Text('BERIKUTNYA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}