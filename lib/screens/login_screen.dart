import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'signup_screen.dart';
import 'home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_setup_screen.dart';
import '../services/location_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  void _setLoading(bool val) => setState(() => _isLoading = val);

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red.shade400),
    );
  }

  Future<void> _navigate() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .get();

if (!mounted) return;
await FirebaseFirestore.instance

    .collection('users')

    .doc(user.uid)

    .set({

  'lastLogin': FieldValue.serverTimestamp(),

}, SetOptions(merge: true));

  // First login (Google/Facebook/GitHub user)
  if (!doc.exists) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .set({
      'email': user.email ?? '',
      'profileComplete': false,
      'stars': 0,
      'totalScans': 0,
      'dailyScans': {},
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(),
      ),
    );
    return;
  }

  final data = doc.data();

  if (data?['profileComplete'] != true) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileSetupScreen(),
      ),
    );
    return;
  }

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const HomeScreen(),
    ),
  );
}

  // ─── Email Login ─────────────────────────────────
  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    _setLoading(true);
    try {
      final user = await _auth.login(
        _emailController.text,
        _passwordController.text,
      );
     if (user != null) {
  await LocationService().updateUserLocation();
  await _navigate();
}
    } catch (e) {
      _showError(e.toString());
    }
    _setLoading(false);
  }

  // ─── Google Login ─────────────────────────────────
  Future<void> _loginWithGoogle() async {
    _setLoading(true);
    try {
    final user = await _auth.signInWithGoogle();

if (user != null) {
  await LocationService().updateUserLocation();
  await _navigate();
}
    } catch (e) {
      _showError(e.toString());
    }
    _setLoading(false);
  }

  // ─── Facebook Login ───────────────────────────────
 Future<void> _loginWithFacebook() async {
  _setLoading(true);

  try {
    final user = await _auth.signInWithFacebook();

    if (user != null) {
      await LocationService().updateUserLocation();
      await _navigate();
    }
  } catch (e) {
    _showError(e.toString());
  }

  _setLoading(false);
}

  // ─── GitHub Login ─────────────────────────────────
  Future<void> _loginWithGitHub() async {
    _setLoading(true);
    try {
      final githubProvider = GithubAuthProvider();
      final result = await FirebaseAuth.instance.signInWithProvider(githubProvider);
   if (result.user != null) {
  await LocationService().updateUserLocation();
  await _navigate();
}
    } catch (e) {
      _showError(e.toString());
    }
    _setLoading(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // 🌿 Header
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: const Text("🌿", style: TextStyle(fontSize: 40)),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "NeuroLeaf",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Sign in to continue",
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // 📧 Email Field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  validator: (v) =>
                      v == null || !v.contains('@') ? 'Enter valid email' : null,
                ),

                const SizedBox(height: 16),

                // 🔒 Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration:
                      _inputDecoration("Password", Icons.lock_outline).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.length < 6 ? 'Min 6 characters' : null,
                ),

                const SizedBox(height: 24),

                // 🚀 Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _loginWithEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Login",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Divider ───────────────────────
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text("or continue with",
                          style: TextStyle(color: Colors.grey.shade500)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 24),

                // ─── Google Button (full width) ────
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: _socialButton(
                    label: "Continue with Google",
                    icon: "G",
                    color: Colors.white,
                    textColor: Colors.black87,
                    onTap: _isLoading ? null : _loginWithGoogle,
                  ),
                ),

                const SizedBox(height: 12),

                // ─── Facebook + GitHub Row ─────────
                Row(
                  children: [
                    // Facebook
                    Expanded(
                      child: _socialButton(
                        label: "Facebook",
                        icon: "f",
                        color: const Color(0xFF1877F2),
                        textColor: Colors.white,
                        onTap: _isLoading ? null : _loginWithFacebook,
                      ),
                    ),

                    const SizedBox(width: 12),

                    // GitHub
                    Expanded(
                      child: _socialButton(
                        label: "GitHub",
                        icon: "⌥",
                        color: const Color(0xFF24292E),
                        textColor: Colors.white,
                        onTap: _isLoading ? null : _loginWithGitHub,
                        useGitHubIcon: true,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // ─── Sign Up Link ──────────────────
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ",
                          style: TextStyle(color: Colors.grey.shade600)),
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SignupScreen()),
                        ),
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
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
    );
  }

  Widget _socialButton({
    required String label,
    required String icon,
    required Color color,
    required Color textColor,
    required VoidCallback? onTap,
    bool useGitHubIcon = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            useGitHubIcon
                ? Icon(Icons.code, color: textColor, size: 18)
                : Text(
                    icon,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}