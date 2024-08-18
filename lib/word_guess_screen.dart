import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart'; // Import for TextInputFormatter

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

  FocusNode getNextFocusNode(int currentIndex) {
    for (int i = currentIndex; i < focusNodes.length; i++) {
      if (controllers[i].text.isEmpty) {
        return focusNodes[i];
      }
    }
    return focusNodes[currentIndex];
  }

  Future<void> checkWord() async {
    String userGuess = controllers.map((controller) => controller.text).join().toUpperCase(); // Convert guess to uppercase

    if (userGuess == word) {
      correctGuessesInLevel++;
      wordsGuessed++;

      if (isLevelBasedMode) {
        if (wordsGuessed % 10 == 0) {
          showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: Text('Level Completed!'),
              content: Text('You have completed Level $currentLevel!\nCorrect guesses: $correctGuessesInLevel out of 10'),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    if (currentLevel < 100) {
                      setState(() {
                        currentLevel++;
                        wordsGuessed = 0;
                        correctGuessesInLevel = 0;
                        currentWordIndex = (currentLevel - 1) * 10;
                        updateWord();
                        setupTextFields();
                      });
                      await saveState();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Congratulations! You have completed all levels!')),
                      );
                    }
                  },
                  child: Text('Proceed to Next Level'),
                ),
              ],
            ),
          );
        } else {
          if (currentWordIndex < (currentLevel * 10 - 1)) {
            setState(() {
              currentWordIndex++;
              updateWord();
              setupTextFields();
            });
            await saveState();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Level $currentLevel incomplete. Proceeding to the next level.')),
            );
            Future.delayed(Duration(seconds: 1), () async {
              setState(() {
                currentLevel++;
                wordsGuessed = 0;
                correctGuessesInLevel = 0;
                currentWordIndex = (currentLevel - 1) * 10;
                updateWord();
                setupTextFields();
              });
              await saveState();
            });
          }
        }
      } else {
        if (currentWordIndex < wordList.length - 1) {
          setState(() {
            currentWordIndex++;
            updateWord();
            setupTextFields();
          });
          await saveState();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No more words available in this mode.')),
          );
        }
      }
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Incorrect'),
          content: Text('Correct word: $word'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (currentWordIndex < (currentLevel * 10 - 1) || !isLevelBasedMode) {
                  setState(() {
                    currentWordIndex++;
                    updateWord();
                    setupTextFields();
                  });
                  await saveState();
                }
              },
              child: Text('Next'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void dispose() {
    saveState(); // Save state when the page is closed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mode == 'Free Play' ? 'Guess the Word - Free Play' : 'Guess the Word - Level $currentLevel'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Hint: ${hint.toLowerCase()}'), // Show hint in lowercase
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
                      style: TextStyle(fontSize: 24),
                      maxLength: 1,
                      inputFormatters: [UpperCaseTextFormatter()], // Convert input to uppercase
                      decoration: InputDecoration(
                        counterText: '',
                        border: OutlineInputBorder(),
                      ),
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
              onPressed: checkWord,
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}

// TextInputFormatter to convert input to uppercase
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
