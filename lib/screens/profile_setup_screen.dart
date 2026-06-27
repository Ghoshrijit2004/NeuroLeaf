import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();

  String _selectedAvatar = '🌿';
  bool _isSaving = false;

  final List<String> _avatars = [
    '🌿', '🌱', '🍃', '🌾', '🌵', '🌴', '🍀', '🌻',
    '🌺', '🌸', '🍁', '🌲', '🪴', '🎋', '🌳', '🪷',
  ];

  // ─── Progress calculation ─────────────────────────
 double get _progress {
  int filled = 0;

  if (_nameController.text.trim().isNotEmpty) filled++;
  if (_bioController.text.trim().isNotEmpty) filled++;

  filled++; // avatar selected

  return filled / 3;
}

  int get _progressPercent => (_progress * 100).round();

  Color get _progressColor {
    if (_progressPercent < 40) return Colors.red.shade400;
    if (_progressPercent < 75) return Colors.orange.shade400;
    return const Color(0xFF2E7D32);
  }

  // ─── Save to Firestore ────────────────────────────
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your name")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'name': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'avatar': _selectedAvatar,
        'email': user?.email ?? '',
        'profileComplete': true,
        'stars': 0,
        'totalScans': 0,
        'dailyScans': {},
        'unlockedPdfs': [],
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const HomeScreen()),
  (_) => false,
);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 12),

              // ─── Header ──────────────────────────
              const Text(
                "Set up your profile",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "Tell us about yourself to get started",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),

              const SizedBox(height: 24),

              // ─── Progress Bar ─────────────────────
              Row(
                children: [
                  Text(
                    "$_progressPercent% complete",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _progressColor,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _progressPercent == 100 ? "Ready! 🎉" : "Keep going...",
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progress,
                  minHeight: 10,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(_progressColor),
                ),
              ),

              const SizedBox(height: 28),

              // ─── Avatar Picker ────────────────────
              const Text(
                "Choose your avatar",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2E7D32),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: _avatars.length,
                  itemBuilder: (context, i) {
                    final selected = _avatars[i] == _selectedAvatar;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedAvatar = _avatars[i];
                      }),
                      child: Container(
                        decoration: BoxDecoration(
                          color: selected
                              ? Colors.green.shade100
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF2E7D32)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            _avatars[i],
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // ─── Name ─────────────────────────────
              _buildLabel("Full Name *"),
              const SizedBox(height: 8),
              _buildField(
                controller: _nameController,
                hint: "e.g. Rijit Ghosh",
                icon: Icons.person_outline,
              ),

              const SizedBox(height: 16),

              // ─── Bio ──────────────────────────────
              _buildLabel("Bio"),
              const SizedBox(height: 8),
              TextField(
                controller: _bioController,
                maxLines: 3,
                maxLength: 120,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: "e.g. Plant enthusiast, farmer, researcher...",
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  filled: true,
                  fillColor: Colors.white,
                  counterStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                        const BorderSide(color: Color(0xFF2E7D32)),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const SizedBox(height: 32),
              Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.blue.shade50,
    borderRadius: BorderRadius.circular(12),
  ),
  child: const Row(
    children: [
      Icon(Icons.location_on, color: Colors.blue),
      SizedBox(width: 8),
      Expanded(
        child: Text(
          "Your location will be detected automatically for weather and crop insights.",
          style: TextStyle(fontSize: 13),
        ),
      ),
    ],
  ),
),

              // ─── Save Button ──────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              "Complete Profile",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            Text("🌿", style: TextStyle(fontSize: 18)),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ─── Skip ────────────────────────────
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(builder: (_) => const HomeScreen()),
  (_) => false,
),
                  child: Text(
                    "Skip for now",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF2E7D32)),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF2E7D32)),
        ),
      ),
    );
  }
}
