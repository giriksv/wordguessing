import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: Text('Achievements'),
        backgroundColor: Color(0xFF0083CB), // Ensure AppBar color consistency
      ),
      body: Container(
        decoration: buildGradientBackground(), // Apply gradient background
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total Points: ${points['total']}', style: TextStyle(fontSize: 20, color: Colors.white)),
                    SizedBox(height: 10),
                    Text('Points by Easy Mode: ${points['easy']}', style: TextStyle(fontSize: 16, color: Colors.white)),
                    Text('Points by Medium Mode: ${points['medium']}', style: TextStyle(fontSize: 16, color: Colors.white)),
                    Text('Points by Hard Mode: ${points['hard']}', style: TextStyle(fontSize: 16, color: Colors.white)),
                    Text('Points by Five Mode: ${points['five']}', style: TextStyle(fontSize: 16, color: Colors.white)),
                    Text('Points by Six Mode: ${points['six']}', style: TextStyle(fontSize: 16, color: Colors.white)),
                    Text('Points by Seven Mode: ${points['seven']}', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ],
                ),
              );
            }
          },
        ),
      ),
      // bottomNavigationBar: MyApp.buildBottomNavigationBar(
      //   currentIndex: _selectedIndex,
      //   onTap: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //       _onItemTapped(index);
      //     });
      //   },
      // ),
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

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GameSelectionScreen()),
        );
        break;
      case 1:
      // Already on Achievement screen
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ModeSelectionScreen()),
        );
        break;
    }
  }
}
