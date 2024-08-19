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

    for (int i = 0; i < controllers.length; i++) {
      controllers[i].addListener(() {
        if (controllers[i].text.length == 1) {
          FocusScope.of(context).requestFocus(getNextFocusNode(i + 1));
        }
      });
    }

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
    if (index < focusNodes.length) {
      return focusNodes[index];
    }
    return focusNodes.last;
  }

  void checkAnswer() async {
    String guessedWord = controllers.map((c) => c.text.toUpperCase()).join();

    if (guessedWord == word) {
      correctGuessesInLevel++;
      wordsGuessed++;

      int points = 0;
      int indexLevel = _getIndexLevelFromMode(widget.mode);

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
          points = 5;
          break;
      }

      final dbHelper = DatabaseHelper();
      if (isLevelBasedMode) {
        await dbHelper.insertOrUpdateByMode(widget.mode, currentLevel, points);
      } else {
        await dbHelper.insertOrUpdateByIndex(indexLevel, points);
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

  int _getIndexLevelFromMode(String mode) {
    switch (mode) {
      case 'five':
        return 4;
      case 'six':
        return 5;
      case 'seven':
        return 6;
      default:
        return 0;
    }
  }

  void _showLevelCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Level Complete', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('You have completed Level $currentLevel.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentLevel++;
                wordsGuessed = 0;
                correctGuessesInLevel = 0;
                currentWordIndex++;
                updateWord();
                setupTextFields();
              });
              saveState();
              Navigator.of(context).pop();
            },
            child: Text('Next Level', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }

  void _showCorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Correct!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('You guessed the word correctly.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentWordIndex++;
                updateWord();
                setupTextFields();
              });
              saveState();
              Navigator.of(context).pop();
            },
            child: Text('Next Word', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  void _showIncorrectAnswerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Incorrect!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('The correct word was $word.'),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                currentWordIndex++;
                updateWord();
                setupTextFields();
              });
              saveState();
              Navigator.of(context).pop();
            },
            child: Text('Next Word', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _nextWord() {
    setState(() {
      currentWordIndex++;
      if (currentWordIndex >= wordList.length) {
        currentWordIndex = 0;  // Restart or end of words
      }
      updateWord();
      setupTextFields();
    });
    saveState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Word Guessing Game'),
        actions: [
          IconButton(
            icon: Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AchievementScreen()),
              );
            },
          ),
        ],
      ),
      body: wordList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hint: ${hint.toLowerCase()}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            SizedBox(height: 20),
            Row(
              children: List.generate(word.length, (index) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      inputFormatters: [UpperCaseTextFormatter()],
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        filled: true,
                        fillColor: Colors.grey[200],
                        contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                      ),
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkAnswer,
              child: Text('Submit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 12.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
