import 'package:flutter/material.dart';
import 'package:iptvmobile/routes/routes_names.dart';

class PlanScreen extends StatelessWidget {
  const PlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF3E1F1F),
        elevation: 0,
        leading: const Icon(Icons.arrow_back),
        title: const Text("My Plan"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔥 TOP BANNER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF3E1F1F),
              ),
              child: Column(
                children: [
                  const Text(
                    "One Stop For All Your Favourite\nOTT Subscriptions",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 15),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset("assets/images/plan_logo.png"),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "SUBSCRIBE TO WATCH",
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 10),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () {
                      Navigator.pushReplacementNamed(
                        context,
                        RouteNames.dashBoardScreenn,
                      );
                    },
                    child: const Text("SUBSCRIBE NOW"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 ₹99 PLAN
            _planCard(
              title: "24 OTTs",
              oldPrice: "₹ 150",
              newPrice: "₹ 99",
              duration: "monthly",
              topLogos: [
                "assets/images/z5.png",
                "assets/images/sony.png",
              ],
            ),

            // 🔥 ₹199 PLAN
            _planCard(
              title: "24 OTTs",
              oldPrice: "₹ 199",
              newPrice: "₹ 199",
              duration: "quarterly",
              topLogos: [
                "assets/images/z5.png",
                "assets/images/sony.png",
                "assets/images/jio.png",
              ],
            ),

            // 🔥 ₹299 PLAN
            _planCard(
              title: "24 OTTs",
              oldPrice: "₹ 299",
              newPrice: "₹ 299",
              duration: "yearly",
              topLogos: [
                "assets/images/z5.png",
                "assets/images/sony.png",
                "assets/images/jio.png",
                "assets/images/prime_video.png",
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 PLAN CARD
  Widget _planCard({
    required String title,
    required String oldPrice,
    required String newPrice,
    required String duration,
    required List<String> topLogos,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "TRENDING OFFER",
            style: TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 5),

          Row(
            children: [
              Text(title, style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 10),
              Text(
                oldPrice,
                style: const TextStyle(
                  color: Colors.grey,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
              const SizedBox(width: 5),
              Text(newPrice, style: const TextStyle(color: Colors.white)),
              const SizedBox(width: 5),
              Text(duration,
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),

          const SizedBox(height: 10),

          const Text(
            "Watch these premium OTT apps",
            style: TextStyle(color: Colors.blue),
          ),

          const SizedBox(height: 10),

          // 🔥 BIG LOGOS
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 10,
            children: topLogos.map((e) => _bigLogo(e)).toList(),
          ),

          const SizedBox(height: 12),

          // 🔥 ONLY ONE IMAGE BELOW
          Center(
            child: _bottomImage("assets/images/plan_logo1.png"),
          ),

          const SizedBox(height: 15),

          // 🔥 BUTTON
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onPressed: () {},
              child: Text("Subscribe Now for $newPrice"),
            ),
          ),
        ],
      ),
    );
  }

  // 🔥 BIG LOGO
  Widget _bigLogo(String path) {
    return Container(
      height: 50,
      width: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Image.asset(path, fit: BoxFit.contain),
    );
  }

  // 🔥 BOTTOM IMAGE (SINGLE)
  Widget _bottomImage(String path) {
    return Container(
      height: 300,
      width: 400,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Image.asset(path, fit: BoxFit.contain),
    );
  }
}