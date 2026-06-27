import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreditService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ─── Get current user uid (null-safe) ────────────
  String? get _uid => _auth.currentUser?.uid;

  // ─── Get user document ref (null-safe) ───────────
  DocumentReference? get _userRef {
    final uid = _uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid);
  }

  // ─── Ensure user document exists ─────────────────
  Future<void> _ensureUserDoc() async {
    final ref = _userRef;
    if (ref == null) return;
    final user = _auth.currentUser;
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': user?.displayName ?? 'User',
        'email': user?.email ?? '',
        'stars': 0,
        'totalScans': 0,
        'dailyScans': {},
        'unlockedPdfs': [],
        'profileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  // ─── Record a scan + award stars if earned ───────
  Future<Map<String, dynamic>> recordScan() async {
    final ref = _userRef;
    if (ref == null) {
      return {'totalScans': 0, 'todayScans': 0, 'stars': 0, 'earnedStar': false};
    }

    await _ensureUserDoc();

    final today = _todayKey();
    final snap = await ref.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};

    final int totalScans = (data['totalScans'] ?? 0) + 1;
    final Map<String, dynamic> dailyScans =
        Map<String, dynamic>.from(data['dailyScans'] ?? {});
    final int todayCount = (dailyScans[today] ?? 0) + 1;
    dailyScans[today] = todayCount;

    int stars = data['stars'] ?? 0;
    bool earnedStar = false;

    // ⭐ Award 1 star for every 10 scans today
    if (todayCount % 10 == 0) {
      stars += 1;
      earnedStar = true;
    }

    await ref.set({
      'totalScans': totalScans,
      'dailyScans': dailyScans,
      'stars': stars,
    }, SetOptions(merge: true));

    return {
      'totalScans': totalScans,
      'todayScans': todayCount,
      'stars': stars,
      'earnedStar': earnedStar,
    };
  }

  // ─── Spend stars for premium content ─────────────
  Future<bool> spendStar(int cost) async {
    final ref = _userRef;
    if (ref == null) return false;

    await _ensureUserDoc();

    final snap = await ref.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};
    final int stars = data['stars'] ?? 0;

    if (stars < cost) return false;

    await ref.set({'stars': stars - cost}, SetOptions(merge: true));
    return true;
  }

  // ─── Get current stars balance ────────────────────
  Future<int> getStars() async {
    final ref = _userRef;
    if (ref == null) return 0;

    await _ensureUserDoc();

    final snap = await ref.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return data['stars'] ?? 0;
  }

  // ─── Get today's scan count ───────────────────────
  Future<int> getTodayScans() async {
    final ref = _userRef;
    if (ref == null) return 0;

    await _ensureUserDoc();

    final snap = await ref.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};
    final Map<String, dynamic> dailyScans =
        Map<String, dynamic>.from(data['dailyScans'] ?? {});
    return dailyScans[_todayKey()] ?? 0;
  }

  // ─── Check if profile is complete ────────────────
  Future<bool> isProfileComplete() async {
    final ref = _userRef;
    if (ref == null) return false;
    final snap = await ref.get();
    if (!snap.exists) return false;
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return data['profileComplete'] == true;
  }

  // ─── Mark profile as complete ─────────────────────
  Future<void> markProfileComplete(Map<String, dynamic> profileData) async {
    final ref = _userRef;
    if (ref == null) return;
    await ref.set({
      ...profileData,
      'profileComplete': true,
    }, SetOptions(merge: true));
  }

  // ─── Get total scan count ─────────────────────────
  Future<int> getTotalScans() async {
    final ref = _userRef;
    if (ref == null) return 0;
    final snap = await ref.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};
    return data['totalScans'] ?? 0;
  }

  // ─── Get user profile data ────────────────────────
  Future<Map<String, dynamic>> getUserProfile() async {
    final ref = _userRef;
    if (ref == null) return {};
    final snap = await ref.get();
    return snap.data() as Map<String, dynamic>? ?? {};
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
