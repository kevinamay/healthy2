import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Untuk mendapatkan UID pengguna
import 'package:hitung/screens/login_screen.dart';
import 'package:hitung/screens/next_page_after_goal.dart'; // Akan kita buat di langkah selanjutnya

class GoalSelectionScreen extends StatefulWidget {
  const GoalSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GoalSelectionScreen> createState() => _GoalSelectionScreenState();
}

class _GoalSelectionScreenState extends State<GoalSelectionScreen> {
  String? _selectedGoal; // Variabel untuk menyimpan tujuan yang dipilih

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Daftar tujuan kesehatan
  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Menurunkan berat badan',
      'subtitle': 'Turunkan berat badan dengan cara sehat',
      'icon': Icons.scale, // Ikon timbangan
      'iconColor': Colors.pink.shade300,
    },
    {
      'title': 'Meningkatkan kesehatan metabolisme',
      'subtitle': 'Optimalkan metabolisme tubuh Anda',
      'icon': Icons.cached, // Ikon refresh/putar
      'iconColor': Colors.orange.shade300,
    },
    {
      'title': 'Dapatkan energi',
      'subtitle': 'Tingkatkan stamina dan kekuatan Anda',
      'icon': Icons.flash_on, // Ikon petir
      'iconColor': Colors.amber.shade300,
    },
    {
      'title': 'Anti-penuaan dan umur panjang',
      'subtitle': 'Jaga kesehatan dan vitalitas jangka panjang',
      'icon': Icons.star_border, // Ikon bintang (opsional, sesuaikan)
      'iconColor': Colors.lightGreen.shade300,
    },
    {
      'title': 'Mempertahankan berat badan',
      'subtitle': 'Jaga berat badan ideal Anda',
      'icon': Icons.loop, // Ikon loop
      'iconColor': Colors.blue.shade300,
    },
    {
      'title': 'Meningkatkan kesehatan mental',
      'subtitle': 'Fokus pada kesejahteraan pikiran',
      'icon': Icons.lightbulb_outline, // Ikon bohlam (opsional, sesuaikan)
      'iconColor': Colors.deepPurple.shade300,
    },
  ];

  Future<void> _saveGoalAndNavigate() async {
  print('DEBUG: _saveGoalAndNavigate called.');
  User? user = _auth.currentUser;
  print('DEBUG: Current User UID: ${user?.uid}');

  if (_selectedGoal == null) {
    print('DEBUG: No goal selected.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Silakan pilih salah satu tujuan Anda.')),
    );
    return;
  }

  if (user == null) {
    print('DEBUG: User is null, redirecting to login.');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pengguna tidak ditemukan. Harap login kembali.')),
    );
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
    return;
  }

  print('DEBUG: Attempting to save goal: $_selectedGoal for UID: ${user.uid}');
  try {
    await _database.child('users').child(user.uid).update({
      'healthGoal': _selectedGoal,
      'goalSelectionTimestamp': ServerValue.timestamp,
    });
    print('DEBUG: Goal saved successfully!'); // <-- Ini harus muncul di konsol jika berhasil
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tujuan Anda berhasil disimpan!')),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const NextPageAfterGoal()),
    );
  } on FirebaseException catch (e) { // <-- Tangkap FirebaseException spesifik
    print('DEBUG: Firebase Exception: ${e.code} - ${e.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menyimpan tujuan (Firebase): ${e.message}')),
    );
  } catch (e) {
    print('DEBUG: General Error saving goal: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal menyimpan tujuan: ${e.toString()}')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apa tujuan Anda?'),
        centerTitle: true,
        // Tombol back dihapus karena ini setelah login
        automaticallyImplyLeading: false,
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
                        color: _selectedGoal == goal['title']
                            ? Theme.of(context).primaryColor // Warna border saat terpilih
                            : Colors.transparent, // Transparan saat tidak terpilih
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedGoal = goal['title']; // Set tujuan yang dipilih
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: goal['iconColor'].withOpacity(0.2), // Warna background ikon
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                goal['icon'],
                                size: 30,
                                color: goal['iconColor'], // Warna ikon
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    goal['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    goal['subtitle'],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedGoal == goal['title'])
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor, // Ikon centang saat terpilih
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
                onPressed: _saveGoalAndNavigate, // Panggil fungsi untuk menyimpan dan navigasi
                child: const Text('BERIKUTNYA'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}