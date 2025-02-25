import 'package:flutter/material.dart';
import 'package:naari_nivesh/utils/BottomNavigation.dart';

class PersonalRecommendScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal Recommendation'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Personal Recommendation Screen Content'),
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: 2),
    );
  }
}