import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:naari_nivesh/constants.dart';
import 'dart:convert';
//import 'screens/scenario.dart'; // Import the ScenarioScreen

class CrisisScreen extends StatefulWidget {
  CrisisScreen({Key? key}) : super(key: key);

  @override
  _CrisisScreenState createState() => _CrisisScreenState();
}

class _CrisisScreenState extends State<CrisisScreen> {
  bool isLoading = false; // ✅ Track if the request is in progress

  final Map<String, int> levelMapping = {
    'Basic Emergency': 1,
    'Health Crisis': 2,
    'Job Loss': 3,
    'Financial Debt': 4,
    'Family Emergency': 5,
    'Natural Disaster': 6,
  };

  void _showPopup(BuildContext context, String level) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Start this level?'),
          content: Text('Do you want to start $level?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(
                  dialogContext,
                ).pop(); // Close dialog before navigation
                Navigator.pushNamed(
                  context,
                  '/scenario',
                  arguments: {'level': levelMapping[level]},
                );
              },
              child: Text('Start'),
            ),
          ],
        );
      },
    );
  }

  void _showStartSimulationPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Welcome!'),
          content: Text('Start your simulation today!'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Let's Begin!"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crisis Readiness Roadmap'),
        backgroundColor: Colors.teal,
      ),
      body: Stack(
        children: [
          InteractiveViewer(
            boundaryMargin: EdgeInsets.all(0),
            minScale: 1.0,
            maxScale: 3.0,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/roadmap.jpeg',
                    fit: BoxFit.cover,
                  ),
                ),
                _buildClickableAreas(context),
              ],
            ),
          ),

          // ✅ Show loading overlay when request is in progress
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(
                  0.5,
                ), // Semi-transparent overlay
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        "Loading, please wait...",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClickableAreas(BuildContext context) {
    return Stack(
      children: [
        _positionedArea(context, 'Basic Emergency', left: 20, bottom: 150),
        _positionedArea(context, 'Health Crisis', left: 20, top: 150),
        _positionedArea(
          context,
          'Financial Debt',
          left: MediaQuery.of(context).size.width / 2 - 75,
          top: 50,
        ),
        _positionedArea(
          context,
          'Job Loss',
          left: MediaQuery.of(context).size.width / 2 - 75,
          top: MediaQuery.of(context).size.height / 2 - 75,
        ),
        _positionedArea(
          context,
          'Family Emergency',
          right: 20,
          top: MediaQuery.of(context).size.height / 2 - 75,
        ),
        _positionedArea(context, 'Natural Disaster', right: 20, bottom: 50),
        Positioned(
          bottom: 50,
          left: 20,
          child: GestureDetector(
            onTap: () => _showStartSimulationPopup(context),
            child: Container(
              width: 150,
              height: 150,
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _positionedArea(
    BuildContext context,
    String level, {
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: GestureDetector(
        onTap: () => _showPopup(context, level),
        child: Container(width: 150, height: 150, color: Colors.transparent),
      ),
    );
  }
}
