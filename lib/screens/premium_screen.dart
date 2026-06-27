import 'package:flutter/material.dart';
import '../services/credit_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _credits = CreditService();
  int _stars = 0;
  bool _isLoading = true;

  // ─── Unlocked content tracker ─────────────────────
  final Set<String> _unlocked = {};

  final List<Map<String, dynamic>> _papers = [
    {
      'id': 'p1',
      'type': 'paper',
      'title': 'Deep Learning for Plant Disease Detection',
      'author': 'Mohanty et al., 2016',
      'desc': 'CNN-based identification of 26 diseases across 14 crops using 54,000+ images.',
      'cost': 1,
      'icon': '🔬',
      'color': Colors.purple,
    },
    {
      'id': 'p2',
      'type': 'paper',
      'title': 'Transfer Learning in Agricultural AI',
      'author': 'Hughes & Salathé, 2015',
      'desc': 'Using pre-trained models to classify plant diseases with limited data.',
      'cost': 2,
      'icon': '🧬',
      'color': Colors.blue,
    },
    {
      'id': 'p3',
      'type': 'paper',
      'title': 'Tomato Disease Classification with ResNet',
      'author': 'Too et al., 2019',
      'desc': 'Comparative study of deep CNN architectures for tomato leaf disease detection.',
      'cost': 1,
      'icon': '🍅',
      'color': Colors.red,
    },
    {
      'id': 'p4',
      'type': 'paper',
      'title': 'Early Blight vs Late Blight: A Field Guide',
      'author': 'Cornell Plant Pathology, 2021',
      'desc': 'Visual differentiation guide with treatment protocols for Potato blight diseases.',
      'cost': 1,
      'icon': '🥔',
      'color': Colors.brown,
    },
  ];

  final List<Map<String, dynamic>> _books = [
    {
      'id': 'b1',
      'type': 'book',
      'title': 'Plant Pathology: Principles and Practice',
      'author': 'Agrios, G.N.',
      'desc': '5th edition — the definitive textbook on plant diseases, symptoms, and management.',
      'cost': 3,
      'icon': '📗',
      'color': Colors.green,
    },
    {
      'id': 'b2',
      'type': 'book',
      'title': 'Integrated Pest Management in Agriculture',
      'author': 'Koul & Dhaliwal',
      'desc': 'Comprehensive guide to eco-friendly pest and disease management strategies.',
      'cost': 3,
      'icon': '📘',
      'color': Colors.indigo,
    },
    {
      'id': 'b3',
      'type': 'book',
      'title': 'AI in Modern Agriculture',
      'author': 'Rasmussen et al., 2022',
      'desc': 'How machine learning, drones, and IoT are transforming farming practices.',
      'cost': 4,
      'icon': '🤖',
      'color': Colors.teal,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStars();
  }

  Future<void> _loadStars() async {
    final s = await _credits.getStars();
    setState(() {
      _stars = s;
      _isLoading = false;
    });
  }

  Future<void> _unlock(Map<String, dynamic> item) async {
    final cost = item['cost'] as int;

    if (_stars < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Not enough stars! You need $cost ⭐ but have $_stars ⭐"),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Unlock for $cost ⭐?"),
        content: Text(
            "Spend $cost star${cost > 1 ? 's' : ''} to unlock \"${item['title']}\"?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade400),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Unlock",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _credits.spendStar(cost);
      if (success) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2E7D32)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Premium Content",
          style: TextStyle(
              color: Color(0xFF2E7D32), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ─── Stars Balance ─────────────────
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text("⭐",
                            style: TextStyle(fontSize: 36)),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$_stars Stars available",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2E7D32),
                                ),
                              ),
                              Text(
                                "Scan 10 leaves daily to earn more ⭐",
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── How to earn ──────────────────
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      children: [
                        const Text("💡",
                            style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Scan 10 leaves in a day → earn 1 ⭐ star. Repeat daily for more!",
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.green.shade800),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ─── Research Papers ──────────────
                  _sectionHeader("📄 Research Papers"),
                  const SizedBox(height: 12),
                  ..._papers.map((item) => _contentCard(item)),

                  const SizedBox(height: 24),

                  // ─── Books ────────────────────────
                  _sectionHeader("📚 Books"),
                  const SizedBox(height: 12),
                  ..._books.map((item) => _contentCard(item)),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF2E7D32),
      ),
    );
  }

  Widget _contentCard(Map<String, dynamic> item) {
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
          color: isUnlocked
              ? Colors.green.shade300
              : Colors.grey.shade200,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (item['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(item['icon'],
                  style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['author'],
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 6),
                Text(
                  item['desc'],
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 10),

                // Unlock button or unlocked badge
                isUnlocked
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "✅ Unlocked — Read now",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF2E7D32),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: () => _unlock(item),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
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
                              fontWeight: FontWeight.w600,
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
