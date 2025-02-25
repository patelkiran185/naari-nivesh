import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:naari_nivesh/sub-screens/mentor_profile.dart';
import 'package:naari_nivesh/utils/BottomNavigation.dart';

class MentorScreen extends StatefulWidget {
  const MentorScreen({super.key});

  @override
  State<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends State<MentorScreen> {
  final List<MentorCard> mentors = [
    MentorCard(
      name: 'Mentor 1',
      description: 'Empowering women in finance and investment.',
      imageUrl: 'assets/images/profile.png',
    ),
    MentorCard(
      name: 'Mentor 2',
      description: 'Expert in personal finance management for women.',
      imageUrl: 'assets/images/profile.png',
    ),
    MentorCard(
      name: 'Mentor 3',
      description: 'Specialist in stock market investments for women.',
      imageUrl: 'assets/images/profile.png',
    ),
    MentorCard(
      name: 'Mentor 4',
      description: 'Advisor for women\'s retirement planning.',
      imageUrl: 'assets/images/profile.png',
    ),
    MentorCard(
      name: 'Mentor 5',
      description: 'Consultant for women in real estate investments.',
      imageUrl: 'assets/images/profile.png',
    ),
    MentorCard(
      name: 'Mentor 6',
      description: 'Expert in mutual funds and SIPs for women.',
      imageUrl: 'assets/images/profile.png',
    ),
    MentorCard(
      name: 'Mentor 7',
      description: 'Financial advisor for women\'s tax planning.',
      imageUrl: 'assets/images/profile.png',
    ),
    MentorCard(
      name: 'Mentor 8',
      description: 'Specialist in cryptocurrency investments for women.',
      imageUrl: 'assets/images/profile.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Connect with Mentors',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: Colors.black45,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Swiper(
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(16),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.asset(
                    mentors[index].imageUrl,
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  mentors[index].name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mentors[index].description,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MentorProfileScreen(
                            name: mentors[index].name,
                            description: mentors[index].description,
                            imageUrl: mentors[index].imageUrl,
                            expertise: "Finance & Investment",
                            experience: "10+ years",
                            contact: "mentor@example.com",
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.person, size: 20), 
                    label: const Text('Profile', style: TextStyle(fontSize: 16)),
                  ),
                ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.teal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                        },
                        icon: const Icon(Icons.message, color: Colors.teal, size: 20),  
                        label: const Text(
                          'Connect',
                          style: TextStyle(color: Colors.teal, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),

                              ],
                            ),
                          ),
                        ),
                        itemCount: mentors.length,
                        itemWidth: MediaQuery.of(context).size.width * 0.8,
                        itemHeight: MediaQuery.of(context).size.height * 0.65,
                        layout: SwiperLayout.STACK,
                      ),
                      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
                    );
                  }
                }

                class MentorCard {
                  final String name;
                  final String description;
                  final String imageUrl;

                  MentorCard({
                    required this.name,
                    required this.description,
                    required this.imageUrl,
                  });
                }
