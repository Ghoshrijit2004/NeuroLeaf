import 'package:flutter/material.dart';
import '../services/credit_service.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _credits = CreditService();
  int _stars = 0;
  final Set<String> _unlocked = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStars();
  }

Future<void> _loadStars() async {
  final stars = await _credits.getStars();

  if (!mounted) return;

  setState(() {
    _stars = stars;
  });
}

  final List<Map<String, dynamic>> _freeArticles = [
    {
      'id': 'a1',
      'title': 'How to Identify Common Leaf Diseases',
      'desc': 'A beginner\'s guide to spotting early signs of plant disease.',
      'readTime': '5 min read',
      'icon': '🌿',
      'color': Colors.green,
      'free': true,
    },
    {
      'id': 'a2',
      'title': 'Organic Pest Control Methods',
      'desc': 'Natural ways to protect your crops without chemicals.',
      'readTime': '7 min read',
      'icon': '🪲',
      'color': Colors.orange,
      'free': true,
    },
    {
      'id': 'a3',
      'title': 'Understanding Soil Health',
      'desc': 'Why healthy soil is the foundation of disease-free plants.',
      'readTime': '6 min read',
      'icon': '🌱',
      'color': Colors.brown,
      'free': true,
    },
    {
      'id': 'a4',
      'title': 'Watering Best Practices',
      'desc': 'How over and under watering leads to plant diseases.',
      'readTime': '4 min read',
      'icon': '💧',
      'color': Colors.blue,
      'free': true,
    },
  ];

  final List<Map<String, dynamic>> _premiumContent = [
    {
      'id': 'p1',
      'title': 'Deep Learning for Plant Disease Detection',
      'author': 'Mohanty et al., 2016',
      'desc': 'CNN-based identification of 26 diseases across 14 crops using 54,000+ images.',
      'readTime': '20 min read',
      'icon': '🔬',
      'color': Colors.purple,
      'cost': 1,
      'type': 'Research Paper',
    },
    {
      'id': 'p2',
      'title': 'Transfer Learning in Agricultural AI',
      'author': 'Hughes & Salathé, 2015',
      'desc': 'Using pre-trained models to classify plant diseases with limited data.',
      'readTime': '25 min read',
      'icon': '🧬',
      'color': Colors.blue,
      'cost': 2,
      'type': 'Research Paper',
    },
    {
      'id': 'p3',
      'title': 'Tomato Disease Classification with ResNet',
      'author': 'Too et al., 2019',
      'desc': 'Comparative study of deep CNN architectures for tomato leaf disease.',
      'readTime': '18 min read',
      'icon': '🍅',
      'color': Colors.red,
      'cost': 1,
      'type': 'Research Paper',
    },
    {
      'id': 'b1',
      'title': 'Plant Pathology: Principles and Practice',
      'author': 'Agrios, G.N.',
      'desc': '5th edition — the definitive textbook on plant diseases and management.',
      'readTime': '2 hr read',
      'icon': '📗',
      'color': Colors.green,
      'cost': 3,
      'type': 'Book',
    },
    {
      'id': 'b2',
      'title': 'AI in Modern Agriculture',
      'author': 'Rasmussen et al., 2022',
      'desc': 'How machine learning and IoT are transforming farming practices.',
      'readTime': '3 hr read',
      'icon': '🤖',
      'color': Colors.teal,
      'cost': 4,
      'type': 'Book',
    },
  ];

  Future<void> _unlockContent(Map<String, dynamic> item) async {
    final cost = item['cost'] as int;
    if (_stars < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Need $cost ⭐ but you have $_stars ⭐"),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Unlock for $cost ⭐?"),
        content: Text("Spend $cost star${cost > 1 ? 's' : ''} to unlock \"${item['title']}\"?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade400),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Unlock", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _credits.spendStar(cost);
     if (success) {

  if (!mounted) return;

  setState(() {

    _stars -= cost;

    _unlocked.add(item['id']);

  });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("\"${item['title']}\" unlocked! 🎉"),
            backgroundColor: Colors.green.shade600,
          ),
        );
      }
    }
  }
    @override

 @override
void dispose() {
  _tabController.dispose();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Library 📚",
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2E7D32),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2E7D32),
          tabs: const [
            Tab(text: "Free Articles"),
            Tab(text: "Premium ⭐"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // ─── Free Articles ────────────────────
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 4),
              ..._freeArticles.map((a) => _articleCard(a)),
            ],
          ),

          // ─── Premium Content ──────────────────
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    const Text("⭐", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "You have $_stars stars. Earn more by completing tasks!",
                        style: TextStyle(
                            fontSize: 13, color: Colors.amber.shade800),
                      ),
                    ),
                  ],
                ),
              ),
              ..._premiumContent.map((p) => _premiumCard(p)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _articleCard(Map<String, dynamic> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(item['icon'],
                    style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(item['desc'],
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time,
                        size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(item['readTime'],
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade400)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text("Free",
                          style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2E7D32),
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _premiumCard(Map<String, dynamic> item) {
    final isUnlocked = _unlocked.contains(item['id']);
    final cost = item['cost'] as int;
    final canAfford = _stars >= cost;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? Colors.green.shade300 : Colors.grey.shade200,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
                child: Text(item['icon'],
                    style: const TextStyle(fontSize: 26))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(item['type'],
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.purple.shade400,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(item['title'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(item['author'] ?? '',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                const SizedBox(height: 4),
                Text(item['desc'],
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                isUnlocked
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text("✅ Read now",
                            style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold)),
                      )
                    : GestureDetector(
                        onTap: () => _unlockContent(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: canAfford
                                ? Colors.amber.shade100
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: canAfford
                                  ? Colors.amber.shade400
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Text(
                            canAfford
                                ? "🔓 Unlock for $cost ⭐"
                                : "🔒 Need $cost ⭐",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: canAfford
                                  ? Colors.amber.shade800
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
