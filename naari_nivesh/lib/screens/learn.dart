import 'package:flutter/material.dart';
import 'package:naari_nivesh/utils/BottomNavigation.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearningScreenState createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearnScreen> {
  String selectedDifficulty = 'Medium';
  int currentModule = 1;
  int score = 0;

  final List<String> modules = [
    'Basics of Saving',
    'Budgeting Skills',
    'Understanding Loans',
    'Investment Fundamentals',
    'Financial Planning'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nari Shiksha'),
         backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
        actions: [
    
          PopupMenuButton<String>(
            icon: Icon(Icons.filter_list),
            onSelected: (String difficulty) {
              setState(() {
                selectedDifficulty = difficulty;
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'Low',
                child: Text('Beginner'),
              ),
              PopupMenuItem<String>(
                value: 'Medium',
                child: Text('Intermediate'),
              ),
              PopupMenuItem<String>(
                value: 'High',
                child: Text('Advanced'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProgressBar(),
          _buildModuleSelector(),
          Expanded(
            child: _buildLearningGame(),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Progress',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal),
          ),
          SizedBox(height: 8),
          Text(
            'Score: $score / 100',
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildModuleSelector() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: modules.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              setState(() {
                currentModule = index + 1;
              });
            },
            child: Container(
              width: 100,
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: currentModule == index + 1 ? Colors.teal : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getModuleIcon(index),
                    color: currentModule == index + 1 ? Colors.white : Colors.black,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Module ${index + 1}',
                    style: TextStyle(
                      color: currentModule == index + 1 ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getModuleIcon(int index) {
    switch (index) {
      case 0:
        return Icons.savings;
      case 1:
        return Icons.account_balance_wallet;
      case 2:
        return Icons.monetization_on;
      case 3:
        return Icons.trending_up;
      case 4:
        return Icons.event_note;
      default:
        return Icons.book;
    }
  }

  Widget _buildLearningGame() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Module $currentModule: ${modules[currentModule - 1]}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 16),
          Text(
            'Difficulty: $selectedDifficulty',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          SizedBox(height: 24),
          _buildGameContent(),
        ],
      ),
    );
  }

  Widget _buildGameContent() {
    // This is a placeholder for the actual game content
    // You would replace this with your actual game logic
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Question:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        Text(
          'What is the best way to start saving money?',
          style: TextStyle(fontSize: 16),
        ),
        SizedBox(height: 16),
        _buildAnswerOption('Set aside a fixed amount each month', true),
        _buildAnswerOption('Spend all your money and save later', false),
        _buildAnswerOption('Borrow money to save', false),
        _buildAnswerOption('Wait for a windfall to start saving', false),
      ],
    );
  }

  Widget _buildAnswerOption(String answer, bool isCorrect) {
    return GestureDetector(
      onTap: () {
        // Handle answer selection
        if (isCorrect) {
          setState(() {
            score += 10;
          });
          _showCorrectAnswerDialog();
        } else {
          _showIncorrectAnswerDialog();
        }
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(answer),
      ),
    );
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Correct!'),
          content: Text('Great job! You\'ve earned 10 points.'),
          actions: <Widget>[
            TextButton(
              child: Text('Next Question'),
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Load next question
              },
            ),
          ],
        );
      },
    );
  }

  void _showIncorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Incorrect'),
          content: Text('That\'s not quite right. Try again!'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

