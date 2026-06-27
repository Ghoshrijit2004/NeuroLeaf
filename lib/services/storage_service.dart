import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StorageService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  // ─── Ensure user document exists ─────────────────
  Future<void> _ensureUserDoc() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final ref = _db.collection('users').doc(user.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'name': user.displayName ?? 'User',
        'email': user.email ?? '',
        'stars': 0,
        'totalScans': 0,
        'dailyScans': {},
        'unlockedPdfs': [],
        'profileComplete': false,
        'createdAt': FieldValue.serverTimestamp(),
          'lastLogin': FieldValue.serverTimestamp(),

  'lastScanAt': null,
      }, SetOptions(merge: true));
    }
  }

  // ─── Save a scan record ──────────────────────────
Future<void> saveScan({
  required String disease,
  required double confidence,
  required String description,
  required String solution,
}) async {
  final user = _auth.currentUser;
  if (user == null) return;

  await _ensureUserDoc();

  // Save scan
  await _db
      .collection('users')
      .doc(user.uid)
      .collection('scans')
      .add({
    'disease': disease,
    'confidence': confidence,
    'description': description,
    'solution': solution,
    'timestamp': FieldValue.serverTimestamp(),
  });

  // Update user stats
  await _db
      .collection('users')
      .doc(user.uid)
      .update({
    'totalScans': FieldValue.increment(1),
    'lastScanAt': FieldValue.serverTimestamp(),
  });
}
}
