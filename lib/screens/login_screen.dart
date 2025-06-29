import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Firebase Auth
import 'package:hitung/screens/registration_screen.dart';
import 'package:hitung/screens/home_screen.dart';
import 'package:lottie/lottie.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;

  // Inisialisasi instance Firebase Auth
  final FirebaseAuth _auth = FirebaseAuth.instance; // <-- Tambahkan ini
  final DatabaseReference _database = FirebaseDatabase.instance.ref(); // Tetap dibutuhkan untuk data profil jika disimpan di sana

  Future<void> _loginUser() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();

      try {
        // 1. COBA LOGIN DENGAN EMAIL DAN PASSWORD MENGGUNAKAN FIREBASE AUTHENTICATION
        await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Berhasil!')),
        );
        // Navigasi ke halaman utama setelah login berhasil
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );

      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = 'Tidak ada pengguna yang ditemukan untuk email tersebut.';
        } else if (e.code == 'wrong-password') {
          message = 'Kata sandi salah untuk email tersebut.';
        } else if (e.code == 'invalid-email') {
          message = 'Format email tidak valid.';
        } else if (e.code == 'network-request-failed') {
          message = 'Tidak ada koneksi internet atau masalah jaringan.';
        }
        else {
          message = 'Login gagal: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      } catch (e) {
        print('General Error during login: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login gagal: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              Lottie.asset(
                'assets/login_thinking.json', // Path ke animasi Lottie
                height: 300, // Sesuaikan tinggi
                width: 300,  // Sesuaikan lebar
                fit: BoxFit.contain,
                repeat: true, // Animasi akan berulang
                animate: true, // Animasi akan berjalan otomatis
              ),
              const SizedBox(height: 20),
              const Text(
                'Selamat Datang Kembali!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Login ke Aplikasi Pelacak Kesehatan',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Masukkan email yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration( // Perhatikan, ini bukan 'const' lagi
                  labelText: 'Kata Sandi',
                  hintText: 'Masukkan kata sandi Anda',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton( // <-- Tambahkan suffixIcon ini
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible; // Ubah state saat ikon ditekan
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible, // <-- Gunakan state ini
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata Sandi tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    print('Lupa Kata Sandi? pressed');
                  },
                  child: const Text('Lupa Kata Sandi?'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginUser,
                  child: const Text('Login'),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: const Text('Daftar Sekarang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
