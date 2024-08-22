import 'package:flutter/material.dart';
import 'word_guess_screen.dart';

class IndexSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Index'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordGuessScreen(mode: 'five')),
                );
              },
              child: Text('4'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordGuessScreen(mode: 'six')),
                );
              },
              child: Text('5'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => WordGuessScreen(mode: 'seven')),
                );
              },
              child: Text('6'),
            ),
          ],
        ),
      ),
    );
  }
}
