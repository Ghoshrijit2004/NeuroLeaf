import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/credit_service.dart';
import '../services/weather_service.dart';
import 'notification_screen.dart';
class DashboardScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const DashboardScreen({
    super.key,
    this.onNavigate,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;

  String name = '';
  String avatar = '🌿';

  int stars = 0;
  int totalScans = 0;
  int todayScans = 0;

  String recentDisease = '';
  double recentConfidence = 0;
  String tipTitle = 'Loading tip...';
String tipDescription = '';
int streak = 0;
String weatherCity = 'Loading weather...';
double temperature = 0;
int humidity = 0;
String weatherCondition = '';
@override
void initState() {
  super.initState();
  loadDashboard();
  loadTip();
  loadWeather();
}

Future<void> loadDashboard() async {

  try {

    final uid = FirebaseAuth.instance.currentUser!.uid;

    final userDoc = await FirebaseFirestore.instance

        .collection('users')

        .doc(uid)

        .get();

    final data = userDoc.data() ?? {};
    final dailyScans =
    Map<String, dynamic>.from(
      data['dailyScans'] ?? {},
    );

    final scans = await FirebaseFirestore.instance

        .collection('users')

        .doc(uid)

        .collection('scans')

        .orderBy('timestamp', descending: true)

        .limit(1)

        .get();

    final today = await CreditService().getTodayScans();

    if (!mounted) return;

    setState(() {

      name = data['name'] ?? '';

      avatar = data['avatar'] ?? '🌿';

      stars = data['stars'] ?? 0;

      totalScans = data['totalScans'] ?? 0;

      todayScans = today;
      streak = calculateStreak(dailyScans);

      if (scans.docs.isNotEmpty) {

        recentDisease = scans.docs.first['disease'] ?? '';

        recentConfidence =

            (scans.docs.first['confidence'] ?? 0).toDouble();

      }

      isLoading = false;

    });

  } catch (e) {

    debugPrint(e.toString());

  }

}
Future<void> loadTip() async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('tips')
        .get();

    if (snapshot.docs.isEmpty) return;

    final dayIndex =
    (DateTime.now().millisecondsSinceEpoch ~/ 86400000)
        % snapshot.docs.length;

    final tip = snapshot.docs[dayIndex].data();

    if (!mounted) return;

    setState(() {
      tipTitle = tip['title'] ?? '';
      tipDescription = tip['description'] ?? '';
    });
  } catch (e) {
  debugPrint(e.toString());

  if (!mounted) return;

  setState(() {
    isLoading = false;
  });
}
}
int calculateStreak(Map<String, dynamic> dailyScans) {
  int streakCount = 0;

  DateTime currentDay = DateTime.now();

  while (true) {
    final key =
        '${currentDay.year}-${currentDay.month.toString().padLeft(2, '0')}-${currentDay.day.toString().padLeft(2, '0')}';

    if (dailyScans.containsKey(key) &&
        (dailyScans[key] ?? 0) > 0) {
      streakCount++;

      currentDay =
          currentDay.subtract(const Duration(days: 1));
    } else {
      break;
    }
  }

  return streakCount;
}
Future<void> loadWeather() async {
  try {
    final uid =
        FirebaseAuth.instance.currentUser!.uid;

    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

    final data = doc.data();

    final lat = data?['latitude'];
    final lon = data?['longitude'];

    if (lat == null || lon == null) return;

    final weather =
        await WeatherService()
            .getWeather(lat, lon);

    if (!mounted) return;

    setState(() {
  weatherCity =
      data?['location'] ?? 'Unknown Location';

  temperature =
      (weather['temp'] ?? 0).toDouble();

  humidity =
      weather['humidity'] ?? 0;

  weatherCondition =
      weather['condition'] ?? 'Unknown';
});
  } catch (e) {
    debugPrint(e.toString());
  }
}
  Widget statCard(
    String icon,
    String value,
    String label,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Color(0xFF2E7D32),
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            )
          ],
        ),
      ),
    );
  }

