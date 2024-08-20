import 'package:flutter/material.dart';
import 'database_helper.dart';

class AchievementScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievements'),
      ),
      body: FutureBuilder<Map<String, int>>(
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
                  Text('Total Points: ${points['total']}', style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text('Points by Easy Mode: ${points['easy']}', style: TextStyle(fontSize: 16)),
                  Text('Points by Medium Mode: ${points['medium']}', style: TextStyle(fontSize: 16)),
                  Text('Points by Hard Mode: ${points['hard']}', style: TextStyle(fontSize: 16)),
                  Text('Points by Five Mode: ${points['five']}', style: TextStyle(fontSize: 16)),
                  Text('Points by Six Mode: ${points['six']}', style: TextStyle(fontSize: 16)),
                  Text('Points by Seven Mode: ${points['seven']}', style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }
        },
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
}
