import 'package:flutter/material.dart';

class NextPageAfterGoal extends StatelessWidget {
  const NextPageAfterGoal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Halaman Selanjutnya'),
        automaticallyImplyLeading: false, // Menghilangkan tombol back
      ),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline, size: 80, color: Colors.green),
              SizedBox(height: 20),
              Text(
                'Selamat! Konfigurasi Awal Selesai.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 10),
              Text(
                'Anda telah memilih tujuan kesehatan Anda. Sekarang Anda bisa melanjutkan dengan fitur utama aplikasi.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              // Di sini Anda bisa menambahkan tombol untuk ke dashboard utama atau fitur lain
            ],
          ),
        ),
      ),
    );
  }
}