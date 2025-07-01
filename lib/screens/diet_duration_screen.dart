import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitung/screens/login_screen.dart'; // Untuk navigasi fallback
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini
import 'package:hitung/screens/diet_screen.dart'; // Untuk tombol kembali

class DietDurationScreen extends StatefulWidget {
  const DietDurationScreen({Key? key}) : super(key: key);

  @override
  State<DietDurationScreen> createState() => _DietDurationScreenState();
}

class _DietDurationScreenState extends State<DietDurationScreen> {
  String? _selectedDuration; // Durasi yang dipilih (misal: "1 Minggu", "2 Minggu", "1 Bulan")

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Data untuk setiap opsi durasi diet
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
      'difficulty': 1, // Bintang kesulitan: 1 = Rendah
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
      'difficulty': 2, // Bintang kesulitan: 2 = Sedang
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
      'difficulty': 3, // Bintang kesulitan: 3 = Tinggi
    },
  ];

  // Fungsi untuk membangun bintang kesulitan
  Widget _buildDifficultyStars(int difficulty) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return Icon(
          index < difficulty ? Icons.star : Icons.star_border,
          color: Colors.amber, // Warna bintang
          size: 18,
        );
      }),
    );
  }

  // Fungsi untuk menyimpan durasi yang dipilih dan navigasi
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
      await _database.child('users').child(user.uid).update({
        'dietDuration': durationValue,
        'dietDurationTimestamp': ServerValue.timestamp,
      });
      print('DEBUG: DietDurationScreen - Diet duration saved successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Durasi diet Anda berhasil disimpan!')),
      );

      // Navigasi ke halaman selanjutnya setelah berhasil menyimpan
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const NextPageAfterGoal()), // Halaman final
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

  // Fungsi Logout (diulang)
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
        title: const Text('Pilih Durasi Diet'), // Judul AppBar
        centerTitle: true,
        leading: IconButton( // Tombol back AppBar
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Kembali ke DietScreen
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
                  bool isSelected = _selectedDuration == option['id']; // Cek apakah opsi ini terpilih

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context).primaryColor // Warna border saat terpilih
                            : Colors.transparent, // Transparan saat tidak terpilih
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedDuration = option['id']; // Perbarui pilihan saat kartu diklik
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
                                Row( // Icon dan Judul Durasi
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
                                // Tag Pemula/Menengah/Lanjutan
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
                            // Deskripsi
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
                            // Tingkat Kesulitan
                            Row(
                              children: [
                                Icon(Icons.star, size: 20, color: Colors.amber), // Ikon bintang utama
                                const SizedBox(width: 8),
                                Text(
                                  'Tingkat kesulitan: ',
                                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                ),
                                _buildDifficultyStars(option['difficulty'] as int),
                                const Spacer(), // Dorong tombol "Pilih" ke kanan
                                // Tombol "Pilih"
                                if (isSelected) // Hanya tampilkan tombol "Pilih" jika kartu ini yang terpilih
                                  SizedBox(
                                    height: 35,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        _saveDurationAndNavigate(option['valueToSave'] ?? option['id'] as String);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green, // Warna hijau
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
            // Tidak ada tombol 'BERIKUTNYA' umum di bawah, karena 'Pilih' di dalam kartu sudah menavigasi.
            // Namun, jika Anda ingin, Anda bisa tambahkan kembali dan sesuaikan logikanya.
          ],
        ),
      ),
    );
  }
}