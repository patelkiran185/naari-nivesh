import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:naari_nivesh/constants.dart';
import 'dart:typed_data';
import 'package:confetti/confetti.dart';

class ScenarioScreen extends StatefulWidget {
  final int level;

  ScenarioScreen({required this.level});

  @override
  _ScenarioScreenState createState() => _ScenarioScreenState();
}

class _ScenarioScreenState extends State<ScenarioScreen> {
  Future<Map<String, dynamic>>? scenarioFuture;
  String? selectedOption;
  bool isEvaluating = false;
  String feedback = "";
  bool isLoading = true; // Track loading state
  late ConfettiController _confettiController; // 🎉 Confetti controller
  String selectedLanguage = "English"; // Default language

  @override
  void initState() {
    super.initState();
    scenarioFuture = fetchScenario();
    _confettiController = ConfettiController(
      duration: Duration(seconds: 3),
    ); // 🎉 Confetti duration
  }

  @override
  void dispose() {
    _confettiController.dispose(); // 🎉 Dispose confetti controller
    super.dispose();
  }

  Future<Map<String, dynamic>> fetchScenario() async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('http://${ip}:5000/scenario/${widget.level}?language=$selectedLanguage'),
      );

      if (response.statusCode == 200) {
        setState(() => isLoading = false);
        return jsonDecode(response.body);
      } else {
        setState(() => isLoading = false);
        throw Exception("Failed to load scenario");
      }
    } catch (e) {
      print("Error fetching scenario: $e");
      setState(() => isLoading = false);
      return {
        "scenario": "Error fetching scenario.",
        "image_base64": null,
        "response_options": [],
      };
    }
  }

  Future<void> evaluateChoice(String choice, String scenario) async {
    setState(() {
      isEvaluating = true;
      feedback = "";
    });

    try {
      final response = await http.post(
        Uri.parse('http://${ip}:5000/evaluate'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "choice": choice,
          "scenario": scenario,
          "language": selectedLanguage, // Pass selected language to backend
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          feedback = data["feedback"] ?? "No feedback available.";
          isEvaluating = false;
        });

        // 🎉 Trigger Confetti Effect when "OK" is pressed in the feedback dialog
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Feedback"),
              content: Text(feedback),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _confettiController.play(); // 🎉 Start confetti effect
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      } else {
        throw Exception("Failed to evaluate choice");
      }
    } catch (e) {
      print("Error evaluating choice: $e");
      setState(() {
        feedback = "Error evaluating response. Try again.";
        isEvaluating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Emergency Scenario"),
        actions: [
          // Language selection dropdown
          DropdownButton<String>(
            value: selectedLanguage,
            onChanged: (String? newValue) {
              setState(() {
                selectedLanguage = newValue!;
                scenarioFuture = fetchScenario(); // Fetch scenario with new language
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
        ],
      ),
      body: Stack(
        children: [
          if (isLoading)
            Center(
              child: CircularProgressIndicator(),
            ) // Show loading indicator while fetching data
          else
            FutureBuilder<Map<String, dynamic>>(
              future: scenarioFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError || !snapshot.hasData) {
                  return Center(child: Text("Error fetching scenario."));
                }

                final scenarioText =
                    snapshot.data?["scenario"] ?? "No scenario available.";
                final String? imageBase64 = snapshot.data?["image_base64"];
                final responseOptions =
                    (snapshot.data?["response_options"] ?? []).cast<String>();

                Uint8List? imageBytes;
                if (imageBase64 != null && imageBase64.isNotEmpty) {
                  imageBytes = base64Decode(imageBase64);
                }

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Scenario text
                        Text(
                          scenarioText,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),

                        // Display Base64 image
                        if (imageBytes != null)
                          Image.memory(
                            imageBytes,
                            height: 200,
                            fit: BoxFit.cover,
                          )
                        else
                          Icon(Icons.image_not_supported, size: 100),

                        SizedBox(height: 16),
                        Text(
                          "Choose what you would do in this situation:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        // Response options
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemCount: responseOptions.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedOption = responseOptions[index];
                                });
                                evaluateChoice(
                                  responseOptions[index],
                                  scenarioText,
                                );
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(vertical: 8),
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      selectedOption == responseOptions[index]
                                          ? Colors.teal.withOpacity(0.3)
                                          : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color:
                                        selectedOption == responseOptions[index]
                                            ? Colors.teal
                                            : Colors.grey,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.touch_app, color: Colors.teal),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        responseOptions[index],
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        if (isEvaluating)
                          Padding(
                            padding: EdgeInsets.all(10.0),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),

          // 🎉 Confetti Widget
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 3.14 / 2, // 🎉 Shoot confetti downward
              emissionFrequency: 0.05, // 🎉 Frequency of confetti
              numberOfParticles: 20, // 🎉 Amount of confetti
              gravity: 0.3, // 🎉 Slow fall
            ),
          ),
        ],
      ),
    );
  }
}