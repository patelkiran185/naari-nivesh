import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:naari_nivesh/utils/BottomNavigation.dart';
import 'package:naari_nivesh/sub-screens/finhealth.dart';
import 'package:naari_nivesh/sub-screens/personalrecommend.dart';
import 'package:naari_nivesh/sub-screens/progress.dart';
import 'package:naari_nivesh/sub-screens/skilldashboard.dart';
import 'package:naari_nivesh/main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String userName = "User"; // Default value
  bool isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  void _fetchUserName() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          setState(() {
            userName = userDoc['name'] ?? "User";
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user name: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? 'Welcome...' : 'Welcome, $userName!',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.normal, letterSpacing: 1.2),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black45,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                childAspectRatio: 1.1,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildCard(
                    context: context,
                    title: 'Skill Monetization',
                    value: '3 Skills',
                    subtitle: 'Potential earnings: ₹5000/month',
                    icon: Icons.work,
                    screen: SkillDashboardScreen(),
                  ),
                  _buildCard(
                    context: context,
                    title: 'Personal Recommendation',
                    value: 'Start Saving',
                    subtitle: 'Set aside ₹100 weekly for emergencies',
                    icon: Icons.lightbulb,
                    screen: PersonalRecommendScreen(),
                  ),
                  _buildCard(
                    context: context,
                    title: 'Financial Health',
                    value: 'Good',
                    subtitle: 'You\'ve saved ₹1000 this month!',
                    icon: Icons.favorite,
                    screen: FinHealthScreen(),
                  ),
                  _buildCard(
                    context: context,
                    title: 'Progress Summary',
                    value: '75%',
                    subtitle: 'Completed 3 out of 4 financial goals',
                    icon: Icons.trending_up,
                    screen: ProgressScreen(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }

  void _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Logout failed: ${e.toString()}")),
      );
    }
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Widget screen,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis)),
                Icon(icon, size: 20, color: Colors.teal),
              ]),
              const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
