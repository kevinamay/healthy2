import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitung/screens/login_screen.dart'; // Untuk navigasi fallback
import 'package:hitung/screens/next_page_after_goal.dart'; // Halaman final setelah ini
import 'package:hitung/screens/hunger_time_screen.dart';

class MealTimeScreen extends StatefulWidget {
  const MealTimeScreen({Key? key}) : super(key: key);

  @override
  State<MealTimeScreen> createState() => _MealTimeScreenState();
}

class _MealTimeScreenState extends State<MealTimeScreen> {
  TimeOfDay _firstMealTime = TimeOfDay(hour: 12, minute: 0); // Default waktu makan pertama
  TimeOfDay _lastMealTime = TimeOfDay(hour: 22, minute: 0);  // Default waktu makan terakhir

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Fungsi untuk menampilkan Time Picker
  Future<void> _selectTime(BuildContext context, bool isFirstMeal) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isFirstMeal ? _firstMealTime : _lastMealTime,
      builder: (context, child) {
        // Gaya TimePicker agar sesuai dengan tema aplikasi (opsional)
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor, // Warna header dan tombol
              onPrimary: Colors.white, // Warna teks di header dan tombol
              onSurface: Colors.black, // Warna teks pada picker
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor, // Warna teks tombol
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != (isFirstMeal ? _firstMealTime : _lastMealTime)) {
      setState(() {
        if (isFirstMeal) {
          _firstMealTime = picked;
        } else {
          _lastMealTime = picked;
        }
      });
    }
  }

  Future<void> _saveMealTimesAndNavigate() async {
    print('DEBUG: MealTimeScreen - _saveMealTimesAndNavigate called.');

    User? user = _auth.currentUser;
    print('DEBUG: MealTimeScreen - Current User UID: ${user?.uid}');

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna tidak ditemukan. Harap login kembali.')),
      );
      print('DEBUG: MealTimeScreen - User is null, redirecting to login.');
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
      );
      return;
    }

    try {
      print('DEBUG: MealTimeScreen - Attempting to save meal times for UID: ${user.uid}');
      await _database.child('users').child(user.uid).update({
        'firstMealTime': _firstMealTime.format(context), // Simpan dalam format string
        'lastMealTime': _lastMealTime.format(context),    // Simpan dalam format string
        'mealTimeSelectionTimestamp': ServerValue.timestamp,
      });
      print('DEBUG: MealTimeScreen - Meal times saved successfully!');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Waktu makan Anda berhasil disimpan!')),
      );

      // Navigasi ke halaman selanjutnya
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HungerTimeScreen()), // Halaman final
      );
    } on FirebaseException catch (e) {
      print('DEBUG: MealTimeScreen - Firebase Exception: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan waktu makan (Firebase): ${e.message}')),
      );
    } catch (e) {
      print('DEBUG: MealTimeScreen - General Error saving meal times: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan waktu makan: ${e.toString()}')),
      );
    }
  }

  // Fungsi Logout (diulang karena merupakan halaman Stateful)
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
        title: const Text('Kebiasaan makan'),
        centerTitle: true,
        leading: IconButton( // Tombol back AppBar
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kapan waktu makan Anda?',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Makanan pertama dimulai pada',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green, // Warna hijau sesuai gambar
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _selectTime(context, true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white, // Background putih
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200, width: 2), // Border hijau
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _firstMealTime.hour.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const Text(' : ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(
                      _firstMealTime.minute.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Makanan terakhir berakhir pada',
              style: TextStyle(
                fontSize: 16,
                color: Colors.green, // Warna hijau sesuai gambar
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _selectTime(context, false),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _lastMealTime.hour.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const Text(' : ', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                    Text(
                      _lastMealTime.minute.toString().padLeft(2, '0'),
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(), // Dorong tombol ke bawah
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveMealTimesAndNavigate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Warna tombol hijau
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'BERIKUTNYA',
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}