import 'package:flutter/material.dart';
import 'package:hitung/screens/goal_selection_screen.dart'; // Import halaman tujuan

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Setelah 2 detik, navigasi ke GoalSelectionScreen
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        // --- GANTI BAGIAN INI ---
        MaterialPageRoute(builder: (context) => GoalSelectionScreen()), // Hapus 'const' di sini
        // --- AKHIR GANTI BAGIAN INI ---
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Kesehatan'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.health_and_safety, size: 80, color: Color(0xFF6A5ACD)),
              SizedBox(height: 20),
              Text(
                'Memuat Aplikasi...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 10),
              CircularProgressIndicator(), // Indikator loading
            ],
          ),
        ),
      ),
    );
  }
}