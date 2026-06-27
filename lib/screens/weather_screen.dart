import 'package:flutter/material.dart';

class WeatherScreen extends StatelessWidget {
  const WeatherScreen({super.key});

  final List<Map<String, dynamic>> _crops = const [
    {
      'name': 'Tomato',
      'icon': '🍅',
      'condition': 'Good',
      'advice': 'Ideal temperature for growth. Watch for late blight.',
      'color': Colors.red,
    },
    {
      'name': 'Potato',
      'icon': '🥔',
      'condition': 'Moderate',
      'advice': 'Humidity is high. Risk of early blight. Apply fungicide.',
      'color': Colors.brown,
    },
    {
      'name': 'Pepper',
      'icon': '🫑',
      'condition': 'Good',
      'advice': 'Perfect conditions. Ensure regular watering.',
      'color': Colors.green,
    },
    {
      'name': 'Wheat',
      'icon': '🌾',
      'condition': 'Alert',
      'advice': 'High wind forecast. Secure crops and check for rust.',
      'color': Colors.amber,
    },
  ];

  final List<Map<String, dynamic>> _forecast = const [
    {'day': 'Today', 'icon': '☀️', 'high': '32', 'low': '24'},
    {'day': 'Tue', 'icon': '⛅', 'high': '29', 'low': '22'},
    {'day': 'Wed', 'icon': '🌧️', 'high': '26', 'low': '20'},
    {'day': 'Thu', 'icon': '🌦️', 'high': '28', 'low': '21'},
    {'day': 'Fri', 'icon': '☀️', 'high': '33', 'low': '25'},
    {'day': 'Sat', 'icon': '☀️', 'high': '34', 'low': '26'},
    {'day': 'Sun', 'icon': '⛅', 'high': '30', 'low': '23'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F9F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "Weather & Crops 🌤",
          style: TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ─── Current Weather Card ─────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Mumbai, India",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                          const SizedBox(height: 4),
                          const Text("32°C",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 52,
                                  fontWeight: FontWeight.bold)),
                          const Text("Partly Cloudy",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 16)),
                        ],
                      ),
                      const Text("⛅",
                          style: TextStyle(fontSize: 72)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _weatherStat("💧", "Humidity", "78%"),
                      _weatherStat("💨", "Wind", "12 km/h"),
                      _weatherStat("👁️", "UV Index", "High"),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ─── 7-Day Forecast ───────────────────
            const Text("7-Day Forecast",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _forecast
                    .map((f) => Column(
                          children: [
                            Text(f['day'],
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade500)),
                            const SizedBox(height: 6),
                            Text(f['icon'],
                                style: const TextStyle(fontSize: 22)),
                            const SizedBox(height: 6),
                            Text("${f['high']}°",
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2E7D32))),
                            Text("${f['low']}°",
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade400)),
                          ],
                        ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 20),

            // ─── Crop Advisory ────────────────────
            const Text("Crop Advisory",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32))),
            const SizedBox(height: 12),
            ..._crops.map((crop) => _cropCard(crop)),

            const SizedBox(height: 20),

            // ─── Farming Tips ─────────────────────
            const Text("Today's Farming Tips",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32))),
            const SizedBox(height: 12),
            _tipCard("🌧️ Rain expected Wednesday",
                "Harvest sensitive crops before Wednesday to avoid moisture damage."),
            _tipCard("🌡️ High UV today",
                "Water crops in early morning or evening to reduce evaporation."),
            _tipCard("🍄 Humidity alert",
                "High humidity increases fungal risk. Inspect leaves for early signs."),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _weatherStat(String icon, String label, String value) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  Widget _cropCard(Map<String, dynamic> crop) {
    Color conditionColor;
    switch (crop['condition']) {
      case 'Good':
        conditionColor = Colors.green;
        break;
      case 'Moderate':
        conditionColor = Colors.orange;
        break;
      default:
        conditionColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Text(crop['icon'], style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(crop['name'],
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: conditionColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(crop['condition'],
                          style: TextStyle(
                              fontSize: 11,
                              color: conditionColor,
                              fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(crop['advice'],
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tipCard(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 4),
          Text(body,
              style:
                  TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
