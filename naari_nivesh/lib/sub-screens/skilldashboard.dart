import 'package:flutter/material.dart';
import 'package:naari_nivesh/utils/BottomNavigation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:lottie/lottie.dart';

// Previous model classes remain the same...
class UserProfile {
  final String name;
  final List<Skill> skills;
  final String location;
  final List<String> interests;
  final int totalEarnings;
  final int activeOrders;
  final double rating;

  UserProfile({
    required this.name,
    required this.skills,
    required this.location,
    required this.interests,
    required this.totalEarnings,
    required this.activeOrders,
    required this.rating,
  });
}

class Skill {
  final String name;
  final int proficiencyLevel;
  final List<String> monetizationOptions;
  final double suggestedPrice;
  final String icon;
  final double growth;
  final int totalOrders;

  Skill({
    required this.name,
    required this.proficiencyLevel,
    required this.monetizationOptions,
    required this.suggestedPrice,
    required this.icon,
    required this.growth,
    required this.totalOrders,
  });
}

class SkillDashboardScreen extends StatefulWidget {
  @override
  _SkillDashboardScreenState createState() => _SkillDashboardScreenState();
}

class _SkillDashboardScreenState extends State<SkillDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  final UserProfile profile = UserProfile(
    name: "Lakshmi Devi",
    location: "Rajasthan",
    totalEarnings: 25000,
    activeOrders: 3,
    rating: 4.8,
    skills: [
      Skill(
        name: "Hand Embroidery",
        proficiencyLevel: 4,
        monetizationOptions: [
          "Custom wedding clothes",
          "Teaching workshops",
          "Local handicraft marketplace",
        ],
        suggestedPrice: 500.0,
        icon: "🧵",
        growth: 15.5,
        totalOrders: 24,
      ),
      Skill(
        name: "Pickle Making",
        proficiencyLevel: 5,
        monetizationOptions: [
          "Weekly market stall",
          "Bulk festival orders",
          "Home delivery service",
        ],
        suggestedPrice: 150.0,
        icon: "🥫",
        growth: 22.3,
        totalOrders: 45,
      ),
      Skill(
        name: "Jam Making",
        proficiencyLevel: 4,
        monetizationOptions: [
          "Online store",
          "Farmer's market",
          "Subscription boxes",
        ],
        suggestedPrice: 200.0,
        icon: "🍓",
        growth: 18.5,
        totalOrders: 30,
      ),
    ],
    interests: ["Textile Arts", "Food Processing", "Local Markets"],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Custom App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1DE9B6),
                      Color(0xFF0097A7),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    SafeArea(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Skill Dashboard',
                              style: GoogleFonts.poppins(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 8),
                            AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'Turn your skills into income!',
                                  textStyle: GoogleFonts.poppins(
                                    fontSize: 20,
                                    color: Colors.white70,
                                  ),
                                  speed: Duration(milliseconds: 100),
                                ),
                              ],
                              totalRepeatCount: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Cards Row
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildStatsCard(
                          "Total Earnings",
                          "₹${profile.totalEarnings}",
                          Icons.currency_rupee,
                          Colors.green,
                        ),
                        _buildStatsCard(
                          "Active Orders",
                          "${profile.activeOrders}",
                          Icons.shopping_bag,
                          Colors.orange,
                        ),
                        _buildStatsCard(
                          "Rating",
                          "${profile.rating}",
                          Icons.star,
                          Colors.amber,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 15),

                  // Skills Section
                  Text(
                    "Your Skills",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  // SizedBox(height: 0),

                  // Enhanced Skills Cards
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: profile.skills.length,
                    itemBuilder: (context, index) {
                      final skill = profile.skills[index];
                      return _buildEnhancedSkillCard(skill);
                    },
                  ),

                  SizedBox(height: 24),

                  // Action Buttons with Gradients
                  Row(
                    children: [
                      Expanded(
                        child: _buildGradientButton(
                          "Find Markets",
                          Icons.storefront,
                          [
                            Color.fromARGB(255, 67, 230, 208),
                            Color(0xFF00796B)
                          ],
                          () {},
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: _buildGradientButton(
                          "Add Skill",
                          Icons.add_circle,
                          [
                            Color.fromARGB(255, 67, 230, 208),
                            Color(0xFF00796B)
                          ],
                          () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: 2),
    );
  }

  Widget _buildStatsCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      margin: EdgeInsets.only(right: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.teal.shade700, width: 1),
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        width: 160,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade700,
              ),
            ),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedSkillCard(Skill skill) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.teal.shade50],
          ),
        ),
        child: ExpansionTile(
          leading: Text(
            skill.icon,
            style: TextStyle(fontSize: 24),
          ),
          title: Text(
            skill.name,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.teal.shade700,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                Icons.trending_up,
                color: Colors.green,
                size: 16,
              ),
              Text(
                " ${skill.growth}% growth",
                style: GoogleFonts.poppins(
                  color: Colors.green,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Suggested Price",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            "₹${skill.suggestedPrice.toStringAsFixed(0)}",
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade700,
                            ),
                          ),
                        ],
                      ),
                      CircularPercentIndicator(
                        radius: 30.0,
                        lineWidth: 5.0,
                        percent: skill.proficiencyLevel / 5,
                        center: Text(
                          "${(skill.proficiencyLevel * 20)}%",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        progressColor: Colors.teal,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    "Business Opportunities",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  SizedBox(height: 8),
                  ...skill.monetizationOptions.map(
                    (option) => ListTile(
                      leading: Icon(Icons.check_circle, color: Colors.teal),
                      title: Text(
                        option,
                        style: GoogleFonts.poppins(fontSize: 14),
                      ),
                      dense: true,
                    ),
                  ),
                  SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      side: BorderSide(color: Colors.teal),
                    ),
                    child: Text(
                      "View Details",
                      style: GoogleFonts.poppins(color: Colors.teal),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(
    String text,
    IconData icon,
    List<Color> colors,
    VoidCallback onPressed,
  ) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
