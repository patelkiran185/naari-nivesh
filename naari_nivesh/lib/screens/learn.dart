import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:naari_nivesh/utils/BottomNavigation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:naari_nivesh/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  String selectedLevel = '';
  Map<String, List<Map<String, String>>> lessons = {};
  Map<String, double> completionPercentage = {
    'Beginner': 0.0,
    'Intermediate': 0.0,
    'Advanced': 0.0
  };
  List<Map<String, String>> currentLessons = [];
  final String backendUrl = "http://${ip}:5000";
  Set<String> completedLessons = {};

  @override
  void initState() {
    super.initState();
    _fetchLessons();
    _loadCompletedLessons();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  // Load completed lessons from SharedPreferences
  Future<void> _loadCompletedLessons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      completedLessons = Set<String>.from(prefs.getStringList('completedLessons') ?? []);
      _calculateCompletionPercentages();
    });
  }

  // Save completed lessons to SharedPreferences
  Future<void> _saveCompletedLessons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completedLessons', completedLessons.toList());
  }

  // Calculate completion percentages for each level
  void _calculateCompletionPercentages() {
    for (var level in completionPercentage.keys) {
      if (lessons[level] == null || lessons[level]!.isEmpty) {
        completionPercentage[level] = 0.0;
      } else {
        int totalLessons = lessons[level]!.length;
        int completedCount = 0;
        
        for (var lesson in lessons[level]!) {
          if (completedLessons.contains('${level}:${lesson["title"]}')) {
            completedCount++;
          }
        }
        
        completionPercentage[level] = totalLessons > 0 
            ? (completedCount / totalLessons) * 100 
            : 0.0;
      }
    }
    setState(() {});
  }

  // Mark a lesson as complete
  void markLessonAsComplete(String lessonTitle) {
    setState(() {
      completedLessons.add('$selectedLevel:$lessonTitle');
      _saveCompletedLessons();
      _calculateCompletionPercentages();
    });
  }

  Future<void> _fetchLessons() async {
    try {
      final levels = ['beginner', 'intermediate', 'advanced'];
      Map<String, List<Map<String, String>>> loadedLessons = {};

      for (var level in levels) {
        final response = await http.get(Uri.parse('$backendUrl/lessons/$level'));

        if (response.statusCode == 200) {
          List<dynamic> lessonList = jsonDecode(response.body);
          loadedLessons[_capitalize(level)] = lessonList.map<Map<String, String>>((lesson) {
            return {
              "title": lesson["title"].toString(),
              "description": lesson["description"].toString()
            };
          }).toList();
        }
      }

      setState(() {
        lessons = loadedLessons;
        _calculateCompletionPercentages();
      });
    } catch (e) {
      print("Error fetching lessons: $e");
    }
  }

  void _selectLevel(String level) {
    if (lessons[level] == null) {
      return;
    }
    setState(() {
      selectedLevel = level;
      currentLessons = lessons[level] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Learn'), backgroundColor: Colors.teal),
      body: selectedLevel.isEmpty ? _buildLevelSelection() : _buildLessonList(),
      bottomNavigationBar: BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildLevelSelection() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text('Select Your Level', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        Expanded(
          child: ListView(
            children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
              return InkWell(
                onTap: () => _selectLevel(level),
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  color: Colors.teal.shade100,
                  child: ListTile(
                    title: Text(level, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('Completion: ${completionPercentage[level]!.toStringAsFixed(0)}%'),
                    trailing: Icon(Icons.arrow_forward_ios),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildLessonList() {
    return Column(
      children: [
        ListTile(
          leading: Icon(Icons.arrow_back),
          title: Text('$selectedLevel Lessons', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          onTap: () => setState(() => selectedLevel = ''),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: currentLessons.length,
            itemBuilder: (context, index) {
              String title = currentLessons[index]["title"]!;
              bool isCompleted = completedLessons.contains('$selectedLevel:$title');
              
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  title: Row(
                    children: [
                      Text(title, style: TextStyle(fontSize: 16)),
                      if (isCompleted)
                        Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(Icons.check_circle, color: Colors.green, size: 18)
                        )
                    ],
                  ),
                  subtitle: Text(currentLessons[index]["description"]!),
                  trailing: Icon(Icons.arrow_forward_ios),
                  onTap: () => _openLesson(title),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openLesson(String lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LessonScreen(
          lesson: lesson, 
          level: selectedLevel,
          onLessonComplete: markLessonAsComplete,
          isCompleted: completedLessons.contains('$selectedLevel:$lesson'),
        )
      ),
    ).then((_) {
      // Refresh after returning from lesson screen
      setState(() {});
    });
  }
}

class LessonScreen extends StatefulWidget {
  final String lesson;
  final String level;
  final Function(String) onLessonComplete;
  final bool isCompleted;
  
  LessonScreen({
    required this.lesson, 
    required this.level,
    required this.onLessonComplete,
    required this.isCompleted,
  });

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  String lessonContent = "Loading...";
  List<Map<String, dynamic>> quizQuestions = [];
  final String backendUrl = "http://${ip}:5000";
  bool isLessonCompleted = false;

  @override
  void initState() {
    super.initState();
    isLessonCompleted = widget.isCompleted;
    _fetchLessonContent();
  }
  
  Future<void> _fetchLessonContent() async {
    try {
      final response = await http.get(Uri.parse('$backendUrl/generate_lesson/${Uri.encodeComponent(widget.lesson)}'));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        // Debugging info
        print("Response Data Type: ${data.runtimeType}");
        print("Content Type: ${data['content'].runtimeType}");
        print("MCQs Type: ${data['mcqs'].runtimeType}");

        String content = data["content"] ?? "No content available";
        List<Map<String, dynamic>> parsedMcqs = [];

        // ✅ **Fix Heading Formatting in Content**
        content = content.replaceAllMapped(RegExp(r'\*{3}([^\*]+)\*{2}'), (match) {
          return "**${match.group(1)}**"; // Proper bold formatting
        });

        // ✅ **Handle Different MCQs Formats**
        if (data["mcqs"] is List) {
          parsedMcqs = List<Map<String, dynamic>>.from(
            data["mcqs"].map((q) => Map<String, dynamic>.from(q))
          );
        } else if (data["mcqs"] is String) {
          try {
            String mcqsString = data["mcqs"];

            // Remove Markdown code block indicators if present
            if (mcqsString.contains("```json")) {
              mcqsString = mcqsString.replaceAll("```json", "").replaceAll("```", "").trim();
            }

            parsedMcqs = List<Map<String, dynamic>>.from(jsonDecode(mcqsString));
          } catch (e) {
            print("Error parsing MCQs string: $e");
          }
        }

        // ✅ **Update State**
        setState(() {
          lessonContent = content;
          quizQuestions = parsedMcqs;
        });

        print("Loaded ${quizQuestions.length} quiz questions.");
      } else {
        print("HTTP Error: ${response.statusCode}");
        setState(() {
          lessonContent = "Error loading lesson content (HTTP ${response.statusCode})";
          quizQuestions = [];
        });
      }
    } catch (e) {
      print("Error fetching lesson content: $e");
      setState(() {
        lessonContent = "Error loading lesson content: $e";
        quizQuestions = [];
      });
    }
  }

  // ✅ **Start Quiz Function with User Feedback**
  void _startQuiz() {
    if (quizQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Quiz questions are still loading. Please wait.")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          questions: quizQuestions,
          onQuizComplete: _handleQuizComplete,
        )
      ),
    );
  }

  // Handle quiz completion
  void _handleQuizComplete(int score, int total) {
    double percentage = (score / total) * 100;
    
    // If score is >= 70% and not already completed
    if (percentage >= 70 && !isLessonCompleted) {
      setState(() {
        isLessonCompleted = true;
      });
      
      // Mark the lesson as complete in parent
      widget.onLessonComplete(widget.lesson);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Congratulations! Lesson marked as complete."),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.lesson),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.lesson,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                if (isLessonCompleted)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green)
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 16),
                        SizedBox(width: 4),
                        Text('Completed', style: TextStyle(color: Colors.green.shade800, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
              ],
            ),
            SizedBox(height: 16),
            MarkdownBody(data: lessonContent),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _startQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text("Take Quiz", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final Function(int score, int total)? onQuizComplete;
  
  QuizScreen({
    required this.questions,
    this.onQuizComplete,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  Map<int, String> selectedAnswers = {};
  bool quizCompleted = false;
  int correctAnswers = 0;
  bool showFeedback = false;

  @override
  void initState() {
    super.initState();
    // Initialize score
    correctAnswers = 0;
  }

  void _selectAnswer(String answer) {
    setState(() {
      // Store the previous answer before updating
      String? previousAnswer = selectedAnswers[currentQuestionIndex];
      
      // Update the selected answer
      selectedAnswers[currentQuestionIndex] = answer;
      showFeedback = true;
      
      // Get the correct answer for the current question
      String correctAnswer = widget.questions[currentQuestionIndex]['answer'];
      
      // Update the score based on the new answer
      if (answer == correctAnswer) {
        // Only increment if this is a new correct answer
        if (previousAnswer != correctAnswer) {
          correctAnswers++;
        }
      } else {
        // If changing from correct to incorrect, decrement
        if (previousAnswer == correctAnswer) {
          correctAnswers--;
        }
      }
    });
  }

  void _nextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        showFeedback = false;
      });
    } else {
      setState(() {
        quizCompleted = true;
      });
      
      // Call callback when quiz is completed
      if (widget.onQuizComplete != null) {
        widget.onQuizComplete!(correctAnswers, widget.questions.length);
      }
    }
  }

  void _previousQuestion() {
    if (currentQuestionIndex > 0) {
      setState(() {
        currentQuestionIndex--;
        showFeedback = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text("Quiz"), backgroundColor: Colors.teal),
        body: Center(child: Text("No questions available.")),
      );
    }

    if (quizCompleted) {
      return _buildResultScreen();
    }

    var currentQuestion = widget.questions[currentQuestionIndex];
    List<String> options = List<String>.from(currentQuestion['options']);
    String correctAnswer = currentQuestion['answer'];

    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Question ${currentQuestionIndex + 1} of ${widget.questions.length}",
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            SizedBox(height: 16),
            Text(
              currentQuestion['question'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            ...options.map((option) {
              bool isSelected = selectedAnswers[currentQuestionIndex] == option;
              bool isCorrect = option == correctAnswer;
              
              // Determine the color based on feedback state
              Color borderColor = Colors.grey[300]!;
              Color backgroundColor = Colors.white;
              
              if (showFeedback) {
                if (isCorrect) {
                  borderColor = Colors.green;
                  backgroundColor = Colors.green.withOpacity(0.1);
                } else if (isSelected && !isCorrect) {
                  borderColor = Colors.red;
                  backgroundColor = Colors.red.withOpacity(0.1);
                }
              } else if (isSelected) {
                borderColor = Colors.teal;
                backgroundColor = Colors.teal.withOpacity(0.1);
              }
              
              return Container(
                margin: EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: showFeedback ? null : () => _selectAnswer(option),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: borderColor,
                        width: isSelected || (showFeedback && isCorrect) ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: backgroundColor,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: showFeedback 
                                  ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.grey[400]!))
                                  : (isSelected ? Colors.teal : Colors.grey[400]!),
                              width: 2,
                            ),
                            color: showFeedback 
                                ? (isCorrect ? Colors.green : (isSelected ? Colors.red : Colors.white))
                                : (isSelected ? Colors.teal : Colors.white),
                          ),
                          child: (showFeedback && isCorrect) || isSelected
                              ? Icon(
                                  showFeedback && isCorrect ? Icons.check : (isSelected ? Icons.check : null),
                                  size: 16,
                                  color: Colors.white
                                )
                              : null,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: 16,
                              color: showFeedback
                                  ? (isCorrect ? Colors.green[800] : (isSelected ? Colors.red[800] : Colors.black))
                                  : Colors.black,
                            ),
                          ),
                        ),
                        if (showFeedback && isCorrect)
                          Icon(Icons.check_circle, color: Colors.green),
                        if (showFeedback && isSelected && !isCorrect)
                          Icon(Icons.cancel, color: Colors.red),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
            SizedBox(height: 16),
            if (showFeedback)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      selectedAnswers[currentQuestionIndex] == correctAnswer
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: selectedAnswers[currentQuestionIndex] == correctAnswer
                          ? Colors.green
                          : Colors.red,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedAnswers[currentQuestionIndex] == correctAnswer
                            ? "Correct! Well done."
                            : "Incorrect. The correct answer is: $correctAnswer",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: selectedAnswers[currentQuestionIndex] == correctAnswer
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (currentQuestionIndex > 0)
                  ElevatedButton(
                    onPressed: _previousQuestion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                    ),
                    child: Text("Previous"),
                  )
                else
                  SizedBox(width: 88), // placeholder for spacing
                ElevatedButton(
                  onPressed: selectedAnswers[currentQuestionIndex] != null
                      ? _nextQuestion
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  child: Text(
                    currentQuestionIndex < widget.questions.length - 1
                        ? "Next"
                        : "Finish",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    double percentage = (correctAnswers / widget.questions.length) * 100;
    bool passedQuiz = percentage >= 70;
    
    return Scaffold(
      appBar: AppBar(
        title: Text("Quiz Results"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              passedQuiz ? Icons.emoji_events : Icons.school,
              size: 80,
              color: passedQuiz ? Colors.teal : Colors.orange,
            ),
            SizedBox(height: 24),
            Text(
              "Quiz Completed!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              "You scored $correctAnswers out of ${widget.questions.length}",
              style: TextStyle(fontSize: 18),
            ),
            Text(
              "${percentage.toStringAsFixed(0)}%",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: passedQuiz ? Colors.teal : Colors.orange,
              ),
            ),
            SizedBox(height: 32),
            if (passedQuiz)
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text(
                      "Congratulations! You've passed the quiz!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "This lesson has been marked as complete.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.green.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Column(
                  children: [
                    Text(
                      "Almost there!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      "You need to score at least 70% to complete this lesson.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.orange.shade800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: Text("Back to Lesson", style: TextStyle(fontSize: 16)),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  currentQuestionIndex = 0;
                  selectedAnswers.clear();
                  quizCompleted = false;
                  correctAnswers = 0;
                  showFeedback = false;
                });
              },
              child: Text("Retake Quiz", style: TextStyle(color: Colors.teal)),
            ),
            SizedBox(height: 24),
            // Review answers section
            Expanded(
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  var question = widget.questions[index];
                  var selectedAnswer = selectedAnswers[index];
                  var isCorrect = selectedAnswer == question['answer'];
                  
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Question ${index + 1}",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(question['question']),
                          SizedBox(height: 8),
                          Text(
                            "Your answer: $selectedAnswer",
                            style: TextStyle(
                              color: isCorrect ? Colors.green[800] : Colors.red[800],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (!isCorrect)
                            Text(
                              "Correct answer: ${question['answer']}",
                              style: TextStyle(
                                color: Colors.green[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}