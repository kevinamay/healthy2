// lib/screens/diet_duration_screen.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:hitung/screens/login_screen.dart';
import 'package:hitung/screens/sub_goals/base_question_screen.dart';
import 'package:hitung/screens/personalized_plan_screen.dart'; // <-- Import halaman baru ini
import 'package:hitung/screens/diet_screen.dart'; // Untuk tombol kembali

class DietDurationScreen extends StatefulWidget {
  const DietDurationScreen({Key? key}) : super(key: key);

  @override
  State<DietDurationScreen> createState() => _DietDurationScreenState();
}

class _DietDurationScreenState extends State<DietDurationScreen> {
  String? _selectedDuration;

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final List<Map<String, dynamic>> _durationOptions = [
    {
      'id': '1_minggu',
      'title': '1 Minggu',
      'subtitle': 'Perkenalan Pola Makan',
      'tag': 'Pemula',
      'tagColor': Colors.green,
      'icon': Icons.checklist_rtl,
      'iconColor': Colors.green.shade600,
      'description': 'Fokus pada pengenalan makanan sehat dan pengurangan gula. Tidak terlalu ketat, cocok untuk adaptasi awal.',
      'difficulty': 1,
      'durationWeeks': 1, // Tambahkan ini untuk perhitungan
    },
    {
      'id': '2_minggu',
      'title': '2 Minggu',
      'subtitle': 'Penyesuaian Tubuh',
      'tag': 'Menengah',
      'tagColor': Colors.blue,
      'icon': Icons.calendar_today,
      'iconColor': Colors.blue.shade600,
      'description': 'Tahap penyesuaian tubuh dengan porsi terkontrol dan peningkatan aktivitas fisik. Siap untuk tantangan lebih?',
      'difficulty': 2,
      'durationWeeks': 2, // Tambahkan ini untuk perhitungan
    },
    {
      'id': '1_bulan',
      'title': '1 Bulan',
      'subtitle': 'Pembentukan Kebiasaan',
      'tag': 'Lanjutan',
      'tagColor': Colors.orange,
      'icon': Icons.watch_later,
      'iconColor': Colors.orange.shade600,
      'description': 'Membentuk kebiasaan hidup sehat secara permanen. Fokus pada disiplin dan konsistensi. Capai tujuan jangka panjang Anda!',
      'difficulty': 3,
      'durationWeeks': 4, // Tambahkan ini untuk perhitungan (1 bulan = 4 minggu)
    },
  ];

  Widget _buildDifficultyStars(int difficulty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Icon(
          index < difficulty ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 18,
        );
      }),
    );
  }

  Future<void> _saveDurationAndNavigate(String durationValue) async {
    print('DEBUG: DietDurationScreen - _saveDurationAndNavigate called for: $durationValue');

    User? user = _auth.currentUser;
    print('DEBUG: DietDurationScreen - Current User UID: ${user?.uid}');

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna tidak ditemukan. Harap login kembali.')),
      );
      print('DEBUG: DietDurationScreen - User is null, redirecting to login.');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
      );
      return;
    }

    try {
      print('DEBUG: DietDurationScreen - Attempting to save dietDuration: $durationValue for UID: ${user.uid}');

      // Dapatkan jumlah minggu dari opsi yang dipilih
      int? durationInWeeks;
      for(var option in _durationOptions) {
        if (option['id'] == _selectedDuration) {
          durationInWeeks = option['durationWeeks'] as int?;
          break;
        }
      }

      await _database.child('users').child(user.uid).update({
        'dietDuration': durationValue,
        'dietDurationInWeeks': durationInWeeks, // <-- Simpan durasi dalam minggu
        'dietDurationTimestamp': ServerValue.timestamp,
      });
      print('DEBUG: DietDurationScreen - Diet duration saved successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Durasi diet Anda berhasil disimpan!')),
      );

      // Navigasi ke halaman PersonalizedPlanScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PersonalizedPlanScreen()), // <-- GANTI KE SINI
      );
    } on FirebaseException catch (e) {
      print('DEBUG: DietDurationScreen - Firebase Exception: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan durasi diet (Firebase): ${e.message}')),
      );
    } catch (e) {
      print('DEBUG: DietDurationScreen - General Error saving diet duration: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan durasi diet: ${e.toString()}')),
      );
    }
  }

  Future<void> _logout() async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil logout.')),
      );
      Navigator.pushAndRemoveUntil(
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
        title: const Text('Pilih Durasi Diet'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DietScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih durasi yang sesuai dengan tujuan dan kemampuan Anda',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _durationOptions.length,
                itemBuilder: (context, index) {
                  final option = _durationOptions[index];
                  bool isSelected = _selectedDuration == option['id'];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedDuration = option['id'];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(option['icon'] as IconData, size: 30, color: option['iconColor'] as Color),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          option['title'] as String,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          option['subtitle'] as String,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: (option['tagColor'] as Color).withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    option['tag'] as String,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: option['tagColor'] as Color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline, size: 20, color: Colors.green.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    option['description'] as String,
                                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.star, size: 20, color: Colors.amber),
                                const SizedBox(width: 8),
                                Text(
                                  'Tingkat kesulitan: ',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                                _buildDifficultyStars(option['difficulty'] as int),
                                const Spacer(),
                                if (isSelected)
                                  SizedBox(
                                    height: 35,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _saveDurationAndNavigate(option['id'] as String); // Menggunakan 'id' sebagai valueToSave
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                      ),
                                      child: const Text('Pilih', style: TextStyle(fontSize: 14, color: Colors.white)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}