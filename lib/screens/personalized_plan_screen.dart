import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:hitung/screens/login_screen.dart';
import 'dart:math';

class PersonalizedPlanScreen extends StatefulWidget {
  const PersonalizedPlanScreen({Key? key}) : super(key: key);

  @override
  State<PersonalizedPlanScreen> createState() => _PersonalizedPlanScreenState();
}

class _PersonalizedPlanScreenState extends State<PersonalizedPlanScreen> {
  User? _currentUser;
  Map<String, dynamic>? _userFirestoreData;
  Map<String, dynamic>? _userRealtimeData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser == null) {
      _errorMessage = 'Pengguna tidak login. Harap login kembali.';
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _redirectToLogin();
      });
    } else {
      _fetchUserData();
    }
  }

  void _redirectToLogin() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (Route<dynamic> route) => false,
    );
  }

  Future<void> _fetchUserData() async {
    try {
      // Fetch from Firestore (for profile data)
      DocumentSnapshot firestoreDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (firestoreDoc.exists) {
        _userFirestoreData = firestoreDoc.data() as Map<String, dynamic>; // Firestore sudah Map<String, dynamic>
      } else {
        _errorMessage = 'Data profil tidak ditemukan di Firestore.';
      }

      // Fetch from Realtime Database (for onboarding answers)
      DatabaseEvent rtEvent = await FirebaseDatabase.instance
          .ref()
          .child('users')
          .child(_currentUser!.uid)
          .once();

      if (rtEvent.snapshot.exists) {
        // --- PERBAIKAN DI SINI ---
        // Cara 1: Cast sebagai dynamic, lalu iterasi dengan key String
        // _userRealtimeData = Map<String, dynamic>.from(rtEvent.snapshot.value as Map);

        // Cara 2 (lebih umum dan aman jika kita yakin strukturnya Map<String, dynamic>):
        _userRealtimeData = (rtEvent.snapshot.value as Map<dynamic, dynamic>).cast<String, dynamic>();
        // --- AKHIR PERBAIKAN ---

      } else {
        _errorMessage += '\nData onboarding tidak ditemukan di Realtime Database.';
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data: ${e.toString()}';
        _isLoading = false;
      });
      print('Error fetching user data: $e');
    }
  }

  // --- Logika Perhitungan & Rekomendasi ---
  double calculateBMR() {
    if (_userFirestoreData == null ||
        _userFirestoreData!['weight'] == null ||
        _userFirestoreData!['height'] == null ||
        _userFirestoreData!['age'] == null ||
        _userFirestoreData!['gender'] == null) {
      return 0.0;
    }

    double weight = (_userFirestoreData!['weight'] as num).toDouble();
    double height = (_userFirestoreData!['height'] as num).toDouble();
    int age = (_userFirestoreData!['age'] as num).toInt();
    String gender = _userFirestoreData!['gender'] as String;

    // Menggunakan rumus Mifflin-St Jeor (lebih akurat dari Harris-Benedict)
    if (gender == 'Pria') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
  }

  double calculateTDEE(double bmr) {
    // Asumsi level aktivitas: Sedentary (sedikit atau tanpa olahraga)
    // Untuk aplikasi yang lebih kompleks, bisa tambahkan pertanyaan level aktivitas
    return bmr * 1.2; // Sedentary (little or no exercise)
  }

  Map<String, dynamic> getDietPlanDetails() {
    String? healthGoal = _userRealtimeData?['healthGoal'];
    String? currentDiet = _userRealtimeData?['currentDiet']; // Diet yang diikuti
    String? weightLossObstacle = _userRealtimeData?['weightLossObstacle']; // Hambatan BB
    String? dietDuration = _userRealtimeData?['dietDuration']; // Durasi diet
    int? dietDurationInWeeks = (_userRealtimeData?['dietDurationInWeeks'] as num?)?.toInt() ?? 0;

    String recommendedDietType = 'Diet Normal Seimbang';
    String dietDescription = 'Fokus pada asupan nutrisi lengkap, porsi terkontrol, dan keberlanjutan jangka panjang.';
    List<Map<String, String>> dietFocusPoints = [
      {'icon': '🍎', 'text': 'Variasi Makanan: Konsumsi beragam buah, sayur, protein tanpa lemak, dan biji-bijian.'},
      {'icon': '💧', 'text': 'Hidrasi Cukup: Minum air yang cukup sepanjang hari.'},
      {'icon': '🚫', 'text': 'Batasi Gula & Olahan: Kurangi asupan gula tambahan dan makanan ultra-proses.'},
    ];

    List<Map<String, dynamic>> recommendedFoods = [];
    List<Map<String, dynamic>> recommendedExercises = [];

    if (healthGoal == 'Menurunkan berat badan') {
      recommendedDietType = 'Diet Rendah Karbohidrat';
      dietDescription = 'Diet rendah karbohidrat berfokus pada pengurangan asupan karbohidrat dan peningkatan konsumsi protein serta lemak sehat. Pendekatan ini membantu tubuh Anda beralih ke pembakaran lemak sebagai sumber energi utama, yang dapat mempercepat proses penurunan berat badan.';
      dietFocusPoints = [
        {'icon': '🍞', 'text': 'Batasi Karbohidrat: Batasi asupan karbohidrat hingga 100-150g per hari untuk hasil optimal'},
        {'icon': '🍗', 'text': 'Fokus Protein: Tingkatkan asupan protein dan lemak sehat untuk energi dan massa otot'},
        {'icon': '🍬', 'text': 'Hindari Olahan: Hindari makanan olahan dan gula tambahan yang dapat menghambat progres'},
      ];
      recommendedFoods = [
        {'category': 'Protein', 'items': ['Dada Ayam', 'Ikan Salmon', 'Telur', 'Tahu & Tempe']},
        {'category': 'Karbohidrat', 'items': ['Nasi Merah', 'Ubi', 'Quinoa', 'Oatmeal']},
        {'category': 'Lemak Sehat', 'items': ['Alpukat', 'Minyak Zaitun', 'Kacang-kacangan', 'Biji Chia']},
        {'category': 'Sayuran', 'items': ['Brokoli', 'Bayam', 'Kale', 'Paprika']},
      ];
      recommendedExercises = [
        {'type': 'Kardio Ringan', 'duration': '30 menit, 3x seminggu', 'description': 'Jalan cepat, bersepeda santai, atau berenang dapat membantu membakar kalori dan meningkatkan kesehatan jantung.', 'info': 'Mulai dengan 15 menit dan tingkatkan secara bertahap'},
        {'type': 'Latihan Kekuatan', 'duration': '20 menit, 2x seminggu', 'description': 'Angkat beban ringan atau latihan dengan berat badan sendiri untuk membangun massa otot dan meningkatkan metabolisme.', 'info': 'Fokus pada latihan yang melibatkan banyak kelompok otot'},
      ];
    } else if (healthGoal == 'Meningkatkan kesehatan metabolisme') {
      recommendedDietType = 'Diet Seimbang & Teratur';
      dietDescription = 'Fokus pada konsistensi waktu makan dan kualitas nutrisi untuk mengoptimalkan fungsi metabolisme tubuh Anda.';
      dietFocusPoints = [
        {'icon': '⏰', 'text': 'Waktu Makan Teratur: Patuhi jadwal makan yang konsisten untuk menstabilkan gula darah.'},
        {'icon': '🥗', 'text': 'Makronutrien Seimbang: Pastikan asupan protein, lemak, dan karbohidrat kompleks seimbang.'},
        {'icon': '🥕', 'text': 'Serat Tinggi: Konsumsi banyak serat dari buah, sayur, dan biji-bijian.'},
      ];
      recommendedFoods = [
        {'category': 'Protein', 'items': ['Dada Ayam', 'Telur', 'Ikan', 'Kacang-kacangan']},
        {'category': 'Karbohidrat Kompleks', 'items': ['Nasi Merah', 'Ubi', 'Oatmeal', 'Roti Gandum Utuh']},
        {'category': 'Lemak Sehat', 'items': ['Alpukat', 'Minyak Zaitun', 'Kacang-kacangan', 'Biji-bijian']},
        {'category': 'Sayuran & Buah', 'items': ['Brokoli', 'Bayam', 'Apel', 'Berry']},
      ];
      recommendedExercises = [
        {'type': 'HIIT', 'duration': '10-15 menit, 1-2x seminggu', 'description': 'Latihan intensitas tinggi singkat yang efektif membakar kalori dan meningkatkan metabolisme hingga 24 jam setelah latihan.', 'info': 'Mulai dengan intensitas rendah dan tingkatkan secara bertahap'},
        {'type': 'Latihan Kekuatan', 'duration': '30 menit, 3x seminggu', 'description': 'Membangun massa otot meningkatkan BMR (Basal Metabolic Rate) Anda, yang berarti Anda membakar lebih banyak kalori saat istirahat.', 'info': 'Fokus pada progresif overload'},
      ];
    }
    // ... Tambahkan kondisi untuk tujuan lain jika diperlukan
    // Anda bisa mengadaptasi rekomendasi berdasarkan 'currentDiet', 'healthCondition', dll.

    // Jika diet yang diikuti pengguna saat ini adalah diet populer, bisa disorot
    if (currentDiet != null && currentDiet != 'Tidak ada') {
      if (currentDiet == 'Diet Keto' && healthGoal == 'Menurunkan berat badan') {
        dietDescription = 'Karena Anda sudah mengikuti Diet Keto, rencana ini akan mengoptimalkan asupan lemak dan protein untuk menjaga tubuh dalam kondisi ketosis demi penurunan berat badan yang efektif.';
        dietFocusPoints.insert(0, {'icon': '🥑', 'text': 'Pertahankan Ketosis: Jaga asupan karbohidrat sangat rendah (<50g/hari) untuk membakar lemak.'});
      }
    }


    return {
      'recommendedDietType': recommendedDietType,
      'dietDescription': dietDescription,
      'dietFocusPoints': dietFocusPoints,
      'recommendedFoods': recommendedFoods.isEmpty ? [
        {'category': 'Protein', 'items': ['Dada Ayam', 'Telur', 'Ikan', 'Kacang-kacangan']},
        {'category': 'Karbohidrat', 'items': ['Nasi Merah', 'Ubi', 'Roti Gandum']},
        {'category': 'Lemak Sehat', 'items': ['Alpukat', 'Minyak Zaitun']},
        {'category': 'Sayuran', 'items': ['Semua Jenis Sayuran']},
      ] : recommendedFoods,
      'recommendedExercises': recommendedExercises.isEmpty ? [
        {'type': 'Jalan Kaki', 'duration': '30 menit, 5x seminggu', 'description': 'Aktivitas dasar untuk kebugaran umum.', 'info': 'Baik untuk kesehatan jantung'},
      ] : recommendedExercises,
      'estimatedDurationWeeks': dietDurationInWeeks ?? 12,
    };
  }

  // Fungsi Logout
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
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
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Menyesuaikan Rencana Anda'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Memuat rencana personal Anda...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _logout,
            ),
          ],
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ),
      );
    }

    // Pastikan semua data ada sebelum mencoba mengaksesnya
    if (_userFirestoreData == null || _userRealtimeData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error Data')),
        body: const Center(child: Text('Data pengguna tidak lengkap.')),
      );
    }

    // Ambil data untuk tampilan ringkasan
    int age = (_userFirestoreData!['age'] as num?)?.toInt() ?? 0;
    double initialWeight = (_userFirestoreData!['weight'] as num?)?.toDouble() ?? 0.0;
    double height = (_userFirestoreData!['height'] as num?)?.toDouble() ?? 0.0;
    double targetWeight = (_userFirestoreData!['targetWeight'] as num?)?.toDouble() ?? 0.0;

    String healthGoal = _userRealtimeData?['healthGoal'] as String? ?? 'Tidak diketahui';
    String dietDuration = _userRealtimeData?['dietDuration'] as String? ?? 'Tidak ditentukan';
    int dietDurationInWeeks = (_userRealtimeData?['dietDurationInWeeks'] as num?)?.toInt() ?? 0;


    // Perhitungan Kalori dan Penurunan Berat Badan
    double bmr = calculateBMR();
    double tdee = calculateTDEE(bmr);
    double targetCalorieIntake = tdee; // Akan disesuaikan jika tujuan adalah penurunan BB

    double weightToLoseKg = max(0, initialWeight - targetWeight); // Pastikan tidak negatif
    double weeklyWeightLossKg = 0.5; // Target penurunan 0.5 kg/minggu (sehat)
    double calorieDeficitPerDay = 500; // Defisit 500 kalori/hari untuk 0.5 kg/minggu

    // Hanya jika tujuan adalah menurunkan berat badan, sesuaikan target kalori
    if (healthGoal == 'Menurunkan berat badan' && weightToLoseKg > 0) {
      targetCalorieIntake = tdee - calorieDeficitPerDay;
      // Pastikan target kalori tidak terlalu rendah (misal: min 1200 untuk wanita, 1500 untuk pria)
      if (targetCalorieIntake < 1200) targetCalorieIntake = 1200; // Contoh batas bawah
    }

    // Perkiraan waktu mencapai target
    String estimatedTargetTime = 'Belum ditentukan';
    if (weightToLoseKg > 0 && weeklyWeightLossKg > 0) {
        int estimatedWeeks = (weightToLoseKg / weeklyWeightLossKg).ceil();
        estimatedTargetTime = '$estimatedWeeks minggu';
    } else if (healthGoal == 'Menurunkan berat badan' && dietDurationInWeeks > 0) {
      estimatedTargetTime = '$dietDurationInWeeks minggu';
    }


    // Dapatkan detail rencana diet dan makanan/olahraga
    Map<String, dynamic> dietPlan = getDietPlanDetails();
    String recommendedDietType = dietPlan['recommendedDietType'];
    String dietDescription = dietPlan['dietDescription'];
    List<Map<String, String>> dietFocusPoints = dietPlan['dietFocusPoints'];
    List<Map<String, dynamic>> recommendedFoods = dietPlan['recommendedFoods'];
    List<Map<String, dynamic>> recommendedExercises = dietPlan['recommendedExercises'];


    return Scaffold(
      appBar: AppBar(
        title: const Text('Menyesuaikan Rencana Anda'),
        centerTitle: true,
        automaticallyImplyLeading: false, // Halaman utama, tidak ada tombol back
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Bagian "Rencana diet Anda berhasil dibuat!"
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Rencana diet Anda berhasil dibuat!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Baru',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Berikut adalah ringkasan data Anda untuk mencapai target:',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 1.8, // Sesuaikan rasio aspek kartu
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildDataCard('Umur', '$age tahun', Icons.watch_later_outlined),
                        _buildDataCard('Berat Awal', '$initialWeight kilogram', Icons.fitness_center),
                        _buildDataCard('Tinggi', '$height centimeter', Icons.height),
                        _buildDataCard('Berat Target', '$targetWeight kilogram', Icons.flag),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bagian "Evaluasi Rencana Anda"
            const Text(
              'Evaluasi Rencana Anda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Target penurunan berat badan:',
                          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        Text(
                          '$weightToLoseKg kg',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: weightToLoseKg > 0 ? (initialWeight - weightToLoseKg) / initialWeight : 0, // Contoh progress
                      backgroundColor: Colors.grey.shade300,
                      color: Theme.of(context).primaryColor,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Mulai', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('Dalam Proses', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('Target', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.access_time, size: 24, color: Theme.of(context).primaryColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Berdasarkan data Anda, kami memperkirakan Anda dapat mencapai target dalam:',
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                              ),
                              Text(
                                estimatedTargetTime,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Dengan penurunan berat badan yang sehat',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 24, color: Colors.blue.shade400),
                        const SizedBox(width: 12),
                        Text(
                          'Penurunan berat badan sehat: ${weeklyWeightLossKg.toStringAsFixed(1)} kg/minggu',
                          style: TextStyle(fontSize: 14, color: Colors.blue.shade600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bagian "Kebutuhan Kalori Harian"
            const Text(
              'Kebutuhan Kalori Harian',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
// Bagian "Kebutuhan Kalori Harian"
            // ... (kode di atasnya)
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          SizedBox(
                            width: 150,
                            height: 150,
                            child: CircularProgressIndicator(
                              value: (targetCalorieIntake / 2500).clamp(0.0, 1.0),
                              strokeWidth: 10,
                              backgroundColor: Colors.grey.shade200,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Kebutuhan Harian',
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                              ),
                              Text(
                                '${targetCalorieIntake.round()} kalori',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      // --- PERBAIKAN DI SINI ---
                      // Ubah childAspectRatio menjadi nilai yang lebih besar (misal: dari 2.5 menjadi 1.5 atau 1.4)
                      childAspectRatio: 1.4, // Coba nilai ini terlebih dahulu
                      // --- AKHIR PERBAIKAN ---
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildMacroCard('Protein', '90g', Icons.egg),
                        _buildMacroCard('Karbohidrat', '180g', Icons.rice_bowl),
                        _buildMacroCard('Lemak', '60g', Icons.oil_barrel),
                        _buildMacroCard('Air', '2L', Icons.water_drop),
                      ],
                    ),
                    // ... (kode di bawahnya)
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, size: 20, color: Colors.blue.shade400),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Kebutuhan kalori ini disesuaikan dengan target ${healthGoal.toLowerCase()} Anda.',
                            style: TextStyle(fontSize: 12, color: Colors.blue.shade600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bagian "Jenis Diet yang Cocok untuk Anda" (sudah ada di atas, mungkin ini ringkasan)
            // Menggunakan struktur yang sama dengan gambar
            // Bagian ini sudah di pindah ke bagian di atas agar sesuai urutan gambar
            // Bagian "Makanan yang Dianjurkan"
            const Text(
              'Makanan yang Dianjurkan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recommendedFoods.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final foodCategory = recommendedFoods[index];
                    return Card(
                      color: Colors.blue.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.shopping_cart, size: 20, color: Colors.blue.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    foodCategory['category'] as String,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: (foodCategory['items'] as List<String>).length,
                                itemBuilder: (context, itemIndex) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Text(
                                      '• ${(foodCategory['items'] as List<String>)[itemIndex]}',
                                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Bagian "Olahraga yang Dianjurkan"
            const Text(
              'Olahraga yang Dianjurkan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              margin: const EdgeInsets.only(bottom: 24),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recommendedExercises.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.9,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemBuilder: (context, index) {
                    final exercise = recommendedExercises[index];
                    return Card(
                      color: Colors.blue.shade50,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.flash_on, size: 24, color: Colors.blue.shade600), // Ganti ikon sesuai jenis olahraga
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    exercise['type'] as String,
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue.shade800),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              exercise['duration'] as String,
                              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: Text(
                                exercise['description'] as String,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.info_outline, size: 16, color: Colors.blue.shade400),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    exercise['info'] as String,
                                    style: TextStyle(fontSize: 11, color: Colors.blue.shade600),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            // Bagian "Tetap Konsisten & Pantau Kemajuan Anda" (Dipindahkan ke paling bawah)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).primaryColor.withOpacity(0.8), Theme.of(context).primaryColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text(
                    'Tetap Konsisten & Pantau Kemajuan Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Perjalanan diet adalah proses, bukan tujuan. Tetap fokus pada kebiasaan sehat dan perubahan kecil setiap hari akan membawa Anda menuju hasil yang diinginkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      print('Mulai Perjalanan Anda ditekan');
                      // TODO: Navigasi ke halaman utama/dashboard aplikasi sebenarnya
                      // Ini bisa menjadi pop semua rute hingga root, lalu push dashboard
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      elevation: 3,
                    ),
                    child: const Text('Mulai Perjalanan Anda'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Bagian "Pantau Kemajuan Anda"
            const Text(
              'Pantau Kemajuan Anda',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildTrackingCard(context, 'Catat Berat Badan', 'Timbang berat badan Anda secara teratur pada waktu yang sama setiap hari untuk hasil yang konsisten.', Icons.scale, 'Catat Berat Hari Ini', () { /* TODO */ }),
                _buildTrackingCard(context, 'Jurnal Makanan', 'Catat semua makanan dan minuman yang Anda konsumsi untuk memantau asupan kalori dan nutrisi.', Icons.book, 'Tambah Entri Makanan', () { /* TODO */ }),
                _buildTrackingCard(context, 'Aktivitas Fisik', 'Rekam semua aktivitas fisik Anda untuk melacak kalori yang terbakar dan kemajuan kebugaran.', Icons.directions_run, 'Catat Aktivitas', () { /* TODO */ }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk kartu data ringkasan (Umur, Berat Awal, dll.)
  Widget _buildDataCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Align(alignment: Alignment.topRight, child: Icon(icon, size: 24, color: Colors.grey[400])),
            Text(
              title,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk kartu makro nutrisi
  Widget _buildMacroCard(String title, String value, IconData icon) {
    return Card(
      color: Colors.blue.shade50, // Warna background yang lebih lembut
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: Colors.blue.shade600),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper untuk kartu pantau kemajuan
  Widget _buildTrackingCard(BuildContext context, String title, String description, IconData icon, String buttonText, VoidCallback onPressed) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 24, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Theme.of(context).primaryColor, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                child: Text(
                  buttonText,
                  style: TextStyle(fontSize: 12, color: Theme.of(context).primaryColor),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}