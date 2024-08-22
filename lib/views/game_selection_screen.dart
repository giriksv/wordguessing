import 'package:flutter/material.dart';
import 'package:word_guessing_app/word_guess_screen.dart';
import 'index_selection_screen.dart';
import 'mode_selection_screen.dart';

class GameSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Game Selection'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ModeSelectionScreen()),
                );
              },
              child: Text('By Mode'),
            ),
            ElevatedButton(
              onPressed: () {

        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => IndexSelectionScreen()),
        );
                // Implement By Index Navigation
              },
              child: Text('By Index'),
            ),
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WordGuessScreen(mode: 'Free Play'),
            ),
          );
        },
        child: Text('Free Play'),
      ),
          ],
        ),
      ),
    );
  }
}
