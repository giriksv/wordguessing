import 'package:flutter/material.dart';
import 'word_guess_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Mode'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordGuessScreen(mode: 'easy')),
                );
              },
              child: Text('Easy'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordGuessScreen(mode: 'medium')),
                );
              },
              child: Text('Medium'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordGuessScreen(mode: 'hard')),
                );
              },
              child: Text('Hard'),
            ),
          ],
        ),
      ),
    );
  }
}
