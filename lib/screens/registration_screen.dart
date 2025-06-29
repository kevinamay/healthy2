import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart'; // Tetap dibutuhkan untuk data profil tambahan
import 'package:firebase_auth/firebase_auth.dart'; // <-- Import Firebase Auth
import 'package:hitung/screens/login_screen.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _targetWeightController = TextEditingController();

  String? _selectedGender;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Inisialisasi instance Firebase Auth dan Realtime Database
  final FirebaseAuth _auth = FirebaseAuth.instance; // <-- Tambahkan ini
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  Future<void> _registerUser() async {
    if (_formKey.currentState!.validate()) {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String confirmPassword = _confirmPasswordController.text.trim();
      final String fullName = _fullNameController.text.trim();
      final int? age = int.tryParse(_ageController.text.trim());
      final String? gender = _selectedGender;
      final double? weight = double.tryParse(_weightController.text.trim());
      final double? height = double.tryParse(_heightController.text.trim());
      final double? targetWeight = double.tryParse(_targetWeightController.text.trim());

      if (password != confirmPassword) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password dan Konfirmasi Password tidak cocok!')),
        );
        return;
      }

      if (gender == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Silakan pilih jenis kelamin.')),
        );
        return;
      }

      if (age == null || weight == null || height == null || targetWeight == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pastikan semua data numerik terisi dengan benar.')),
        );
        return;
      }

      try {
        // 1. DAFTARKAN PENGGUNA DENGAN EMAIL DAN PASSWORD MENGGUNAKAN FIREBASE AUTHENTICATION
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Dapatkan UID pengguna yang baru terdaftar
        String? uid = userCredential.user?.uid;

        if (uid != null) {
          // 2. SIMPAN DATA PROFIL TAMBAHAN KE REALTIME DATABASE MENGGUNAKAN UID SEBAGAI KUNCI
          await _database.child('users').child(uid).set({ // Menggunakan UID sebagai kunci unik
            'email': email,
            // 'password': password, // JANGAN simpan password di Realtime Database!
            'fullName': fullName,
            'age': age,
            'gender': gender,
            'weight': weight,
            'height': height,
            'targetWeight': targetWeight,
            'timestamp': ServerValue.timestamp,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi berhasil! Silakan login.')),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registrasi gagal: UID tidak ditemukan.')),
          );
        }

      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'weak-password') {
          message = 'Kata sandi terlalu lemah.';
        } else if (e.code == 'email-already-in-use') {
          message = 'Akun dengan email ini sudah ada.';
        } else {
          message = 'Terjadi kesalahan otentikasi: ${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        print('Firebase Auth Error: ${e.code} - ${e.message}');
      } catch (e) {
        print('General Error during registration: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registrasi gagal: ${e.toString()}')),
        );
      }
    }
  }

  // ... sisa widget build() tetap sama ...
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text('Daftar Akun Baru'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  hintText: 'Masukkan email Anda',
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
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  hintText: 'Buat kata sandi',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Kata Sandi tidak boleh kosong';
                  }
                  if (value.length < 6) {
                    return 'Kata Sandi minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Konfirmasi Kata Sandi',
                  hintText: 'Konfirmasi kata sandi',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Theme.of(context).primaryColorDark,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),
                obscureText: !_isConfirmPasswordVisible,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Konfirmasi Kata Sandi tidak boleh kosong';
                  }
                  if (value != _passwordController.text) {
                    return 'Kata Sandi tidak cocok';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  hintText: 'Masukkan nama lengkap',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama lengkap tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(
                  labelText: 'Usia',
                  hintText: 'Masukkan usia Anda',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Usia tidak boleh kosong';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return 'Usia tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text('Jenis Kelamin', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700])),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Pria'),
                      value: 'Pria',
                      groupValue: _selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Wanita'),
                      value: 'Wanita',
                      groupValue: _selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Lainnya'),
                      value: 'Lainnya',
                      groupValue: _selectedGender,
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGender = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg)',
                  hintText: 'Masukkan berat badan',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Berat badan tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Berat badan tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _heightController,
                decoration: const InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                  hintText: 'Masukkan tinggi badan',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tinggi badan tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Tinggi badan tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _targetWeightController,
                decoration: const InputDecoration(
                  labelText: 'Target Berat Badan (kg)',
                  hintText: 'Masukkan target berat badan',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Target berat badan tidak boleh kosong';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Target berat badan tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerUser,
                  child: const Text('Daftar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}