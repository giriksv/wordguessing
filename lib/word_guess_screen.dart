import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter
import 'achievement.dart';
import 'database_helper.dart'; // Import the database helper

class WordGuessScreen extends StatefulWidget {
  final String mode;

  WordGuessScreen({required this.mode});

  @override
  _WordGuessScreenState createState() => _WordGuessScreenState();
}

class _WordGuessScreenState extends State<WordGuessScreen> {
  List<List<String>> wordList = [];
  int currentWordIndex = 0;
  int currentLevel = 1;
  int wordsGuessed = 0;
  int correctGuessesInLevel = 0;
  List<TextEditingController> controllers = [];
  List<FocusNode> focusNodes = [];
  String hint = '';
  String word = '';
  bool isLevelBasedMode = false;

  @override
  void initState() {
    super.initState();
    isLevelBasedMode = ['easy', 'medium', 'hard'].contains(widget.mode);

    if (widget.mode == 'Free Play') {
      isLevelBasedMode = false;
      currentLevel = 1;  // Ensure that level is set to 1 for Free Play
    }

    loadCSV().then((_) => loadState());
  }

  String getSharedPrefKey() {
    return 'currentWordIndex_${widget.mode}';
  }

  String getLevelPrefKey() {
    return 'currentLevel_${widget.mode}';
  }

  Future<void> loadCSV() async {
    final data = await rootBundle.loadString('assets/words.csv');
    List<List<dynamic>> csvTable = const CsvToListConverter().convert(data);

    wordList = csvTable.where((row) {
      switch (widget.mode) {
        case 'easy':
          return row[2] == 1;
        case 'medium':
          return row[3] == 1;
        case 'hard':
          return row[4] == 1;
        case 'five':
          return row[5] == 1;
        case 'six':
          return row[6] == 1;
        case 'seven':
          return row[7] == 1;
        case 'Free Play':
          return true;  // For Free Play, include all words
        default:
          return false;
      }
    }).map((row) => row.map((e) => e.toString()).toList()).toList();

    if (wordList.isNotEmpty) {
      updateWord();
      setupTextFields();
    }
  }

  Future<void> loadState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? storedIndex = prefs.getInt(getSharedPrefKey());
    int? storedLevel = prefs.getInt(getLevelPrefKey());

    if (storedIndex != null && storedIndex < wordList.length) {
      setState(() {
        currentWordIndex = storedIndex;
        currentLevel = storedLevel ?? 1;
        updateWord();
        setupTextFields();
      });
    } else {
      setState(() {
        currentWordIndex = 0;
        currentLevel = 1;
        updateWord();
        setupTextFields();
      });
    }
  }

  Future<void> saveState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(getSharedPrefKey(), currentWordIndex);
    await prefs.setInt(getLevelPrefKey(), currentLevel);
  }

  void updateWord() {
    if (currentWordIndex < wordList.length) {
      hint = wordList[currentWordIndex][1]; // Keep hint as it is
      word = wordList[currentWordIndex][0].toUpperCase(); // Convert word to uppercase
    } else {
      hint = '';
      word = '';
    }
  }

  void setupTextFields() {
    controllers = List.generate(word.length, (index) => TextEditingController());
    focusNodes = List.generate(word.length, (index) => FocusNode());

    if (word.length >= 5) {
      controllers[2].text = word[2];
      controllers[4].text = word[4];
    }
    if (word.length >= 7) {
      controllers[6].text = word[6];
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(getNextFocusNode(0));
    });
  }

  FocusNode getNextFocusNode(int index) {
    for (int i = index; i < focusNodes.length; i++) {
      if (controllers[i].text.isEmpty) {
        return focusNodes[i];
      }
    }
    return focusNodes.last;
  }

  void checkAnswer() async {
    String guessedWord = controllers.map((c) => c.text.toUpperCase()).join();

    if (guessedWord == word) {
      correctGuessesInLevel++;
      wordsGuessed++;

      // Determine points based on mode
      int points = 0;
      switch (widget.mode) {
        case 'easy':
          points = 5;
          break;
        case 'medium':
          points = 7;
          break;
        case 'hard':
          points = 10;
          break;
        default:
          points = 5;  // For other modes including Free Play
          break;
      }

      // Insert points into the database
      final dbHelper = DatabaseHelper();
      if (isLevelBasedMode) {
        await dbHelper.insertOrUpdateByMode(widget.mode, currentLevel, points);
      } else {
        await dbHelper.insertOrUpdateByIndex(currentWordIndex, points);
      }

      if (isLevelBasedMode && wordsGuessed % 10 == 0) {
        _showLevelCompleteDialog();
      } else if (isLevelBasedMode) {
        _showCorrectAnswerDialog();
      } else {
        _nextWord();
      }
    } else {
      _showIncorrectAnswerDialog();
    }
  }

  void _nextWord() {
    setState(() {
      currentWordIndex++;
      if (currentWordIndex < wordList.length) {
        updateWord();
        setupTextFields();
      } else {
        _showGameCompleteDialog();
      }
    });
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Correct!"),
          content: Text("You've guessed the word correctly."),
          actions: [
            TextButton(
              child: Text("Next"),
              onPressed: () {
                Navigator.of(context).pop();
                _nextWord();
              },
            ),
          ],
        );
      },
    );
  }

  void _showIncorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Incorrect!"),
          content: Text("The correct word was: $word"),
          actions: [
            TextButton(
              child: Text("Next"),
              onPressed: () {
                Navigator.of(context).pop();
                _nextWord();
              },
            ),
          ],
        );
      },
    );
  }

  void _showLevelCompleteDialog() {
    saveState();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Level Complete!"),
          content: Text("You've completed Level $currentLevel."),
          actions: [
            TextButton(
              child: Text("Next Level"),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentLevel++;
                  correctGuessesInLevel = 0;
                });
              },
            ),
          ],
        );
      },
    );
  }

  void _showGameCompleteDialog() {
    saveState();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Complete!"),
          content: Text("You've completed all levels."),
          actions: [
            TextButton(
              child: Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(); // Exit to the previous screen
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == 'Free Play' ? 'Free Play' : 'Level $currentLevel'),
        actions: [
          IconButton(
            icon: Icon(Icons.emoji_events),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AchievementScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(hint, style: TextStyle(fontSize: 24)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(word.length, (index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    width: 40,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(1),
                        UpperCaseTextFormatter(),
                      ],
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          FocusScope.of(context).requestFocus(getNextFocusNode(index + 1));
                        }
                      },
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
