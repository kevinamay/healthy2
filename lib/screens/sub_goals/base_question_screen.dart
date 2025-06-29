import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hitung/screens/login_screen.dart'; // Untuk navigasi fallback

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
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => LoginScreen()));
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
        print('DEBUG: ${widget.screenDescription} - Navigating to next screen.');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => widget.nextScreen!),
        );
      } else {
        print('DEBUG: ${widget.screenDescription} - No next screen specified, staying on current page.');
        // If there's no next screen, perhaps show a success message or go to a default dashboard.
        // For now, we'll just show the success snackbar and stay.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        automaticallyImplyLeading: false, // Menghilangkan tombol back default
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
                                color: option['iconColor'].withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                option['icon'],
                                size: 30,
                                color: option['iconColor'],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    option['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    option['subtitle'],
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
          ],
        ),
      ),
    );
  }
}