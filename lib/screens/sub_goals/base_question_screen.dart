import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitung/screens/login_screen.dart';
import 'package:hitung/screens/goal_selection_screen.dart'; // Import GoalSelectionScreen untuk tombol Back

// Define a callback function type for when a selection is made and to save data
typedef OnSelectionMadeCallback = Future<void> Function(String selectedOption);

class BaseQuestionScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<Map<String, dynamic>> options; // List of {'title', 'subtitle', 'icon', 'iconColor', 'valueToSave'}
  final String dbKey; // Key to save in Firebase (e.g., 'weightLossObstacle')
  final Widget? nextScreen; // The screen to navigate to after this question
  final String screenDescription; // For debugging prints

  const BaseQuestionScreen({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.options,
    required this.dbKey,
    this.nextScreen,
    required this.screenDescription,
  }) : super(key: key);

  @override
  State<BaseQuestionScreen> createState() => _BaseQuestionScreenState();
}

class _BaseQuestionScreenState extends State<BaseQuestionScreen> {
  String? _selectedOption; // The selected option from the list

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _saveOptionAndNavigate() async {
    print('DEBUG: ${widget.screenDescription} - _saveOptionAndNavigate called.');

    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Silakan pilih salah satu ${widget.title.toLowerCase().replaceAll("apa ", "").replaceAll(" anda", "")}.')),
      );
      print('DEBUG: ${widget.screenDescription} - No option selected.');
      return;
    }

    User? user = _auth.currentUser;
    print('DEBUG: ${widget.screenDescription} - Current User UID: ${user?.uid}');

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna tidak ditemukan. Harap login kembali.')),
      );
      print('DEBUG: ${widget.screenDescription} - User is null, redirecting to login.');
      // Menggunakan pushAndRemoveUntil untuk memastikan tidak ada history kembali setelah logout
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (Route<dynamic> route) => false,
      );
      return;
    }

    try {
      print('DEBUG: ${widget.screenDescription} - Attempting to save ${widget.dbKey}: $_selectedOption for UID: ${user.uid}');
      await _database.child('users').child(user.uid).update({
        widget.dbKey: _selectedOption,
        '${widget.dbKey}Timestamp': ServerValue.timestamp,
      });
      print('DEBUG: ${widget.screenDescription} - Data saved successfully for ${widget.dbKey}!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.title} berhasil disimpan!')),
      );

      if (widget.nextScreen != null) {
        print('DEBUG: ${widget.screenDescription} - Navigating to ${widget.nextScreen!.runtimeType}');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.nextScreen!),
        );
      } else {
        print('DEBUG: ${widget.screenDescription} - No next screen specified, staying on current page.');
      }
    } on FirebaseException catch (e) {
      print('DEBUG: ${widget.screenDescription} - Firebase Exception: ${e.code} - ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan ${widget.dbKey} (Firebase): ${e.message}')),
      );
    } catch (e) {
      print('DEBUG: ${widget.screenDescription} - General Error saving ${widget.dbKey}: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan ${widget.dbKey}: ${e.toString()}')),
      );
    }
  }

  // Fungsi Logout
  Future<void> _logout() async {
    try {
      await _auth.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil logout.')),
      );
      Navigator.pushAndRemoveUntil( // Kembali ke LoginScreen dan hapus semua rute sebelumnya
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
        title: Text(widget.title),
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghilangkan tombol back default dari AppBar
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
            Text(
              widget.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: widget.options.length,
                itemBuilder: (context, index) {
                  final option = widget.options[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: _selectedOption == option['valueToSave']
                            ? Theme.of(context).primaryColor
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        setState(() {
                          _selectedOption = option['valueToSave'];
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: (option['iconColor'] as Color).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                option['icon'] as IconData,
                                size: 30,
                                color: option['iconColor'] as Color,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['title'] as String,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option['subtitle'] as String,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (_selectedOption == option['valueToSave'])
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).primaryColor,
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
                onPressed: _saveOptionAndNavigate,
                child: const Text('BERIKUTNYA'),
              ),
            ),
            // --- HAPUS OUTLINEDBUTTON 'KEMBALI' DARI SINI ---
            // SizedBox(
            //   width: double.infinity,
            //   child: OutlinedButton(
            //     onPressed: () {
            //       Navigator.pushReplacement(
            //         context,
            //         MaterialPageRoute(builder: (context) => const GoalSelectionScreen()),
            //       );
            //     },
            //     child: const Text('KEMBALI'),
            //   ),
            // ),
            // --- AKHIR HAPUS ---
          ],
        ),
      ),
      // --- TAMBAHKAN FLOATINGACTIONBUTTON INI ---
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi kembali ke GoalSelectionScreen
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const GoalSelectionScreen()),
          );
        },
        mini: true, // Membuat FAB lebih kecil
        backgroundColor: Colors.transparent, // Background transparan
        elevation: 0, // Tanpa bayangan
        child: Icon(
          Icons.arrow_back_ios,
          color: Theme.of(context).primaryColor, // Warna ikon sesuai tema utama
          size: 24,
        ),
      ),
      // --- AKHIR TAMBAHAN FLOATINGACTIONBUTTON ---
    );
  }
}