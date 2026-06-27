import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/credit_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _credits = CreditService();
  int _stars = 0;
  int _todayScans = 0;
  int _totalScans = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) return;

  try {
    final snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    final data = snap.data() ?? {};

    final today = await _credits.getTodayScans();

    if (!mounted) return;

    setState(() {
      _stars = data['stars'] ?? 0;
      _totalScans = data['totalScans'] ?? 0;
      _todayScans = today;
      _isLoading = false;
    });
  } catch (e) {
    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Failed to load tasks: $e"),
      ),
    );
  }
}
@override
void dispose() {
  super.dispose();
}

  final List<Map<String, dynamic>> _dailyTasks = [
    {
      'id': 't1',
      'title': 'Scan 10 leaves today',
      'desc': 'Scan 10 different leaves to earn 1 star',
      'icon': '🔍',
      'reward': 1,
      'type': 'scan',
      'target': 10,
    },
    {
      'id': 't2',
      'title': 'Read a free article',
      'desc': 'Read any article in the Library tab',
      'icon': '📖',
      'reward': 1,
      'type': 'read',
      'target': 1,
    },
    {
      'id': 't3',
      'title': 'Daily login streak',
      'desc': 'Open the app 3 days in a row',
      'icon': '🔥',
      'reward': 2,
      'type': 'streak',
      'target': 3,
    },
  ];

  final List<Map<String, dynamic>> _milestones = [
    {
      'title': 'First Scan',
      'desc': 'Complete your first leaf scan',
      'icon': '🌱',
      'reward': 1,
      'target': 1,
      'type': 'totalScans',
    },
    {
      'title': 'Scan Explorer',
      'desc': 'Complete 25 total scans',
      'icon': '🔬',
      'reward': 3,
      'target': 25,
      'type': 'totalScans',
    },
    {
      'title': 'Leaf Master',
      'desc': 'Complete 100 total scans',
      'icon': '🏆',
      'reward': 10,
      'target': 100,
      'type': 'totalScans',
    },
    {
      'title': 'Star Collector',
      'desc': 'Earn 5 stars total',
      'icon': '⭐',
      'reward': 5,
      'target': 5,
      'type': 'stars',
    },
    {
      'title': 'Premium Reader',
      'desc': 'Unlock your first premium paper',
      'icon': '📄',
      'reward': 2,
      'target': 1,
      'type': 'unlocked',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Tasks & Rewards ⭐",
          style: TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14, top: 10, bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.amber.shade300),
            ),
            child: Row(
              children: [
                const Text("⭐", style: TextStyle(fontSize: 14)),
                const SizedBox(width: 4),
                Text("$_stars",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                        fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ─── Stars Summary ─────────────────
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.amber.shade400,
                          Colors.orange.shade400
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Text("⭐",
                            style: TextStyle(fontSize: 52)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$_stars Stars",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                "Use stars to unlock premium content",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.9)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── How to earn ──────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("How to earn ⭐ Stars",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF2E7D32))),
                        const SizedBox(height: 10),
                        _earnRow("🔍", "Scan 10 leaves in a day → 1 ⭐"),
                        _earnRow("📖", "Read articles in Library → 1 ⭐"),
                        _earnRow("🔥", "3-day login streak → 2 ⭐"),
                        _earnRow("🏆", "Complete milestones → bonus ⭐"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── Daily Tasks ──────────────────
                  const Text("Daily Tasks",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32))),
                  const SizedBox(height: 12),
                  ..._dailyTasks.map((task) => _taskCard(task)),

                  const SizedBox(height: 20),

                  // ─── Milestones ───────────────────
                  const Text("Milestones",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32))),
                  const SizedBox(height: 12),
                  ..._milestones.map((m) => _milestoneCard(m)),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _earnRow(String icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  fontSize: 13, color: Colors.green.shade800)),
        ],
      ),
    );
  }

  Widget _taskCard(Map<String, dynamic> task) {
    int current = 0;
    int target = task['target'] as int;

    if (task['type'] == 'scan') current = _todayScans;

    final progress = (current / target).clamp(0.0, 1.0);
    final isDone = current >= target;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone ? Colors.green.shade300 : Colors.grey.shade200,
          width: isDone ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(task['icon'], style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task['title'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14)),
                    Text(task['desc'],
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text("+${task['reward']} ⭐",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
              ),
            ],
          ),
          if (task['type'] == 'scan') ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isDone
                            ? Colors.green
                            : const Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isDone ? "✅ Done!" : "$current/$target",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDone
                        ? Colors.green
                        : const Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _milestoneCard(Map<String, dynamic> m) {
    int current = 0;
    final target = m['target'] as int;
    if (m['type'] == 'totalScans') current = _totalScans;
    if (m['type'] == 'stars') current = _stars;

    final isDone = current >= target;
    final progress = (current / target).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDone ? Colors.green.shade300 : Colors.grey.shade200,
          width: isDone ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(m['icon'], style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m['title'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(m['desc'],
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDone
                      ? Colors.green.shade100
                      : Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isDone ? "✅ Done" : "+${m['reward']} ⭐",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: isDone
                        ? Colors.green.shade700
                        : Colors.amber.shade800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isDone ? Colors.green : const Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                isDone ? "Complete!" : "$current/$target",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDone
                      ? Colors.green
                      : const Color(0xFF2E7D32),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