Widget actionButton(
  String title,
  IconData icon,
  VoidCallback onTap,
) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: const Color(0xFF2E7D32),
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(title),
        ],
      ),
    ),
  );
}
Widget _buildDrawer() {
  return Drawer(
      child: SafeArea(
  child: ListView(
    padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          accountName: Text(name),
          accountEmail: Text(
            FirebaseAuth.instance.currentUser?.email ?? '',
          ),
          currentAccountPicture: CircleAvatar(
            child: Text(
              avatar,
              style: const TextStyle(fontSize: 30),
            ),
          ),
          decoration: const BoxDecoration(
            color: Color(0xFF2E7D32),
          ),
        ),

        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Profile"),
          onTap: () {
            Navigator.pop(context);
            widget.onNavigate?.call(5);
          },
        ),

        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text("Theme"),
          subtitle: const Text("Light / Dark"),
          onTap: () {},
        ),

       ListTile(

  leading: const Icon(Icons.settings),

  title: const Text("Settings"),

  onTap: () {},

),

ListTile(
  leading: const Icon(Icons.history),
  title: const Text("Scan History"),
  onTap: () {
    Navigator.pop(context);
    widget.onNavigate?.call(1);
  },
),

ListTile(

  leading: const Icon(Icons.analytics),

  title: const Text("Statistics"),

  onTap: () {},

),

ListTile(

  leading: const Icon(Icons.emoji_events),

  title: const Text("Achievements"),

  onTap: () {},

),

ListTile(

  leading: const Icon(Icons.help_outline),

  title: const Text("Help & Support"),

  onTap: () {},

),

ListTile(

  leading: const Icon(Icons.info_outline),

  title: const Text("About NeuroLeaf"),

  onTap: () {},

),

        const Divider(),

        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          onTap: () async {
  await FirebaseAuth.instance.signOut();

  if (!mounted) return;

  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
},
        ),
      ],
    ),
      ),
  );
}

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
final remainingScans =
    (10 - todayScans).clamp(0, double.infinity).toInt();
    bool hasNotification = false;
    return Scaffold(
  drawer: _buildDrawer(),
  backgroundColor: const Color(0xFFF5F9F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
  children: [
   
   Builder(
  builder: (context) => GestureDetector(
    onTap: () {
      Scaffold.of(context).openDrawer();
    },
    child: CircleAvatar(
      radius: 24,
      backgroundColor: Colors.white24,
      child: Text(
        avatar,
        style: const TextStyle(fontSize: 24),
      ),
    ),
  ),
),

    const SizedBox(width: 12),

    Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hello $name",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            "Welcome back 🌿",
            style: TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    ),

    Stack(
  children: [
    IconButton(
      onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const NotificationScreen(),
    ),
  );
},
      icon: const Icon(
        Icons.notifications_none,
        color: Colors.white,
      ),
    ),
   if (hasNotification)
  Positioned(
    right: 10,
    top: 10,
    child: Container(
      width: 10,
      height: 10,
      decoration: const BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
      ),
    ),
  ),
  ],
),
  ],
)
              ),

              const SizedBox(height: 20),

              const Text(
                "Today's Progress",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                   LinearProgressIndicator(
  value: (todayScans / 10).clamp(0.0, 1.0),
  minHeight: 10,
  borderRadius: BorderRadius.circular(20),
),
                    const SizedBox(height: 10),
                    Text(
                      "$todayScans / 10 scans today",
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

GestureDetector(
  onTap: () => widget.onNavigate?.call(3),
  child: Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Colors.blue.shade50,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        const Text(
          "🌦️",
          style: TextStyle(fontSize: 40),
        ),

        const SizedBox(width: 16),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weatherCity.isEmpty
                    ? "Loading weather..."
                    : weatherCity,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),

              Row(
  children: [
    Text(
      "${temperature.toStringAsFixed(1)}°C",
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(width: 8),
    const Icon(
      Icons.arrow_forward_ios,
      size: 14,
    ),
  ],
),

              Text(
                "Humidity: $humidity%",
              ),
              Text(
  weatherCondition,
  style: TextStyle(
    color: Colors.grey.shade700,
  ),
),
            ],
          ),
        ),
      ],
    ),
  ),
),

const SizedBox(height: 20),
             Column(
  children: [
    Row(
      children: [
        statCard(
          "⭐",
          stars.toString(),
          "Stars",
        ),
        const SizedBox(width: 12),
        statCard(
          "🔍",
          totalScans.toString(),
          "Scans",
        ),
      ],
    ),

    const SizedBox(height: 12),

    Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text(
            "🔥",
            style: TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 6),
          Text(
            streak == 1
    ? "1 Day Streak"
    : "$streak Days Streak",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Text(
streak == 0
    ? "Start your first scan today 🌱"
    : streak < 7
        ? "Keep the streak alive 🔥"
        : "Amazing consistency! 🚀"
),
        ],
      ),
    ),
  ],
),
const SizedBox(height: 12),

Container(
  width: double.infinity,
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.purple.shade50,
    borderRadius: BorderRadius.circular(18),
  ),
  child: Column(
    children: [
      const Text(
        "🎯 Next Goal",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        remainingScans == 0
            ? "🎉 Daily goal completed!"
            : "$remainingScans more scans to reach today's goal",
      ),
    ],
  ),
),

              const SizedBox(height: 24),

              const Text(
                "Quick Actions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
  actionButton(
    "Scan Leaf",
    Icons.document_scanner,
    () => widget.onNavigate?.call(1),
  ),

  actionButton(
    "Weather",
    Icons.cloud,
    () => widget.onNavigate?.call(3),
  ),

  actionButton(
    "Library",
    Icons.menu_book,
    () => widget.onNavigate?.call(2),
  ),

  actionButton(
    "Tasks",
    Icons.star,
    () => widget.onNavigate?.call(4),
  ),
],
              ),

              const SizedBox(height: 24),

              const Text(
                "Recent Scan",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 10),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: recentDisease.isEmpty
                    ? const Text("No scans yet")
                    : Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                        Row(
  children: [
    const Text(
      "🦠 ",
      style: TextStyle(fontSize: 20),
    ),
    Expanded(
      child: Text(
        recentDisease,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  ],
),
                          const SizedBox(height: 6),
                          Text(
                            "${(recentConfidence * 100).toStringAsFixed(1)}% confidence",
                          ),
                        ],
                      ),
              ),

              const SizedBox(height: 24),

            Container(
  padding: const EdgeInsets.all(18),
  decoration: BoxDecoration(
    color: Colors.green.shade50,
    borderRadius: BorderRadius.circular(18),
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "🌱 Plant Tip of the Day",
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      Text(
        tipTitle,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 6),
      Text(
        tipDescription,
      ),
    ],
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}