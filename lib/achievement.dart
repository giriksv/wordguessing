import 'package:flutter/material.dart';
import 'package:word_guessing_app/View/bottom_navigation.dart';
import 'package:word_guessing_app/main.dart'; // Import the main file for buildBottomNavigationBar
import 'package:word_guessing_app/game_selection_screen.dart';
import 'package:word_guessing_app/mode_selection_screen.dart';
import 'package:word_guessing_app/model/database_helper.dart';

class AchievementScreen extends StatefulWidget {
  @override
  _AchievementScreenState createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: MyApp.buildAppBar(),
      body: Container(
        decoration: buildGradientBackground(), // Apply gradient background
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Achievement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            Expanded(
              child: FutureBuilder<Map<String, int>>(
                future: loadPoints(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error loading points'));
                  } else {
                    final points = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildAchievementCard(
                              'Total Points',
                              points['total'].toString(),
                              Colors.orangeAccent,
                            ),
                            SizedBox(height: 10),
                            _buildAchievementCard(
                              'Points by Easy Mode',
                              points['easy'].toString(),
                              Colors.greenAccent,
                            ),
                            SizedBox(height: 10),
                            _buildAchievementCard(
                              'Points by Medium Mode',
                              points['medium'].toString(),
                              Colors.blueAccent,
                            ),
                            SizedBox(height: 10),
                            _buildAchievementCard(
                              'Points by Hard Mode',
                              points['hard'].toString(),
                              Colors.redAccent,
                            ),
                            SizedBox(height: 10),
                            _buildAchievementCard(
                              'Points by Five Letter',
                              points['five'].toString(),
                              Colors.purpleAccent,
                            ),
                            SizedBox(height: 10),
                            _buildAchievementCard(
                              'Points by Six Letter',
                              points['six'].toString(),
                              Colors.pinkAccent,
                            ),
                            SizedBox(height: 10),
                            _buildAchievementCard(
                              'Points by Seven Letter',
                              points['seven'].toString(),
                              Colors.cyanAccent,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      //bottomNavigationBar: BottomNavigation(currentIndex: 1),
    );
  }

  Widget _buildAchievementCard(String title, String points, Color color) {
    return Card(
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        trailing: Text(
          points,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Future<Map<String, int>> loadPoints() async {
    final dbHelper = DatabaseHelper();
    final totalPoints = await dbHelper.getTotalPoints();
    final pointsByMode = await dbHelper.getPointsByMode();

    return {
      'total': totalPoints['total']!,
      'easy': pointsByMode['easy']!,
      'medium': pointsByMode['medium']!,
      'hard': pointsByMode['hard']!,
      'five': pointsByMode['five']!,
      'six': pointsByMode['six']!,
      'seven': pointsByMode['seven']!,
    };
  }

  BoxDecoration buildGradientBackground() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0083CB), // Start color (top)
          Color(0xFF01D4CA), // End color (bottom)
        ],
      ),
    );
  }
}
