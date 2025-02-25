import 'package:flutter/material.dart';

class MentorProfileScreen extends StatelessWidget {
  final String name;
  final String description;
  final String imageUrl;
  final String expertise;
  final String experience;
  final String contact;

  const MentorProfileScreen({
    super.key,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.expertise,
    required this.experience,
    required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(name),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage(imageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.school, color: Colors.teal),
              title: Text("Expertise: $expertise"),
            ),
            ListTile(
              leading: const Icon(Icons.work, color: Colors.teal),
              title: Text("Experience: $experience"),
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.teal),
              title: Text("Contact: $contact"),
            ),
            const Spacer(),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              ),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Connection request sent!"))
                );
              },
              icon: const Icon(Icons.message),
              label: const Text("Connect"),
            ),
          ],
        ),
      ),
    );
  }
}
