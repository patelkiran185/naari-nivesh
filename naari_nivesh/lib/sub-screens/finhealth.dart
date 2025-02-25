import 'package:flutter/material.dart';
import 'package:naari_nivesh/utils/BottomNavigation.dart';

class FinHealthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Health'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Text('Financial Health Screen Content'),
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: 2),
    );
  }
}