import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hitung/firebase_options.dart'; // Sesuaikan 'hitung' dengan nama proyek Anda
import 'package:hitung/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Tracker App',
      theme: ThemeData(
        // Skema warna dan gaya input yang konsisten dengan desain gambar
        primaryColor: const Color(0xFF6A5ACD), // Warna ungu primer
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.blue, // Tetap gunakan Colors.blue sebagai basis
        ).copyWith(
          secondary: const Color(0xFF6A5ACD), // Warna aksen juga ungu
        ),
        scaffoldBackgroundColor: Colors.white, // Latar belakang putih
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent, // AppBar transparan
          elevation: 0, // Tanpa bayangan
          iconTheme: IconThemeData(color: Colors.black), // Ikon AppBar hitam
          titleTextStyle: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100], // Background input field abu-abu muda
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none, // Tanpa border default
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF6A5ACD), width: 2), // Border fokus ungu
          ),
          hintStyle: TextStyle(color: Colors.grey[500]),
          labelStyle: TextStyle(color: Colors.grey[700]),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6A5ACD), // Warna tombol utama ungu
            foregroundColor: Colors.white, // Teks tombol putih
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF6A5ACD), // Teks tombol outline ungu
            side: const BorderSide(color: Color(0xFF6A5ACD), width: 2), // Border tombol outline ungu
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF6A5ACD), // Teks tombol teks ungu
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: const LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}