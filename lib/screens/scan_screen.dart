import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../services/credit_service.dart';
import 'premium_screen.dart';


class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _image;
  final picker = ImagePicker();
  bool isUploading = false;

  String? disease;
  double? confidence;
  String? description;
  String? solution;

  int _stars = 0;
  int _todayScans = 0;

  final _storage = StorageService();
  final _credits = CreditService();

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
  final stars = await _credits.getStars();
  final today = await _credits.getTodayScans();

  if (!mounted) return;

  setState(() {
    _stars = stars;
    _todayScans = today;
  });
}
@override
void dispose() {
  super.dispose();
}

  // 📸 Pick Image
  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        disease = null;
        confidence = null;
        description = null;
        solution = null;
      });
    }
  }

  // 📷 Camera
  Future<void> captureImage() async {
    final pickedFile =
        await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        disease = null;
        confidence = null;
        description = null;
        solution = null;
      });
    }
  }

  // 🚀 Upload to API
  Future<void> uploadImage() async {
    if (_image == null) return;
    setState(() => isUploading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse("https://hut-petite-sulfate.ngrok-free.dev/predict"),
      );
      request.files.add(
          await http.MultipartFile.fromPath('file', _image!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final data = jsonDecode(respStr);

        setState(() {
          disease = data["prediction"];
          confidence = data["confidence"];
          description = data["description"];
          solution = data["solution"];
        });

        // 💾 Save scan to Firestore
        await _storage.saveScan(
          disease: disease!,
          confidence: confidence!,
          description: description!,
          solution: solution!,
        );

        // ⭐ Record scan + check for star award
        final result = await _credits.recordScan();
        setState(() {
          _stars = result['stars'];
          _todayScans = result['todayScans'];
        });

        // 🎉 Show star earned notification
        if (result['earnedStar'] == true) {
          _showStarEarnedDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  "Prediction received! ${10 - (_todayScans % 10)} more scans for a ⭐"),
              backgroundColor: Colors.green.shade600,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("API Error: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => isUploading = false);
  }

  // 🎉 Star earned dialog
  void _showStarEarnedDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("⭐", style: TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            const Text(
              "You earned a Star!",
              style: TextStyle(
                  fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "You've scanned 10 leaves today.\nUse your stars to unlock premium research!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Later"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade400),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const PremiumScreen()),
                      );
                    },
                    child: const Text("View Premium",
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "NeuroLeaf 🌿",
          style: TextStyle(
            color: Color(0xFF2E7D32),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          // ⭐ Stars badge (clickable to Premium)
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PremiumScreen()),
            ).then((_) => _loadStats()),
            child: Container(
              margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.amber.shade100,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Row(
                children: [
                  const Text("⭐", style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    "$_stars",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E7D32),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ─── Daily progress bar ──────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Today's scans",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        "$_todayScans / 10 for ⭐",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (_todayScans % 10) / 10,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF2E7D32)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── Image Preview ───────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: _image != null
                    ? Image.file(_image!, fit: BoxFit.cover)
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("🌿",
                              style: TextStyle(
                                  fontSize: 48,
                                  color: Colors.grey.shade300)),
                          const SizedBox(height: 8),
                          Text(
                            "Pick or capture a leaf image",
                            style: TextStyle(
                                color: Colors.grey.shade400,
                                fontSize: 14),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // ─── Action buttons ──────────────────
            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    icon: Icons.photo_library_outlined,
                    label: "Gallery",
                    onTap: pickImage,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionButton(
                    icon: Icons.camera_alt_outlined,
                    label: "Camera",
                    onTap: captureImage,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: isUploading ? null : uploadImage,
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUploading
                            ? Colors.grey.shade300
                            : const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2),
                              )
                            : const Text(
                                "Analyze 🔍",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ─── Result Cards ────────────────────
            if (disease != null) ...[
              _resultCard(
                color: Colors.green.shade50,
                border: Colors.green.shade200,
                child: Row(
                  children: [
                    const Text("🌿", style: TextStyle(fontSize: 28)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Detected Disease",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey)),
                          Text(
                            disease!,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "${(confidence! * 100).toStringAsFixed(1)}%",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (description != null)
              _resultCard(
                color: Colors.blue.shade50,
                border: Colors.blue.shade200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("🧾 Description",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(description!,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),

            if (description != null) const SizedBox(height: 10),

            if (solution != null)
              _resultCard(
                color: Colors.orange.shade50,
                border: Colors.orange.shade200,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("💊 Solution",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13)),
                    const SizedBox(height: 6),
                    Text(solution!,
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF2E7D32)),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, color: Color(0xFF2E7D32))),
          ],
        ),
      ),
    );
  }

  Widget _resultCard({
    required Color color,
    required Color border,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: child,
    );
  }
}
