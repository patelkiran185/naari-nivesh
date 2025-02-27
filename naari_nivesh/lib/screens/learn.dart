import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:naari_nivesh/utils/BottomNavigation.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:naari_nivesh/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class LearnScreen extends StatefulWidget {
  @override
  _LearnScreenState createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> with SingleTickerProviderStateMixin {
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
  late AnimationController _animationController;
  String selectedLanguage = "English"; // Default language

  @override
  void initState() {
    super.initState();
    _fetchLessons();
    _loadCompletedLessons();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<void> _loadCompletedLessons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      completedLessons = Set<String>.from(prefs.getStringList('completedLessons') ?? []);
      _calculateCompletionPercentages();
    });
  }

  Future<void> _saveCompletedLessons() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('completedLessons', completedLessons.toList());
  }

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
        final response = await http.get(
          Uri.parse('$backendUrl/lessons/$level?language=$selectedLanguage'),
        );

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
    _animationController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text('Learning Path', style: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
        )),
        backgroundColor: Colors.teal.shade700,
        actions: [
          // Language selection dropdown
          DropdownButton<String>(
            value: selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                selectedLanguage = newValue!;
                _fetchLessons(); // Fetch lessons with the new language
              });
            },
            items: <String>["English", "Hindi", "Tamil", "Telugu"]
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _fetchLessons();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Refreshing content...'),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: selectedLevel.isEmpty ? _buildLevelSelection() : _buildLessonList(),
      ),
      bottomNavigationBar: BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildLevelSelection() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.teal.shade700,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Start Your Learning Journey',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Select your proficiency level to begin',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 24),
        Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: ['Beginner', 'Intermediate', 'Advanced'].map((level) {
              double percentage = completionPercentage[level]!;
              Color cardColor;
              IconData levelIcon;
              
              switch (level) {
                case 'Beginner':
                  cardColor = Colors.teal.shade600;
                  levelIcon = Icons.emoji_objects_outlined;
                  break;
                case 'Intermediate':
                  cardColor = Colors.indigo.shade600;
                  levelIcon = Icons.trending_up;
                  break;
                case 'Advanced':
                  cardColor = Colors.deepPurple.shade600;
                  levelIcon = Icons.psychology;
                  break;
                default:
                  cardColor = Colors.teal.shade600;
                  levelIcon = Icons.emoji_objects_outlined;
              }
              
              return Container(
                margin: EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _selectLevel(level),
                    borderRadius: BorderRadius.circular(16),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            cardColor,
                            cardColor.withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Icon(
                                  levelIcon,
                                  color: Colors.white,
                                  size: 36,
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${percentage.toStringAsFixed(0)}% Complete',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              level,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 10),
                            Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.white38,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: (MediaQuery.of(context).size.width - 40) * (percentage / 100),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
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
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      )),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.teal.shade700,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => setState(() => selectedLevel = ''),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Back to Levels',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        selectedLevel == 'Beginner' 
                            ? Icons.emoji_objects_outlined 
                            : (selectedLevel == 'Intermediate' 
                                ? Icons.trending_up 
                                : Icons.psychology),
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$selectedLevel Level',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '${currentLessons.length} lessons available',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
              itemCount: currentLessons.length,
              itemBuilder: (context, index) {
                String title = currentLessons[index]["title"]!;
                String description = currentLessons[index]["description"]!;
                bool isCompleted = completedLessons.contains('$selectedLevel:$title');
                
                return Container(
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => _openLesson(title),
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isCompleted ? Colors.green.shade50 : Colors.teal.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isCompleted ? Icons.check_circle : Icons.play_circle_filled,
                                    color: isCompleted ? Colors.green.shade600 : Colors.teal.shade600,
                                    size: 20,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: GoogleFonts.poppins(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      isCompleted 
                                        ? Container(
                                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade100,
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              'Completed',
                                              style: GoogleFonts.poppins(
                                                color: Colors.green.shade800,
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                          )
                                        : Text(
                                            'Tap to start learning',
                                            style: GoogleFonts.poppins(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Colors.grey.shade400,
                                  size: 14,
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Padding(
                              padding: EdgeInsets.only(left: 42),
                              child: Text(
                                description,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
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
          language: selectedLanguage, // Pass the selected language
        )
      ),
    ).then((_) {
      setState(() {});
    });
  }
}

class LessonScreen extends StatefulWidget {
  final String lesson;
  final String level;
  final Function(String) onLessonComplete;
  final bool isCompleted;
  final String language; // Add language parameter
  
  LessonScreen({
    required this.lesson, 
    required this.level,
    required this.onLessonComplete,
    required this.isCompleted,
    required this.language, // Add language parameter
  });

  @override
  _LessonScreenState createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  String lessonContent = "Loading...";
  List<Map<String, dynamic>> quizQuestions = [];
  final String backendUrl = "http://${ip}:5000";
  bool isLessonCompleted = false;
  bool isLoading = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    isLessonCompleted = widget.isCompleted;
    _fetchLessonContent();
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  Future<void> _fetchLessonContent() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      final response = await http.get(
        Uri.parse('$backendUrl/generate_lesson/${Uri.encodeComponent(widget.lesson)}?language=${widget.language}'),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);

        String content = data["content"] ?? "No content available";
        List<Map<String, dynamic>> parsedMcqs = [];

        content = content.replaceAllMapped(RegExp(r'\*{3}([^\*]+)\*{2}'), (match) {
          return "**${match.group(1)}**";
        });

        if (data["mcqs"] is List) {
          parsedMcqs = List<Map<String, dynamic>>.from(
            data["mcqs"].map((q) => Map<String, dynamic>.from(q))
          );
        } else if (data["mcqs"] is String) {
          try {
            String mcqsString = data["mcqs"];

            if (mcqsString.contains("```json")) {
              mcqsString = mcqsString.replaceAll("```json", "").replaceAll("```", "").trim();
            }

            parsedMcqs = List<Map<String, dynamic>>.from(jsonDecode(mcqsString));
          } catch (e) {
            setState(() {
              lessonContent = "Error loading lesson content: $e";
              quizQuestions = [];
              isLoading = false;
            });
          }
        }

        setState(() {
          lessonContent = content;
          quizQuestions = parsedMcqs;
          isLoading = false;
        });
      } else {
        setState(() {
          lessonContent = "Error loading lesson content (HTTP ${response.statusCode})";
          quizQuestions = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        lessonContent = "Error loading lesson content: $e";
        quizQuestions = [];
        isLoading = false;
      });
    }
  }

  void _startQuiz() {
    if (quizQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Quiz questions are still loading. Please wait."),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizScreen(
          questions: quizQuestions,
          onQuizComplete: _handleQuizComplete,
          lessonTitle: widget.lesson,
        )
      ),
    );
  }

  void _handleQuizComplete(int score, int total) {
    double percentage = (score / total) * 100;
    
    if (percentage >= 70 && !isLessonCompleted) {
      setState(() {
        isLessonCompleted = true;
      });
      
      widget.onLessonComplete(widget.lesson);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Congratulations! Lesson marked as complete."),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              backgroundColor: Colors.teal.shade700,
              leading: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.lesson,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.teal.shade800, Colors.teal.shade600],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -50,
                        bottom: -50,
                        child: Opacity(
                          opacity: 0.1,
                          child: Icon(
                            Icons.school,
                            size: 200,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white30,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                widget.level,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            if (isLessonCompleted)
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade500,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, color: Colors.white, size: 14),
                                    SizedBox(width: 5),
                                    Text(
                                      'Completed',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ];
        },
        body: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.teal),
                    SizedBox(height: 16),
                    Text(
                      'Loading content...',
                      style: GoogleFonts.poppins(
                        color: Colors.teal.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10),
                      MarkdownBody(
                        data: lessonContent,
                        styleSheet: MarkdownStyleSheet(
                          h1: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade800,
                          ),
                          h2: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade700,
                          ),
                          h3: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal.shade600,
                          ),
                          p: GoogleFonts.poppins(
                            fontSize: 16,
                            height: 1.6,
                            color: Colors.grey.shade800,
                          ),
                          listBullet: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.teal.shade700,
                          ),
                          strong: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          blockquote: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.grey.shade700,
                            fontStyle: FontStyle.italic,
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: Colors.teal.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.teal.shade100),
                          ),
                          blockquotePadding: EdgeInsets.all(16),
                          codeblockPadding: EdgeInsets.all(16),
                          code: GoogleFonts.firaCode(
                            backgroundColor: Colors.grey.shade200,
                            fontSize: 14,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.teal.shade100, Colors.teal.shade50],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.quiz,
                                    color: Colors.teal.shade700,
                                    size: 24,
                                  ),
                                ),
                                SizedBox(width: 15),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Test Your Knowledge',
                                      style: GoogleFonts.poppins(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal.shade800,
                                      ),
                                    ),
                                    Text(
                                      'Take a quiz!',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: Colors.teal.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            Text(
                              'Complete the quiz with at least 70% to mark this lesson as completed.',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.teal.shade700,
                              ),
                            ),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _startQuiz,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.teal.shade700,
                                minimumSize: Size(double.infinity, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                isLessonCompleted ? 'Retake Quiz' : 'Start Quiz',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final List<Map<String, dynamic>> questions;
  final Function(int, int) onQuizComplete;
  final String lessonTitle;

  QuizScreen({
    required this.questions,
    required this.onQuizComplete,
    required this.lessonTitle,
  });

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  int? selectedAnswerIndex;
  bool hasAnswered = false;
  bool quizCompleted = false;

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Quiz'),
          backgroundColor: Colors.teal.shade700,
        ),
        body: Center(
          child: Text(
            'No questions available for this quiz.',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: Text(
          'Quiz: ${widget.lessonTitle}',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.teal.shade700,
      ),
      body: quizCompleted
          ? _buildQuizSummary()
          : _buildQuizContent(),
    );
  }

  Widget _buildQuizContent() {
    Map<String, dynamic> currentQuestion = widget.questions[currentQuestionIndex];
    String questionText = currentQuestion["question"];
    List<dynamic> options = currentQuestion["options"];
    
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Question ${currentQuestionIndex + 1}/${widget.questions.length}',
                        style: GoogleFonts.poppins(
                          color: Colors.teal.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      height: 10,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.teal.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100 * ((currentQuestionIndex + 1) / widget.questions.length),
                            decoration: BoxDecoration(
                              color: Colors.teal.shade700,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  questionText,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.teal.shade800,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Select the correct answer:',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.teal.shade700,
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: hasAnswered ? [] : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: hasAnswered 
                          ? null 
                          : () => _selectAnswer(index),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getOptionColor(index),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getOptionBorderColor(index),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: _getCircleColor(index),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _getCircleBorderColor(index),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: _getOptionIcon(index),
                              ),
                            ),
                            SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                options[index],
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  color: hasAnswered ? Colors.black87 : Colors.grey.shade800,
                                  fontWeight: selectedAnswerIndex == index 
                                      ? FontWeight.w600 
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: hasAnswered 
                  ? _moveToNextQuestion 
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade700,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                currentQuestionIndex < widget.questions.length - 1 
                    ? 'Next Question' 
                    : 'Finish Quiz',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizSummary() {
    double percentage = (score / widget.questions.length) * 100;
    bool passed = percentage >= 70;
    
    return Container(
      padding: EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: passed ? Colors.green.shade50 : Colors.orange.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    passed ? Icons.check_circle : Icons.info,
                    color: passed ? Colors.green.shade600 : Colors.orange.shade600,
                    size: 64,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  passed 
                      ? 'Congratulations!' 
                      : 'Good Try!',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: passed ? Colors.green.shade800 : Colors.orange.shade800,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  passed 
                      ? 'You passed the quiz!' 
                      : 'Keep learning and try again!',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildScoreStat(
                        'Score',
                        '$score/${widget.questions.length}',
                        Colors.teal,
                      ),
                      Container(
                        height: 40,
                        width: 1,
                        color: Colors.teal.shade200,
                      ),
                      _buildScoreStat(
                        'Percentage',
                        '${percentage.toStringAsFixed(0)}%',
                        passed ? Colors.green : Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.teal.shade700),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Return to Lesson',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      currentQuestionIndex = 0;
                      score = 0;
                      selectedAnswerIndex = null;
                      hasAnswered = false;
                      quizCompleted = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade700,
                    padding: EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Retake Quiz',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreStat(String label, String value, MaterialColor color) {
    return Column(
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: color.shade600,
          ),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color.shade800,
          ),
        ),
      ],
    );
  }

  void _selectAnswer(int index) {
    setState(() {
      selectedAnswerIndex = index;
      hasAnswered = true;
      
      int correctIndex = _findCorrectAnswerIndex();
      if (index == correctIndex) {
        score++;
      }
    });
  }

  void _moveToNextQuestion() {
    if (currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        selectedAnswerIndex = null;
        hasAnswered = false;
      });
    } else {
      setState(() {
        quizCompleted = true;
      });
      widget.onQuizComplete(score, widget.questions.length);
    }
  }

  int _findCorrectAnswerIndex() {
    String correctAnswer = widget.questions[currentQuestionIndex]["answer"];
    List<dynamic> options = widget.questions[currentQuestionIndex]["options"];
    return options.indexOf(correctAnswer);
  }

  Color _getOptionColor(int index) {
    if (!hasAnswered) {
      return selectedAnswerIndex == index ? Colors.teal.shade50 : Colors.white;
    }
    
    int correctIndex = _findCorrectAnswerIndex();
    
    if (index == correctIndex) {
      return Colors.green.shade50;
    } else if (index == selectedAnswerIndex) {
      return Colors.red.shade50;
    } else {
      return Colors.white;
    }
  }

  Color _getOptionBorderColor(int index) {
    if (!hasAnswered) {
      return selectedAnswerIndex == index ? Colors.teal.shade400 : Colors.grey.shade300;
    }
    
    int correctIndex = _findCorrectAnswerIndex();
    
    if (index == correctIndex) {
      return Colors.green.shade400;
    } else if (index == selectedAnswerIndex) {
      return Colors.red.shade400;
    } else {
      return Colors.grey.shade300;
    }
  }

  Color _getCircleColor(int index) {
    if (!hasAnswered) {
      return selectedAnswerIndex == index ? Colors.teal.shade400 : Colors.white;
    }
    
    int correctIndex = _findCorrectAnswerIndex();
    
    if (index == correctIndex) {
      return Colors.green.shade400;
    } else if (index == selectedAnswerIndex) {
      return Colors.red.shade400;
    } else {
      return Colors.white;
    }
  }

  Color _getCircleBorderColor(int index) {
    if (!hasAnswered) {
      return selectedAnswerIndex == index ? Colors.teal.shade400 : Colors.grey.shade400;
    }
    
    int correctIndex = _findCorrectAnswerIndex();
    
    if (index == correctIndex) {
      return Colors.green.shade400;
    } else if (index == selectedAnswerIndex) {
      return Colors.red.shade400;
    } else {
      return Colors.grey.shade400;
    }
  }

  Widget? _getOptionIcon(int index) {
    if (!hasAnswered) {
      return selectedAnswerIndex == index 
          ? Icon(Icons.check, color: Colors.white, size: 16) 
          : null;
    }
    
    int correctIndex = _findCorrectAnswerIndex();
    
    if (index == correctIndex) {
      return Icon(Icons.check, color: Colors.white, size: 16);
    } else if (index == selectedAnswerIndex) {
      return Icon(Icons.close, color: Colors.white, size: 16);
    } else {
      return null;
    }
  }
}